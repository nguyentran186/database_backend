USE fabric_agency;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS=0;
DROP TRIGGER IF EXISTS import_fabric; --  update quantity after import fabric
DROP TRIGGER IF EXISTS delete_Bolt;  -- update fabric quantity after modify bolt
DROP TRIGGER IF EXISTS insert_Bolt; -- update fabric quantity after modify bolt
DROP TRIGGER IF EXISTS insert_bolt_in_order; -- update price of order after modify bolt and order
DROP TRIGGER IF EXISTS delete_bolt_in_order; -- update price of order after modify bolt and order
DROP TRIGGER IF EXISTS price_change; -- update arrearage after modify total price
DROP TRIGGER IF EXISTS delete_part_payment; -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS insert_part_payment;  -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS update_part_payment;  -- update arrearage after modify partial payment
DROP TRIGGER IF EXISTS insert_supplier; -- check insert info
DROP TRIGGER IF EXISTS insert_customer; -- check insert info
DROP TRIGGER IF EXISTS insert_processed_order; -- check insert info
DROP TRIGGER IF EXISTS insert_cancelled_order; -- insert into cancelled order
DROP TRIGGER IF EXISTS partial_payment_status; 
DROP TRIGGER IF EXISTS check_bolt_fab; -- check ì bolt and fabcat not fit in bolt and order
DROP TRIGGER IF EXISTS check_ord_cus; -- check if order and customer not fit in partial payment
DROP TRIGGER IF EXISTS check_mode; -- check customer code

-- IMPORT FABRIC TRIGGER      ////////////////////////////////////////////////////////////////////////
CREATE TRIGGER  import_fabric
	AFTER INSERT ON import_info
	FOR EACH ROW UPDATE fabric_cat SET quantity = quantity + NEW.quantity
		WHERE fabcat_code = NEW.fabcat_code;
        
        
        
-- BOLT TRIGGER         ////////////////////////////////////////////////////////////////////////
CREATE TRIGGER delete_Bolt
	AFTER DELETE ON bolt 
    FOR EACH ROW UPDATE fabric_cat SET quantity = quantity - 1
		WHERE fabcat_code = OLD.fabcat_code;
CREATE TRIGGER insert_Bolt
	AFTER INSERT ON bolt 
    FOR EACH ROW UPDATE fabric_cat SET quantity = quantity + 1
        WHERE fabcat_code = NEW.fabcat_code;
        
        
        
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
    
CREATE EVENT check_mode
	ON SCHEDULE
		AT 2015-01-01 14:56:59 INTERVAL 1 DAY_SECOND
	DO BEGIN
		UPDATE customer SET customer.debt_start_date = 0
			WHERE customer.arrearage < 2000;
		UPDATE customer SET customer.debt_start_date = customer.debt_start_date + 1
			WHERE customer.arrearage >= 2000;
		UPDATE customer SET customer.mode = 'warning'
			WHERE customer.arrearage >= 2000;
		UPDATE customer SET customer.mode = 'bad debt' 
			WHERE customer.debt_start_date > 180;
    END
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
		UPDATE customer SET arrearage = arrearage - NEW.amount
			WHERE customer.customer_code = NEW.customer_code;
		UPDATE fab_order SET res_price = res_price - NEW.amount
			WHERE fab_order.order_code = NEW.order_code;
        
		UPDATE fab_order SET or_status = 'full paid'
			WHERE fab_order.res_price <= 0 && fab_order.total_price <> 0;
		
	END;
$$
CREATE TRIGGER partial_payment_status
	AFTER INSERT ON order_partial_payment 
    FOR EACH ROW BEGIN
		DECLARE o_status varchar(15);
        SELECT get_or_status(NEW.order_code) into o_status;
        IF o_status = 'new'
        THEN
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

CREATE TRIGGER insert_processed_order
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
CREATE TRIGGER check_bolt_fab
	BEFORE INSERT ON bolt_and_order FOR EACH ROW BEGIN
    DECLARE fab_code varchar(6);
    select bolt.fabcat_code into fab_code from bolt where bolt.bolt_code = NEW.bolt_code; 
    IF NEW.fabcat_code <> fab_code THEN 
		BEGIN
        SIGNAL SQLSTATE '10000' 
        SET MESSAGE_TEXT = 'Bolt and Fabric Category not fit';
      END;
    END IF;
    END;
$$
CREATE TRIGGER check_ord_cus
	BEFORE INSERT ON order_partial_payment FOR EACH ROW BEGIN
	DECLARE cus_code varchar(6);
    select fab_order.customer_code into cus_code from fab_order where fab_order.order_code = NEW.order_code;
    IF NEW.customer_code <> cus_code THEN 
    BEGIN
        SIGNAL SQLSTATE '10001' 
        SET MESSAGE_TEXT = 'Customer and Order not fit';
      END;
    END IF;
    END;
$$
DELIMITER ;