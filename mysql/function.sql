USE fabric_agency;
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS get_length;
DROP FUNCTION IF EXISTS get_selling_price;
DROP FUNCTION IF EXISTS order_quantity;
DROP FUNCTION IF EXISTS get_job;
DROP FUNCTION IF EXISTS get_or_status;
DELIMITER $$

CREATE FUNCTION get_length (catcode varchar(6), boltCode varchar(6)) RETURNS INT BEGIN
    DECLARE new_length INT;
    SELECT bolt.length INTO new_length
    FROM bolt
    WHERE catCode = bolt.fabcat_code and boltCode = bolt.bolt_code
    LIMIT 1;
    RETURN new_length;
END$$

CREATE FUNCTION get_selling_price (catCode varchar(6)) RETURNS INT BEGIN
    DECLARE new_price INT;
    SELECT fabcat_current_price.price INTO new_price
    FROM fabric_cat
    JOIN fabcat_current_price ON fabcat_current_price.fabcat_code = fabric_cat.fabcat_code
    WHERE fabric_cat.fabcat_code = catCode
    
    ORDER BY fabcat_current_price.valid_date DESC LIMIT 1;
    RETURN new_price;
END$$

CREATE FUNCTION order_quantity (order_code INT) RETURNS INT BEGIN
  DECLARE order_quantity INT;
  SELECT count(*) into order_quantity 
  FROM fab_order, bolt_and_order
  WHERE fab_order.order_code = bolt_and_order.order_code AND fab_order.order_code = order_code
  GROUP BY fab_order.order_code;
  RETURN order_quantity;
END$$

CREATE FUNCTION get_job (n_employee_code varchar(6)) RETURNS VARCHAR(50) BEGIN
  DECLARE em_code varchar(50);
  SELECT employee_type into em_code
  FROM employee
  WHERE employee.employee_code = n_employee_code 
  LIMIT 1;
  RETURN em_code;
END$$

CREATE FUNCTION get_or_status(n_order_code varchar(6)) RETURNS VARCHAR(15) BEGIN
	DECLARE order_status varchar(15);
	SELECT or_status into order_status
    FROM fab_order
    WHERE fab_order.order_code = n_order_code
    LIMIT 1;
    RETURN order_status;
END$$

DELIMITER ;