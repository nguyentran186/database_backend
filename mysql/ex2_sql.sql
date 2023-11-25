-- Exercise 2.2 a ---------------------------------------------------
SELECT * FROM fabcat_current_price
WHERE valid_date >= '2020-09-01';

SET SQL_SAFE_UPDATES = 0;
UPDATE fabcat_current_price
SET price = price * 1.1
WHERE valid_date >= '2020-09-01';

SELECT * FROM fabcat_current_price
WHERE valid_date >= '2020-09-01';

-- Exercise 2.2 b ---------------------------------------------------


SELECT DISTINCT fab2.supplier_code, fab2.fabcat_code, bolt_and_order.bolt_code, bolt_and_order.order_code
FROM bolt_and_order JOIN 
	(SELECT fab.supplier_code, fab.fabcat_code, bolt.bolt_code
    FROM bolt JOIN 
		(SELECT F.supplier_code, F.fabcat_code 
        FROM fabric_cat AS F JOIN supplier) AS fab)
	AS fab2;    
-- Exercise 2.2 c ---------------------------------------------------

DELIMITER $$
DROP PROCEDURE IF EXISTS total_purchase_price;
CREATE PROCEDURE total_purchase_price (IN sup_code varchar(6))
BEGIN
    
    SELECT  i.import_date, i.import_time, i.fabcat_code, (i.price * i.quantity) AS 'Total purchase price'
    FROM import_info AS i
    WHERE i.supplier_code = sup_code;
    
END; $$

DELIMITER ;

CALL ex22c('SU0005');



-- Exercise 2.2 d ---------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS sort_supplier_by_categories;
CREATE PROCEDURE sort_supplier_by_categories(IN start_date date,
											IN end_date date)
BEGIN
	SELECT t2.supplier_code, t2.supplier_name, COUNT(t2.fabcat_code)
	FROM
		(SELECT t1.supplier_name, t1.supplier_code, t1.fabcat_name, t1.fabcat_code
		FROM (SELECT S.supplier_code, S.name AS supplier_name, F.fabcat_code, F.name AS fabcat_name FROM fabric_cat AS F JOIN supplier AS S
				ON F.supplier_code = S.supplier_code) AS t1 JOIN import_info ON import_info.fabcat_code = t1.fabcat_code
		WHERE import_info.import_date >= start_date and import_info.import_date <= end_date
		) AS t2
    GROUP BY  t2.supplier_code, t2.supplier_name
    ORDER BY COUNT(t2.fabcat_code) DESC;
END; $$
DELIMITER ;

CALL sort_supplier_by_categories('2023-8-8', '2023-11-11');
