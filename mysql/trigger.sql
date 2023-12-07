USE fabric_agency;
SET GLOBAL event_scheduler = ON;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS=0;
DROP TRIGGER IF EXISTS import_fabric; --  update quantity after import fabric
DROP TRIGGER IF EXISTS delete_Bolt;  -- update fabric quantity after modify bolt
DROP TRIGGER IF EXISTS insert_bolt_in_order; -- update price of order after modify bolt and order
DROP TRIGGER IF EXISTS delete_bolt_in_order; -- update price of order after modify bolt and order
DROP TRIGGER IF EXISTS price_change; -- update arrearage after modify total price
DROP TRIGGER IF EXISTS delete_part_payment; -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS insert_part_payment;  -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS update_part_payment;  -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS insert_supplier; -- check insert info
DROP TRIGGER IF EXISTS insert_customer; -- check insert info
DROP TRIGGER IF EXISTS before_insert_processed_order; -- check insert info
DROP TRIGGER IF EXISTS after_insert_processed_order;
DROP TRIGGER IF EXISTS insert_cancelled_order; -- insert into cancelled order
DROP TRIGGER IF EXISTS partial_payment_status; 
DROP TRIGGER IF EXISTS check_mode; -- check customer code
DROP TRIGGER IF EXISTS fill_supplier_code;
DROP TRIGGER IF EXISTS fill_customer_code;


DELIMITER $$
CREATE TRIGGER fill_customer_code
BEFORE INSERT ON order_partial_payment
FOR EACH ROW
BEGIN
    DECLARE existing_customer_code VARCHAR(6);

    -- Find the existing supplier code for the fabcat_code
    SELECT customer_code
    INTO existing_customer_code
    FROM fabric_agency.fab_order
    WHERE order_code = NEW.order_code;
    SET NEW.customer_code = existing_customer_code;
END $$
DELIMITER ;

-- IMPORT FABRIC TRIGGER      ////////////////////////////////////////////////////////////////////////
DELIMITER //
CREATE TRIGGER fill_supplier_code
BEFORE INSERT ON fabric_agency.import_info
FOR EACH ROW
BEGIN
    DECLARE existing_supplier_code VARCHAR(6);
    SELECT supplier_code
    INTO existing_supplier_code
    FROM fabric_agency.fabric_cat
    WHERE fabcat_code = NEW.fabcat_code;
	
    SET NEW.supplier_code = existing_supplier_code;
END //
DELIMITER ;

CREATE TRIGGER  import_fabric
	AFTER INSERT ON import_info
	FOR EACH ROW UPDATE fabric_cat SET quantity = quantity + NEW.quantity
		WHERE fabcat_code = NEW.fabcat_code;
        
        
-- BOLT TRIGGER         ////////////////////////////////////////////////////////////////////////
CREATE TRIGGER delete_Bolt
	AFTER DELETE ON bolt 
    FOR EACH ROW UPDATE fabric_cat SET quantity = quantity - 1
		WHERE fabcat_code = OLD.fabcat_code;
        
        
        
-- BOLT AND ORDER        ////////////////////////////////////////////////////////////////////////
DELIMITER $$
CREATE TRIGGER insert_bolt_in_order
	AFTER INSERT ON bolt_and_order
    FOR EACH ROW BEGIN
    DECLARE length INT;
    DECLARE price INT DEFAULT 0;
    SET length = (select get_length(NEW.fabcat_code, NEW.bolt_code));
    SET price = (select get_selling_price(NEW.fabcat_code));
    
    UPDATE fab_order SET fab_order.total_price = fab_order.total_price + price*length 
			WHERE fab_order.order_code = NEW.order_code;
	UPDATE fab_order SET fab_order.res_price = fab_order.res_price + price*length 
			WHERE fab_order.order_code = NEW.order_code;
	END$$
    
CREATE TRIGGER delete_bolt_in_order 
	BEFORE DELETE ON bolt_and_order FOR EACH ROW BEGIN
    DECLARE order_quantity INT;
    SELECT order_quantity(OLD.order_code) INTO order_quantity;
    IF order_quantity = 1
    THEN 
      BEGIN
        SIGNAL SQLSTATE '42927' 
        SET MESSAGE_TEXT = 'Order must contain at least 1 item';
      END;
	ELSE
		BEGIN 
			DECLARE length INT;
			DECLARE price INT DEFAULT 0;
			SET length = (select get_length(OLD.fabcat_code, OLD.bolt_code));
			SET price = (select get_selling_price(OLD.fabcat_code));
			UPDATE fab_order SET fab_order.total_price = fab_order.total_price - price*length 
			WHERE fab_order.order_code = OLD.order_code;
        END;
    END IF;
  END
$$

DELIMITER ;






-- ORDER TRIGGER       ////////////////////////////////////////////////////////////////////////

DELIMITER $$
CREATE TRIGGER price_change 
	AFTER UPDATE 
    ON fab_order FOR EACH ROW BEGIN
		IF NEW.total_price <> OLD.total_price THEN
			UPDATE customer
        SET arrearage = arrearage + (NEW.total_price - OLD.total_price)
        WHERE customer_code = NEW.customer_code;
        END IF;
	END
    $$
    
DELIMITER //
CREATE EVENT check_mode
ON SCHEDULE
    EVERY 1 SECOND
-- Set the schedule for every second for easier to observe the behavior
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 YEAR
-- Also set the end time for 1 year from now so that the event will accidentally not run forever
ON COMPLETION PRESERVE
DO BEGIN
    UPDATE fabric_agency.customer
    SET mode = 'normal'
    WHERE arrearage < 2000;

    UPDATE fabric_agency.customer
    SET mode = 'warning'
    WHERE arrearage >= 2000 AND mode = 'normal';

    UPDATE fabric_agency.customer
    SET mode = 'bad debt'
    WHERE DATEDIFF(CURDATE(), debt_date) > 180 AND arrearage >= 2000;

END;
//
DELIMITER ;   
        
        
        
DELIMITER $$
-- PARTIAL PAYMENT TRIGGER     
      
CREATE TRIGGER delete_part_payment
	AFTER DELETE ON order_partial_payment
    FOR EACH ROW UPDATE customer SET arrearage = arrearage + OLD.amount
		WHERE customer.customer_code = OLD.customer_code;
        
     
CREATE TRIGGER insert_part_payment
	AFTER INSERT ON order_partial_payment
    FOR EACH ROW BEGIN 
      DECLARE v_customer_cur_arrearage INT DEFAULT 0;
      DECLARE v_customer_cur_debt_date date;

      UPDATE customer SET arrearage = arrearage - NEW.amount
        WHERE customer.customer_code = NEW.customer_code;
      UPDATE fab_order SET res_price = res_price - NEW.amount
        WHERE fab_order.order_code = NEW.order_code;
          
      UPDATE fab_order SET or_status = 'full paid'
        WHERE res_price <= 0;

      SELECT arrearage, debt_date
      INTO v_customer_cur_arrearage, v_customer_cur_debt_date
      FROM customer
      WHERE customer_code = NEW.customer_code;

      IF v_customer_cur_arrearage <= 0 AND v_customer_cur_debt_date IS NOT NULL THEN
        UPDATE fabric_agency.customer
        SET debt_date = NULL
        WHERE customer_code = NEW.customer_code;
      END IF;
		
	END;
$$
CREATE TRIGGER partial_payment_status
	AFTER INSERT ON order_partial_payment 
    FOR EACH ROW BEGIN
		DECLARE o_status varchar(15);
        SELECT get_or_status(NEW.order_code) into o_status;
        IF o_status = 'new' OR o_status = 'cancelled' THEN
          BEGIN
            SIGNAL SQLSTATE '44000' 
            SET MESSAGE_TEXT = 'Cannot insert partial payment for new or cancelled order';
          END;
        ElSEIF o_status != 'full paid' THEN
          UPDATE fab_order SET fab_order.or_status = 'partial paid'
            WHERE fab_order.order_code = NEW.order_code;
        END IF;
    END;
$$
CREATE TRIGGER update_part_payment	
	AFTER UPDATE ON order_partial_payment FOR EACH ROW BEGIN
		IF NEW.amount <> OLD.amount THEN
			UPDATE customer
        SET arrearage = arrearage - (NEW.amount - OLD.amount)
        WHERE customer_code = NEW.customer_code;
        END IF;
	END
    $$
DELIMITER ;

-- EMPLOYEE         ////////////////////////////////////////////////////////////////////////

DELIMITER $$
CREATE TRIGGER insert_customer 
	BEFORE INSERT ON customer FOR EACH ROW BEGIN
    DECLARE job_type varchar(50);
    SELECT get_job(NEW.office_staff_code) INTO job_type;
    IF job_type <> 'ofc_staff'
    THEN 
      BEGIN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee job position is not appropriate';
      END;
    END IF;
  END
$$

CREATE TRIGGER insert_supplier
	BEFORE INSERT ON supplier FOR EACH ROW BEGIN
    DECLARE job_type varchar(50);
    SELECT get_job(NEW.partner_staff_code) INTO job_type;
    IF job_type <> 'partner_staff'
    THEN 
      BEGIN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee job position is not appropriate';
      END;
    END IF;
  END
$$

CREATE TRIGGER before_insert_processed_order
	BEFORE INSERT ON processed_order FOR EACH ROW BEGIN
    DECLARE job_type varchar(50);
    SELECT get_job(NEW.ops_staff_code) INTO job_type;
    IF job_type <> 'ops_staff'
    THEN 
      BEGIN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee job position is not appropriate';
      END;
	ELSE BEGIN
			UPDATE fab_order SET or_status = 'ordered' 
				WHERE fab_order.order_code = NEW.order_code;
		END;
    END IF;
  END
$$

CREATE TRIGGER after_insert_processed_order
	AFTER INSERT ON processed_order FOR EACH ROW BEGIN
    DECLARE v_order_price INT DEFAULT 0;
    DECLARE v_customer_code VARCHAR(50);
    DECLARE v_date_made date;
    DECLARE v_customer_cur_arrearage INT DEFAULT 0;
    DECLARE v_customer_cur_debt_date date;
    DECLARE v_cur_mode VARCHAR(20);
    DECLARE total_res_price INT;


    SELECT customer_code, total_price, DATE(date_time)
    INTO v_customer_code, v_order_price, v_date_made
    FROM fabric_agency.fab_order
    WHERE order_code = NEW.order_code;

    SELECT mode, debt_date
    INTO v_cur_mode, v_customer_cur_debt_date
    FROM fabric_agency.customer
    WHERE customer_code = v_customer_code;

    -- Calculate the sum of res prices for the customer
    SELECT SUM(res_price) INTO total_res_price
    FROM fabric_agency.fab_order
    WHERE customer_code = v_customer_code AND or_status NOT IN ('new', 'cancelled');

    -- Update the customer arrearage
    UPDATE fabric_agency.customer
    SET arrearage = total_res_price
    WHERE customer_code = v_customer_code;

    IF v_customer_cur_debt_date IS NULL THEN 
      BEGIN
        UPDATE fabric_agency.customer
        SET debt_date = DATE(NEW.processed_datetime)
        WHERE customer_code = v_customer_code;
      END;
    END IF;
  END
$$


CREATE TRIGGER insert_cancelled_order
	BEFORE INSERT ON cancelled_order FOR EACH ROW BEGIN
    DECLARE job_type varchar(50);
    SELECT get_job(NEW.ops_staff_code) INTO job_type;
    IF job_type <> 'ops_staff'
    THEN 
      BEGIN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee job position is not appropriate';
      END;
	ELSE BEGIN
			UPDATE fab_order SET or_status = 'cancelled' 
				WHERE fab_order.order_code = NEW.order_code;
			DELETE FROM processed_order WHERE processed_order.order_code = NEW.order_code;
		END;
    END IF;
  END
  $$
DELIMITER ;

DELIMITER //

-- CREATE TRIGGER update_customer_arrearage_after_insert
-- AFTER INSERT ON fabric_agency.fab_order
-- FOR EACH ROW
-- BEGIN
--     DECLARE total_res_price INT;

--     -- Calculate the sum of res prices for the customer
--     SELECT SUM(res_price) INTO total_res_price
--     FROM fabric_agency.fab_order
--     WHERE customer_code = NEW.customer_code;

--     -- Update the customer arrearage
--     UPDATE fabric_agency.customer
--     SET arrearage = total_res_price
--     WHERE customer_code = NEW.customer_code;
-- END;

-- //

CREATE TRIGGER update_customer_arrearage_after_update
AFTER UPDATE ON fabric_agency.fab_order
FOR EACH ROW
BEGIN
    DECLARE total_res_price INT;

    -- Calculate the sum of res prices for the customer
    SELECT SUM(res_price) INTO total_res_price
    FROM fabric_agency.fab_order
    WHERE customer_code = NEW.customer_code AND or_status NOT IN ('new', 'cancelled');

    -- Update the customer arrearage
    UPDATE fabric_agency.customer
    SET arrearage = total_res_price
    WHERE customer_code = NEW.customer_code;
END;

//

DELIMITER ;
