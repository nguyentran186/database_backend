drop database fabric_agency;


CREATE DATABASE fabric_agency
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.employee (
	employee_code varchar(6) not null,
    CONSTRAINT employee_code
		CHECK (employee_code REGEXP 'EM[0-9][0-9][0-9][0-9]'),
    
    employee_type varchar(50),
	CONSTRAINT employee_type
		CHECK (employee_type IN ('manager', 'ops_staff', 'ofc_staff', 'partner_staff')),
    
	first_name varchar(50),
	last_name varchar(50),
	gender varchar(6)
    CONSTRAINT gender
		CHECK (gender IN ('male','female')),
	address varchar(60),
	
	PRIMARY KEY (employee_code)
)
;

CREATE TABLE fabric_agency.employee_phone_number (
	employee_code varchar(6) not null,
    phone_num varchar(11) not null,
    
    CONSTRAINT check_phone_employee
		CHECK (phone_num not like '%[^0-9]%'), 
	
    FOREIGN KEY (employee_code)
		REFERENCES employee(employee_code)
        ON UPDATE cascade
        ON DELETE cascade,
    PRIMARY KEY (employee_code, phone_num)
)
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.customer (
	customer_code varchar(6) not null,
    CONSTRAINT customer_code
		CHECK (customer_code REGEXP 'CU[0-9][0-9][0-9][0-9]'),
        
    office_staff_code varchar(6) not null,
    
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    address	varchar(60),
    mode varchar(20) default 'normal',
    arrearage int,
    debt_date date,
    
    FOREIGN KEY (office_staff_code)
		REFERENCES employee(employee_code)
        ON UPDATE cascade
        ON DELETE no action,
    PRIMARY KEY (customer_code)
)
;

CREATE TABLE fabric_agency.customer_phone_number (
	customer_code varchar(6) not null,
    phone_num varchar(11) not null,
    
    CONSTRAINT check_phone_customer
		CHECK (phone_num not like '%[^0-9]%'), 
    
    FOREIGN KEY (customer_code)
		REFERENCES customer(customer_code)
        ON UPDATE cascade
        ON DELETE cascade,
    
    PRIMARY KEY (customer_code, phone_num)
)
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.fab_order (
	order_code varchar(6) not null,
    CONSTRAINT order_code
		CHECK (order_code REGEXP 'OR[0-9][0-9][0-9][0-9]'),
    customer_code varchar(6) not null,
    
    total_price int default 0,
    CONSTRAINT total_price
		CHECK (total_price>=0),
	
    res_price int default 0,
    
    or_status varchar(15),
    CONSTRAINT or_status
		CHECK (or_status IN ('new','ordered','partial paid','full paid','cancelled')),
    
    date_time datetime,
    
    FOREIGN KEY (customer_code)
		REFERENCES customer(customer_code) 
		ON UPDATE cascade
        ON DELETE no action,
    PRIMARY KEY (order_code)
)
;

CREATE TABLE fabric_agency.processed_order (
	order_code varchar(6) not null,
    ops_staff_code varchar(6) not null,
    processed_datetime datetime,
    
    
    FOREIGN KEY (order_code) 
		REFERENCES fab_order(order_code)
        ON UPDATE cascade
        ON DELETE no action,
	FOREIGN KEY (ops_staff_code) 
		REFERENCES employee(employee_code)
        ON UPDATE cascade
        ON DELETE no action,
    PRIMARY KEY (order_code)
)	
;

CREATE TABLE fabric_agency.cancelled_order (
	order_code varchar(6) not null,
    ops_staff_code varchar(6) not null,
    cancelled_reason varchar(110),
    
    FOREIGN KEY (order_code) 
		REFERENCES fab_order(order_code)
        ON UPDATE cascade
        ON DELETE cascade,
	FOREIGN KEY (ops_staff_code) 
		REFERENCES employee(employee_code)
        ON UPDATE cascade
        ON DELETE no action,
    PRIMARY KEY (order_code)
)
;

CREATE TABLE fabric_agency.order_partial_payment (
	order_code varchar(6) not null,
    customer_code varchar(6),
    pay_date date not null,
    pay_time time not null,
    
    amount int,
	
    FOREIGN KEY (order_code)
		REFERENCES fab_order(order_code)
        ON UPDATE cascade
        ON DELETE cascade,
	FOREIGN KEY (customer_code)
		REFERENCES customer(customer_code)
        ON UPDATE cascade
        ON DELETE cascade,
	PRIMARY KEY (order_code, pay_date, pay_time)
)
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.supplier	 (
	supplier_code varchar(6) not null,
    CONSTRAINT supplier_code
		CHECK (supplier_code REGEXP 'SU[0-9][0-9][0-9][0-9]'),
    
    partner_staff_code varchar(6) not null,
    
    name varchar(50) not null,
    address varchar(60),
    
    bank_account varchar(15),
    CONSTRAINT bank_account
		CHECK (bank_account not like '%[^0-9]%'), 
        
    tax_code varchar(13),
    
    FOREIGN KEY (partner_staff_code)
		REFERENCES employee(employee_code)
        ON UPDATE cascade
        ON DELETE no action,
	PRIMARY KEY (supplier_code)
)
;

CREATE TABLE fabric_agency.supplier_phone_number (
    supplier_code varchar(6) not null,
    phone_num varchar(11) not null,
    
    CONSTRAINT check_phone_supplier
		CHECK (phone_num not like '%[^0-9]%'), 
    
    FOREIGN KEY (supplier_code)
		REFERENCES supplier(supplier_code)
        ON UPDATE no action
        ON DELETE no action,
	PRIMARY KEY (supplier_code, phone_num)
)
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.fabric_cat (
	fabcat_code varchar(6) not null,
		CONSTRAINT fabcat_code
 		CHECK (fabcat_code REGEXP 'FA[0-9][0-9][0-9][0-9]'),
	supplier_code varchar(6),
    
	name varchar(50),
	color varchar(50),
	quantity int,
	
	FOREIGN KEY (supplier_code)
		REFERENCES supplier(supplier_code)
        ON UPDATE cascade
        ON DELETE no action,
	PRIMARY KEY (fabcat_code)
)
;

CREATE TABLE fabric_agency.fabcat_current_price (
	fabcat_code varchar(6) not null,
    valid_date date not null,
    price int not null,
    
    FOREIGN KEY (fabcat_code)
		REFERENCES fabric_cat(fabcat_code)
        ON UPDATE cascade
        ON DELETE cascade,
    PRIMARY KEY (fabcat_code, valid_date, price)
)
;

CREATE TABLE fabric_agency.import_info (
	fabcat_code varchar(6) not null,
    supplier_code varchar(6) default 'SU0000',
    import_date date not null,
    import_time time not null,
    
    quantity int,
    price int,
    
    FOREIGN KEY (fabcat_code)
		REFERENCES fabric_cat(fabcat_code)
        ON UPDATE cascade
        ON DELETE cascade,
	FOREIGN KEY (supplier_code)
		REFERENCES supplier(supplier_code)
        ON UPDATE cascade
        ON DELETE cascade,
    PRIMARY KEY (fabcat_code, supplier_code, import_date, import_time)
)
;

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

CREATE TABLE fabric_agency.bolt (
	bolt_code varchar(6) not null,
    CONSTRAINT bolt_code
		CHECK (bolt_code REGEXP 'BO[0-9][0-9][0-9][0-9]'),
    
    fabcat_code varchar(6) not null,
    
    length int,    
    
    FOREIGN KEY (fabcat_code) 
		REFERENCES fabric_cat(fabcat_code)
        ON DELETE cascade
        ON UPDATE cascade,
    PRIMARY KEY (bolt_code, fabcat_code)
)
;

CREATE TABLE fabric_agency.bolt_and_order (
	bolt_code varchar(6) not null,
    order_code varchar(6) not null,
    fabcat_code varchar(6) not null,

    FOREIGN KEY (bolt_code)
		REFERENCES bolt(bolt_code)
		ON UPDATE cascade
        ON DELETE no action,
    FOREIGN KEY (order_code)
		REFERENCES fab_order(order_code)
        ON UPDATE cascade
        ON DELETE cascade,
	FOREIGN KEY (fabcat_code)
		REFERENCES bolt(fabcat_code)
        ON UPDATE cascade
        ON DELETE no action,
	PRIMARY KEY (bolt_code, order_code, fabcat_code)
)
;






