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