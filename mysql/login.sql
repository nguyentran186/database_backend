DROP DATABASE IF EXISTS login;
CREATE DATABASE login;

CREATE TABLE login.admin_account (
	username varchar(30),
    password varchar(30),
    PRIMARY KEY (username)
);

INSERT INTO login.admin_account(username, password) values 
('admin1', '123456'),
('admin2', '123456');

SELECT * FROM login.admin_account;

CREATE TABLE login.admin_account_hash (
    username varchar(30),
    password_hash varchar(60),
    PRIMARY KEY (username)
);

-- Both accounts have the same password "123456"
INSERT INTO login.admin_account_hash(username, password_hash) values 
('admin1', '$2b$12$w1WuhV2TYbIgdXyUazsWcelBWzrMPb1o5WinLaxBfJ5mcVC0/jwA6'),
('admin2', '$2b$12$MSPjPt6goroLC9R8DK5BIOqXUqofRxF8m4B86wSpoZ8EUpnJKgXpm');

SELECT * FROM login.admin_account_hash;