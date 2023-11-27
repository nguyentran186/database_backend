DROP DATABASE IF EXISTS login;
CREATE DATABASE login;

CREATE TABLE admin_account (
	username varchar(30),
    password varchar(30),
    PRIMARY KEY (username)
);

INSERT INTO admin_account(username, password) values 
('admin1', '123456'),
('admin2', '123456');

SELECT * FROM admin_account;