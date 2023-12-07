USE fabric_agency;

INSERT INTO employee(employee_code, employee_type, first_name, last_name, gender, address) VALUES
('EM0001','manager', 'Nguyen', 'Tran', 'male', '720A Dien Bien Phu'),
('EM0002','ops_staff', 'Thanh', 'Dinh Viet', 'male', '15 To Hien Thanh'),
('EM0003','ofc_staff', 'Linh', 'Tran Khanh', 'female', '72 To Huu'),
('EM0004','partner_staff', 'Ngoc', 'Nguyen Bao', 'female', '260 Ly Thuong Kiet'),
('EM0005','partner_staff', 'Minh', 'Nguyen Nhat', 'male', '24 Dong Nai'),
('EM0006','ops_staff', 'Huyen', 'Phan Khanh', 'female', '26 Thanh Thai'),
('EM0007','ofc_staff', 'Nhi', 'Phan Uyen', 'female', '150 Ly Thai To'),
('EM0008','ops_staff', 'Thien', 'Ton Nu Y', 'male', '135 To Hien Thanh'),
('EM0009','ops_staff', 'Thanh', 'Nguyen Thanh', 'male', '15 Thanh Thai');

INSERT INTO employee_phone_number(phone_num, employee_code) VALUES
 ('0985054654', 'EM0001'),
 ('0956054654', 'EM0001'),
 ('0541355654', 'EM0002'),
 ('0989866654', 'EM0003'),
 ('0985058086', 'EM0004'),
 ('0985059854', 'EM0005'),
 ('0985054459', 'EM0005'),
 ('0354151335', 'EM0006'),
 ('0985065450', 'EM0007'),
 ('0985990535', 'EM0007'),
 ('0935115050', 'EM0007')
;

INSERT INTO customer(customer_code, office_staff_code, first_name, last_name, address) VALUES
('CU0001', 'EM0003','Minh', 'Hoang Phan', '12 Le Van Viet'),
('CU0002', 'EM0007','Linh', 'Pham Khanh', '112 Hoang Van Thu'),
('CU0003', 'EM0007','Dinh', 'Pham My', '14 Cong Hoa'),
('CU0004', 'EM0003','Hoang', 'Dinh Anh', '42 Dong Khoi'),
('CU0005', 'EM0007','Phu', 'Nguyen Anh', '52 Pham Ngu Lao');

INSERT INTO customer_phone_number(phone_num, customer_code) VALUES
 ('0985051233', 'CU0001'),
 ('0923123213', 'CU0001'),
 ('0542091301', 'CU0002'),
 ('0989091238', 'CU0003'),
 ('0985001922', 'CU0004'),
 ('0980192303', 'CU0005'),
 ('0985054123', 'CU0005'),
 ('0354151231', 'CU0004'),
 ('0985065450', 'CU0003'),
 ('0985990535', 'CU0002'),
 ('0935115050', 'CU0001'),
 ('0985912335', 'CU0002'),
 ('0935115023', 'CU0003'),
 ('0985990312', 'CU0004'),
 ('0935131231', 'CU0005')
;

INSERT INTO fab_order(order_code, customer_code, or_status, date_time) VALUES
('OR0001', 'CU0001', 'new', '2023-06-18 06:18:33'),
('OR0002', 'CU0002', 'new', '2023-07-22 04:12:03'),
('OR0003', 'CU0003', 'new', '2022-2-14 16:18:33'),
('OR0004', 'CU0004', 'new', '2022-09-06 20:15:33'),
('OR0005', 'CU0005', 'new', '2022-10-14 13:18:24'),
('OR0006', 'CU0005', 'new', '2021-12-08 06:18:33'),
('OR0007', 'CU0004', 'new', '2021-3-11 23:40:16'),
('OR0008', 'CU0001', 'new', '2023-09-27 11:18:33'),
('OR0009', 'CU0002', 'new', '2022-06-26 9:36:37'),
('OR0010', 'CU0003', 'new', '2022-07-25 9:30:28'),
('OR0011', 'CU0004', 'new', '2023-06-24 12:25:19'),
('OR0012', 'CU0005', 'new', '2022-09-18 15:15:30');

INSERT INTO processed_order (order_code, ops_staff_code, processed_datetime) VALUES
('OR0002', 'EM0002', '2023-07-22 04:12:03'),
('OR0003', 'EM0008', '2022-2-15 16:18:33'),
('OR0004', 'EM0009', '2022-09-07 20:15:33'),
('OR0006', 'EM0008', '2021-12-11 06:18:33'),
('OR0008', 'EM0002', '2023-10-03 11:18:33');

INSERT INTO cancelled_order (order_code, ops_staff_code, cancelled_reason) VALUES
('OR0005', 'EM0002', 'Not enough bolt'),
('OR0009', 'EM0009', 'Customer arrearage is over limit'),
('OR0010', 'EM0006', 'I do not like selling to you'),
('OR0011', 'EM0006', 'Not enough bolt'),
('OR0012', 'EM0008', 'Not enough bolt');

INSERT INTO supplier(supplier_code, partner_staff_code, name, address, bank_account, tax_code) VALUES
('SU0001', 'EM0004', 'Silk Agency', '15 Le Thanh Ton', '00129300312', 'FA1234'),
('SU0002', 'EM0005', 'MSoft', '24 CMT8', '00131351353', 'FA3514'),
('SU0003', 'EM0004', 'Amaron', '155 Ly Thai To', '00988453213', 'FA9803'),
('SU0004', 'EM0005', 'Mate', '213 Truong Dinh', '00153684352', 'FA6512'),
('SU0005', 'EM0005', 'Appel', '25 Ly Thai To', '00135121351', 'FA1351');

INSERT INTO supplier_phone_number(supplier_code, phone_num) VALUES
('SU0001', '0654345108'),
('SU0001', '0651231238'),
('SU0001', '0651081284'),
('SU0002', '0012938012'),
('SU0002', '0049124041'),
('SU0003', '0019283901'),
('SU0004', '0604540535'),
('SU0005', '0905560655'),
('SU0005', '0656506568');

INSERT INTO fabric_cat (fabcat_code, name, color, quantity, supplier_code) VALUES
('FA0001', 'Tasar Silk', 'blue', 2, 'SU0005'),
('FA0002', 'Muga Silk', 'green', 2, 'SU0004'),
('FA0003', 'Eri Silk', 'purple', 2, 'SU0001'),
('FA0004', 'Pima Cotton', 'blue', 2, 'SU0005'),
('FA0005', 'Upland Cotton', 'green', 2, 'SU0003'),
('FA0006', 'Egyptian Cotton', 'purple', 2, 'SU0002'),
('FA0007', 'Full Grain Leather', 'blue', 2, 'SU0002'),
('FA0008', 'Corrected Grain Leather', 'green', 2, 'SU0003'),
('FA0009', 'Bonded Leather', 'purple', 2, 'SU0004');

INSERT INTO fabcat_current_price (fabcat_code, price, valid_date) VALUES
('FA0001', 146, '2023-11-01'),
('FA0001', 193, '2023-11-02'),
('FA0001', 219, '2023-12-05'),
('FA0002', 220, '2023-12-01'),
('FA0002', 330, '2023-10-31'),
('FA0003', 293, '2023-11-01'),
('FA0004', 250, '2023-12-01'),
('FA0005', 300, '2023-12-01'),
('FA0006', 350, '2023-11-01'),
('FA0007', 400, '2023-10-01'),
('FA0008', 450, '2023-11-01'),
('FA0009', 500, '2023-11-01'),
('FA0006', 605, '2023-11-02');

INSERT INTO import_info(fabcat_code, import_date, import_time, quantity, price) VALUES
('FA0001', '2023-09-18', '07:00:00', 4, 250),
('FA0005', '2023-09-30', '08:00:00',1, 124),
('FA0001', '2023-09-12', '05:00:00',2, 156),
('FA0002', '2023-09-17', '16:00:00',4, 89),
('FA0001', '2023-09-06', '14:00:00',10, 120),
('FA0004', '2023-09-09', '19:00:00',6, 220),
('FA0006', '2023-09-11', '20:00:00',1, 413)

;

INSERT INTO fabric_agency.bolt (bolt_code, fabcat_code, length)
VALUES
('BO0001', 'FA0003', 9),
('BO0002', 'FA0003', 4),
('BO0003', 'FA0006', 2),
('BO0004', 'FA0003', 9),
('BO0005', 'FA0009', 4),
('BO0006', 'FA0007', 2),
('BO0007', 'FA0009', 5),
('BO0008', 'FA0002', 4),
('BO0009', 'FA0008', 4),
('BO0010', 'FA0006', 8),
('BO0011', 'FA0006', 5),
('BO0012', 'FA0007', 5),
('BO0013', 'FA0006', 5),
('BO0014', 'FA0008', 1),
('BO0015', 'FA0006', 1),
('BO0016', 'FA0004', 2),
('BO0017', 'FA0006', 5),
('BO0018', 'FA0003', 2),
('BO0019', 'FA0006', 1),
('BO0020', 'FA0009', 5),
('BO0021', 'FA0005', 8),
('BO0022', 'FA0001', 1),
('BO0023', 'FA0005', 5),
('BO0024', 'FA0009', 6),
('BO0025', 'FA0002', 8),
('BO0026', 'FA0007', 3),
('BO0027', 'FA0007', 6),
('BO0028', 'FA0006', 6),
('BO0029', 'FA0004', 1),
('BO0030', 'FA0002', 7);

INSERT INTO fabric_agency.bolt_and_order (bolt_code, order_code, fabcat_code)
VALUES
('BO0020', 'OR0001', 'FA0009'),
('BO0002', 'OR0002', 'FA0003'),
('BO0008', 'OR0002', 'FA0002'),
('BO0013', 'OR0002', 'FA0006'),
('BO0021', 'OR0002', 'FA0005'),
('BO0015', 'OR0003', 'FA0006'),
('BO0030', 'OR0003', 'FA0002'),
('BO0003', 'OR0004', 'FA0006'),
('BO0004', 'OR0004', 'FA0003'),
('BO0005', 'OR0004', 'FA0009'),
('BO0007', 'OR0004', 'FA0009'),
('BO0011', 'OR0004', 'FA0006'),
('BO0017', 'OR0004', 'FA0006'),
('BO0028', 'OR0004', 'FA0006'),
('BO0029', 'OR0004', 'FA0004'),
('BO0006', 'OR0005', 'FA0007'),
('BO0014', 'OR0010', 'FA0008'),
('BO0024', 'OR0011', 'FA0009'),
('BO0019', 'OR0006', 'FA0006'),
('BO0009', 'OR0007', 'FA0008'),
('BO0016', 'OR0007', 'FA0004'),
('BO0022', 'OR0007', 'FA0001'),
('BO0001', 'OR0008', 'FA0003'),
('BO0012', 'OR0008', 'FA0007'),
('BO0026', 'OR0008', 'FA0007'),
('BO0027', 'OR0008', 'FA0007'),
('BO0010', 'OR0009', 'FA0006'),
('BO0018', 'OR0009', 'FA0003'),
('BO0023', 'OR0012', 'FA0005'),
('BO0025', 'OR0009', 'FA0002');


INSERT INTO order_partial_payment (order_code, pay_date, pay_time, amount) VALUES
('OR0008', '2023-06-22', '01:18:32', 150),
-- ('OR0002', '2023-08-11', '14:05:51', 400),
('OR0003', '2023-03-11', '11:38:16', 250),
('OR0008', '2023-06-23', '01:18:32', 400),
('OR0008', '2023-06-24', '01:18:32', 1500),
-- ('OR0001', '2023-06-22', '01:18:32', 150),
('OR0004', '2023-09-27', '20:18:15', 7000),
('OR0008', '2023-06-29', '12:18:32', 6187);