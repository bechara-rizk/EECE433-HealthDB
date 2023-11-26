DROP TRIGGER IF EXISTS check_doctor_hospital_trigger ON doctor_table;
DROP TRIGGER IF EXISTS check_coverage ON insurance_plan;
DROP TRIGGER IF EXISTS check_hospital_doctor_trigger ON hospital;
DROP TRIGGER IF EXISTS check_customer_insures_trigger ON customer_table;
DROP TRIGGER IF EXISTS check_customer_pays_trigger ON customer_table;
DROP TRIGGER IF EXISTS check_bill_pays_trigger ON bill;
DROP TRIGGER IF EXISTS check_department_employees_trigger ON department_table;
DROP VIEW IF EXISTS customer;
DROP VIEW IF EXISTS bill_view;
DROP VIEW IF EXISTS broker;
DROP VIEW IF EXISTS family_member;
DROP VIEW IF EXISTS employee;
DROP VIEW IF EXISTS department;
DROP VIEW IF EXISTS doctor;
DROP TABLE IF EXISTS pays;
DROP TABLE IF EXISTS insures;
DROP TABLE IF EXISTS covers;
DROP TABLE IF EXISTS works_in;
DROP TABLE IF EXISTS accepts;
DROP TABLE IF EXISTS tests;
DROP TABLE IF EXISTS lab_location;
DROP TABLE IF EXISTS customer_diseases;
DROP TABLE IF EXISTS customer_exclusions;
DROP TABLE IF EXISTS f_member_diseases;
DROP TABLE IF EXISTS family_member_table;
DROP TABLE IF EXISTS operates_on;
DROP TABLE IF EXISTS customer_table;
DROP TABLE IF EXISTS broker_table;
DROP TABLE IF EXISTS lab;
DROP TABLE IF EXISTS hospital;
DROP TABLE IF EXISTS insurance_plan;
DROP TABLE IF EXISTS bill;
DROP TABLE IF EXISTS doctor_table;
ALTER TABLE IF EXISTS department_table DROP CONSTRAINT fk_manager;
DROP TABLE IF EXISTS employee_table;
DROP TABLE IF EXISTS department_table;

-------------------- TABLEs

CREATE TABLE employee_table (
    ssn bigint PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone bigint NOT NULL,
    extension int,
    date_hired date NOT NULL,
-- 	years_hired int,
    address text,
    salary numeric NOT NULL,
--  age int,
	dob date NOT NULL,
    su_ssn bigint,
    d_name text
);

CREATE TABLE department_table (
    name text PRIMARY KEY,
    extension int NOT NULL,
    floor_number int NOT NULL,
--  nb_of_employees int,
    manager_ssn bigint NOT NULL
);

CREATE TABLE broker_table (
    phone bigint PRIMARY KEY,
    start_date date NOT NULL,
    end_date date,
    address text,
    commission int NOT NULL DEFAULT 3,
    name text NOT NULL
--  nb_of_customers_brought int
);

CREATE TABLE customer_table (
    ssn bigint PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone bigint NOT NULL,
--  age int,
    dob date NOT NULL,
    address text NOT NULL,
    b_phone bigint,
    e_ssn bigint NOT NULL DEFAULT 1243,
    date_of_assignment date NOT NULL DEFAULT CURRENT_DATE 
);

CREATE TABLE family_member_table (
    c_ssn bigint NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    PRIMARY KEY (c_ssn, first_name, last_name),
    -- age int,
    dob date NOT NULL,
    relation text NOT NULL
);

CREATE TABLE lab (
    id bigint PRIMARY KEY,
    name text NOT NULL,
    representative text NOT NULL,
    phone bigint NOT NULL
);

CREATE TABLE hospital (
    id bigint PRIMARY KEY,
    phone bigint NOT NULL,
    name text NOT NULL,
    representative text NOT NULL,
    location text NOT NULL
);

CREATE TABLE insurance_plan (
    id int PRIMARY KEY,
    type text NOT NULL,
    name text NOT NULL,
    description text,
    price int NOT NULL,
    start_age int NOT NULL,
    end_age int NOT NULL,
    percentage_paid int NOT NULL,
    time_limit int NOT NULL,
    financial_limit bigint NOT NULL
);

CREATE TABLE doctor_table (
    phone bigint PRIMARY KEY,
    specialization text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    -- years_worked int,
    work_start date NOT NULL,
    nb_of_malpractices int NOT NULL DEFAULT 0
);

CREATE TABLE bill (
    id bigint PRIMARY KEY,
    total_amount bigint NOT NULL,
    date date NOT NULL DEFAULT CURRENT_DATE,
    days_to_pay int NOT NULL
    -- still_due numeric 
);

CREATE TABLE pays (
    c_ssn bigint NOT NULL,
    b_id bigint NOT NULL,
    date date NOT NULL DEFAULT CURRENT_DATE,
    amount_paid numeric NOT NULL,
    PRIMARY KEY (c_ssn, b_id, date)
);

CREATE TABLE insures (
    plan_identifier bigint NOT NULL,
    c_ssn bigint NOT NULL,
    nb_of_plans int,
    date_activated date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (plan_identifier, c_ssn, date_activated),
    billed boolean NOT NULL DEFAULT FALSE
);

CREATE TABLE covers (
    plan_identifier bigint NOT NULL,
    h_id bigint NOT NULL,
    PRIMARY KEY (plan_identifier, h_id)
);

CREATE TABLE works_in (
    d_phone bigint NOT NULL,
    h_id bigint NOT NULL,
    PRIMARY KEY (d_phone, h_id)
);

CREATE TABLE accepts (
    plan_identifier bigint NOT NULL,
    lab_id bigint NOT NULL,
    PRIMARY KEY (plan_identifier, lab_id)
);

CREATE TABLE tests (
    c_ssn bigint NOT NULL,
    lab_id bigint NOT NULL,
    description text,
    price numeric NOT NULL,
    date date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (c_ssn, lab_id, date)
);

CREATE TABLE lab_location (
    lab_id bigint NOT NULL,
    location text NOT NULL,
    PRIMARY KEY (lab_id, location)
);

CREATE TABLE customer_diseases (
    c_ssn bigint NOT NULL,
    chronic_disease text NOT NULL,
    PRIMARY KEY (c_ssn, chronic_disease)
);

CREATE TABLE customer_exclusions (
    c_ssn bigint NOT NULL,
    exclusion text NOT NULL,
    PRIMARY KEY (c_ssn, exclusion)
);

CREATE TABLE f_member_diseases (
    c_ssn bigint NOT NULL,
    f_first_name text NOT NULL,
    f_last_name text NOT NULL,
    chronic_disease text NOT NULL,
    PRIMARY KEY (c_ssn, f_first_name, f_last_name, chronic_disease)
);

CREATE TABLE operates_on (
    d_phone bigint NOT NULL,
    h_id bigint NOT NULL,
    c_ssn bigint NOT NULL,
    date date NOT NULL DEFAULT CURRENT_DATE,
    description text,
    price numeric NOT NULL,
    PRIMARY KEY (d_phone, h_id, c_ssn, date, description)
);

---------------- VIEWs

CREATE VIEW family_member(c_ssn, first_name, last_name, age, relation) AS
SELECT c_ssn, first_name, last_name, floor((CURRENT_DATE - dob)/365.242189), relation
FROM family_member_table;

CREATE VIEW doctor(phone, specialization, first_name, last_name, years_worked, nb_of_malpractices) AS
SELECT phone, specialization, first_name, last_name, floor((CURRENT_DATE - work_start)/365.242189), nb_of_malpractices
FROM doctor_table;

CREATE VIEW customer(ssn, first_name, last_name, phone, age, address, b_phone, e_ssn, date_of_assignment) AS
SELECT ssn, first_name, last_name, phone, floor((CURRENT_DATE - dob)/365.242189), address, b_phone, e_ssn, date_of_assignment
FROM customer_table;

CREATE VIEW broker(phone, start_date, end_date, address, commission, name, nb_of_customers_brought) AS
SELECT b.phone, b.start_date, b.end_date, b.address, b.commission, b.name, count(c.ssn)
FROM broker_table b LEFT JOIN customer_table c ON b.phone = c.b_phone
GROUP BY b.phone;

CREATE VIEW department(name, extension, floor_number, nb_of_employees, manager_ssn) AS
SELECT d.name, d.extension, d.floor_number, count(e.ssn), d.manager_ssn
FROM department_table d
LEFT JOIN employee_table e ON d.name = e.d_name
GROUP BY d.name;

CREATE VIEW employee(ssn, first_name, last_name, phone, extension, date_hired, years_hired, address,
salary, age, su_ssn, d_name) AS
SELECT ssn, first_name, last_name, phone, extension, date_hired, floor((CURRENT_DATE - date_hired)/365.242189), address, salary, floor((CURRENT_DATE - dob)/365.242189), su_ssn, d_name
FROM employee_table;

CREATE VIEW bill_view (id, total_amount, date, days_to_pay, still_due) AS
SELECT b.id, b.total_amount, b.date, b.days_to_pay, COALESCE(b.total_amount - SUM(p.amount_paid), b.total_amount)
FROM bill b LEFT JOIN pays p ON b.id = p.b_id
GROUP BY b.id;

----------------- INSERTs

INSERT INTO department_table (name, extension, floor_number, manager_ssn)
VALUES
('Corporate', 101, 1, 123),
('Customer Service', 300, 3, 1243),
('Marketing', 100, 1, 1234),
('Sales', 200, 2, 1238),
('Human Resources', 400, 4, 1248),
('Administration', 500, 5, 1246),
('Claims', 600, 6, 1246),
('Finance', 600, 6, 1246),
('Legal', 600, 6, 1246),
('IT', 600, 6, 1246),
('Training', 600, 6, 1246);

INSERT INTO employee_table (ssn, first_name, last_name, phone, extension, date_hired, address, salary, dob, su_ssn, d_name)
VALUES
(123, 'Steward', 'Noble', 02000, 100, '2018-01-01', 'Matn', 100000, '1990-01-01',NULL,'Corporate'),
(1243, 'Melissa', 'Black', 03010, 315, '2012-03-28', 'Matn', 61000, '1984-06-23', NULL, 'Customer Service'),
(1234, 'John', 'Smith', 03001, 111, '2018-05-15', 'Matn', 60000, '1987-03-27', NULL, 'Marketing'),
(1235, 'Sarah', 'Johnson', 03002, 112, '2019-02-20', 'Beirut', 55000, '1993-01-23', '1234', 'Marketing'),
(1236, 'Michael', 'Davis', 03003, 113, '2020-08-10', 'Beirut', 59000, '1989-11-17', '1234', 'Marketing'),
(1237, 'Emily', 'White', 03004, 211, '2017-11-03', 'Hamra', 57000, '1991-09-13', '1238', 'Sales'),
(1238, 'David', 'Anderson', 03005, 212, '2021-04-25', 'Beirut', 61000, '1987-08-26', NULL, 'Sales'),
(1239, 'Lisa', 'Miller', 03006, 311, '2016-09-12', 'Hamra', 56000, '1992-04-23', '1243', 'Customer Service'),
(1240, 'Andrew', 'Martinez', 03007, 312, '2015-01-30', 'Hamra', 60000, '1988-05-09', '1243', 'Customer Service'),
(1241, 'Jessica', 'Johnson', 03008, 313, '2014-07-19', 'Dekwaneh', 54000, '1994-02-21', '1243', 'Customer Service'),
(1242, 'William', 'Brown', 03009, 314, '2013-12-01', 'Dekwaneh', 53000, '1995-07-08', '1243', 'Customer Service'),
(1244, 'Daniel', 'Wilson', 03011, 316, '2011-08-05', 'Matn', 60000, '1988-04-30', '1243', 'Customer Service'),
(1245, 'Karen', 'Lee', 03012, 411, '2010-05-20', 'Sayda', 55000, '1990-07-13', '1248', 'Human Resources'),
(1246, 'Richard', 'Baker', 03013, 512, '2009-02-15', 'Sayda', 70000, '1989-09-21', NULL, 'Human Resources'),
(1247, 'Elise', 'Turner', 03014, 413, '2008-06-10', 'Jbeil', 57000, '1988-08-06', '1246', 'Administration'),
(1248, 'James', 'Rodriguez', 03015, 414, '2007-04-05', 'Jbeil', 61000, '1987-04-08', NULL, 'Human Resources');

INSERT INTO broker_table (phone, start_date, end_date, address, commission, name)
VALUES
(04001, '2022-03-15', NULL, 'Jbeil', 5, 'Alice Reynolds'),
(04002, '2020-04-23', NULL, 'Matn', 6, 'Samuel Mitchell'),
(04003, '2021-12-19', NULL, 'Hamra', 5, 'Olivia Anderson'),
(04004, '2023-01-26', NULL, 'Hamra', 4, 'Ethan Walker'),
(04005, '2023-02-03', NULL, 'Jbeil', 4, 'Sophia Baker'),
(04006, '2021-09-12', NULL, 'Mansourieh', 5, 'Liam Turner'),
(04007, '2020-11-30', NULL, 'Beirut', 5, 'Ava Harris'),
(04008, '2023-01-23', '2023-03-15', 'Ashrafieh', 3, 'Mason Jenkins'),
(04009, '2021-03-14', '2023-05-06', 'Jbeil', 4, 'Isabella Martin'),
(04010, '2021-05-17', NULL, 'Jbeil', 4, 'Noah Foster');

INSERT INTO customer_table (ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn, date_of_assignment)
VALUES
(0001, 'Mike', 'Madison', 04123, '1980-04-22', 'Ashrafieh', 04001, 1239, '2023-04-05'),
(0002, 'William', 'Johnson', 04132, '1983-11-25', 'Saida', 04001, 1239, '2023-03-03'),
(0003, 'Sarah', 'Brown', 04152, '1991-03-23', 'Hamra', 04003, 1239, '2023-01-02'),
(0004, 'Ashley', 'Taylor', 04133, '1999-10-17', 'Jounie', 04004, 1239, '2023-06-07'),
(0005, 'Thomas', 'Wilson', 04555, '1999-09-08', 'Jbeil', NULL, 1239, '2023-04-20'),
(0006, 'Anthony', 'Anderson', 04765, '2006-07-07', 'Faraya', NULL, 1240, '2023-02-14'),
(0007, 'Lucas', 'Martinez', 04122, '1957-03-25', 'Zahle', 04002, 1240, '2023-10-10'),
(0008, 'Susan', 'Wilson', 04999, '1985-07-21', 'Mansourieh', 04002, 1242, '2023-09-01'),
(0009, 'Lea', 'Marris', 04545, '1999-11-07', 'Matn', 04002, 1243, '2023-08-01'),
(0010, 'Laura', 'Jackson', 04677, '1963-08-05', 'Sawfar', 04002, 1243, '2023-07-01');

INSERT INTO family_member_table (c_ssn, first_name, last_name, dob, relation)
VALUES
(0001, 'Sophia', 'Madison', '1981-08-30', 'Wife'),
(0001, 'Jack', 'Madison', '2008-08-29', 'Son'),
(0001, 'Ethan', 'Madison', '2010-11-08', 'Son'),
(0001, 'Olivia', 'Madison', '2013-07-25', 'Daughter'),
(0010, 'Grace', 'Jackson', '1965-03-30', 'Sister'),
(0010, 'Eva', 'Jackson', '1940-08-27', 'Mother'),
(0010, 'Linda', 'Jackson', '1973-10-20', 'Sister'),
(0010, 'Liam', 'Jackson', '1991-04-19', 'Son'),
(0008, 'Oliver', 'Wilson', '1986-06-21', 'Husband'),
(0008, 'Emma', 'Wilson', '2006-07-22', 'Daughter'),
(0008, 'James', 'Wilson', '2010-10-04', 'Son');

INSERT INTO lab (id, name, representative, phone)
VALUES
(101,'ABC', 'Ziad Shami', 04111),
(102,'Biotech', 'Ali Rizk', 04212),
(103,'Precision', 'Karim Chahine', 04333),
(104,'PHD', 'Anthony Karam', 04799),
(105,'NovaBio', 'Jad Chehab', 04999),
(106,'VitalScan', 'Issa Yasser', 04919),
(107,'Quantum', 'Hasan Moukallid', 04500),
(108,'GeneSys', 'Ahmad Hajj', 04002),
(109,'ALC', 'Sara Yaser', 04888),
(110,'MIC', 'Mohamad Ahmad', 04900);

INSERT INTO hospital (id, phone, name, representative, location)
VALUES
(201, 04541, 'CMC', 'Sami Ahmad', 'Hamra'),
(202, 04000, 'AUBMC', 'Hussein Madi', 'Hamra'),
(203, 04002, 'BAUHC', 'Joe Noura', 'Beirut'),
(204, 04909, 'RIZK', 'Karam Saaed', 'Ashrafieh'),
(205, 04155, 'BELLVUE', 'Jad Chahine', 'Beirut'),
(206, 04330, 'EVERGREEN', 'Omar Khalil', 'Beirut'),
(207, 04444, 'LIBERTY', 'Celena Younes', 'Saida'),
(208, 04997, 'ANC', 'Ahmad Hashem', 'Mansourie'),
(209, 04998, 'HUH', 'Karim Abi Karam', 'Hazmieh'),
(210, 04344, 'MUH', 'Ahmad Agha', 'Matn');

INSERT INTO insurance_plan (id, type, name, description, price, start_age, end_age, percentage_paid, time_limit, financial_limit)
VALUES
(1, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 500, 5, 20, 100, 365, 1000000),
(2, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 550, 21, 40, 100, 365, 1000000),
(3, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 600, 41, 60, 100, 365, 1000000),
(4, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 700, 61, 70, 100, 365, 1000000),
(5, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 800, 71, 80, 100, 365, 1000000),
(6, 'in+out', 'Everything covered', 'Will cover all medical bills, hospital and labs', 900, 81, 90, 100, 365, 1000000),
(7, 'in', 'Hospital only', 'Will only cover hospital bills related to operations', 200, 5, 30, 100, 365, 750000),
(8, 'in', 'Hospital only', 'Will only cover hospital bills related to operations', 250, 31, 60, 100, 365, 750000),
(9, 'in', 'Hospital only', 'Will only cover hospital bills related to operations', 300, 61, 70, 100, 365, 750000),
(10, 'in', 'Hospital only', 'Will only cover hospital bills related to operations', 350, 71, 80, 100, 365, 750000),
(11, 'in', 'Hospital only', 'Will only cover hospital bills related to operations', 450, 81, 90, 100, 365, 750000);

INSERT INTO doctor_table (phone, specialization, first_name, last_name, work_start, nb_of_malpractices)
VALUES
('05112', 'Radiology', 'Emily', 'Tuner', '2018-01-01', 1),
('05661', 'Dermatology', 'Laura', 'Mitchell', '2013-07-09', 4),
('05221', 'Oncologist', 'Victoria', 'White', '2003-01-05', 2),
('05665', 'Cardiologist', 'Gabriel', 'Garcia', '2010-08-01', 1),
('05881', 'Neurologist', 'Alexander', 'Johnson', '2021-06-01', 2),
('05990', 'Pediatrician', 'Christopher', 'William', '2022-09-01', 0),
('05771', 'Gastroenterologist', 'Isabelle', 'Charter', '2018-01-01', 2),
('05889', 'Pulmonologist', 'Willian', 'Lee', '2021-05-01', 0),
('05991', 'Urologist', 'Lucas', 'Rodriguez', '2019-07-01', 0),
('05118', 'Nephrologist', 'Susan', 'Foster', '2015-08-01', 1);

INSERT INTO bill (id, total_amount, date, days_to_pay)
VALUES
(1, 550, '2020-01-15', 30),
(2, 550, '2021-01-15', 30),
(3, 550, '2022-01-15', 30),
(4, 550, '2023-01-15', 30),
(5, 200, '2023-05-23', 30),
(6, 1100, '2022-03-04', 30),
(7, 1100, '2023-03-04', 30),
(8, 200, '2023-07-30', 30),
(9, 2100, '2022-06-25', 30),
(10, 2100, '2023-10-10', 30);

INSERT INTO pays (c_ssn, b_id, date, amount_paid)
VALUES
(0002, 001, '2020-01-15', 550),
(0002, 002, '2021-01-15', 550),
(0002, 003, '2022-01-15', 550),
(0002, 004, '2023-01-15', 550),
(0006, 005, '2023-05-23', 100),
(0006, 005, '2023-06-04', 100),
(0001, 006, '2022-03-04', 700),
(0001, 006, '2022-03-24', 400),
(0001, 007, '2023-03-04', 700),
(0001, 007, '2023-03-21', 400),
(0005, 008, '2023-07-30', 200),
(0008, 009, '2022-06-25', 2100),
(0008, 010, '2023-10-10', 1100);

INSERT INTO insures (plan_identifier, c_ssn, date_activated, billed, nb_of_plans)
VALUES
(2, 0002, '2020-01-15', TRUE, 1),
(7, 0006, '2023-05-23', TRUE, 1),
(2, 0002, '2021-01-15', TRUE, 1),
(2, 0002, '2022-01-15', TRUE, 1),
(2, 0002, '2023-01-15', TRUE, 1),
(8, 0001, '2022-03-04', TRUE, 5),
(8, 0001, '2023-03-04', TRUE, 5),
(7, 0005, '2023-07-30', TRUE, 1),
(2, 0008, '2022-06-25', TRUE, 4),
(2, 0008, '2023-10-10', TRUE, 4);

INSERT INTO covers (plan_identifier, h_id)
VALUES
(1, 201),(1, 202),(1, 203),(1, 204),(1, 205),(1, 206),(1, 207),(1, 208),(1, 209),(1, 210),
(2, 201),(2, 202),(2, 203),(2, 204),(2, 205),(2, 206),(2, 207),(2, 208),(2, 209),(2, 210),
(3, 201),(3, 202),(3, 203),(3, 204),(3, 205),(3, 206),(3, 207),(3, 208),(3, 209),(3, 210),
(4, 201),(4, 202),(4, 203),(4, 204),(4, 205),(4, 206),(4, 207),(4, 208),(4, 209),(4, 210),
(5, 201),(5, 202),(5, 203),(5, 204),(5, 205),(5, 206),(5, 207),(5, 208),(5, 209),(5, 210),
(6, 201),(6, 202),(6, 203),(6, 204),(6, 205),(6, 206),(6, 207),(6, 208),(6, 209),(6, 210),
(7, 203),(7, 204),(7, 205),(7, 206),(7, 207),(7, 208),(7, 209),(7, 210),
(8, 203),(8, 204),(8, 205),(8, 206),(8, 207),(8, 208),(8, 209),(8, 210),
(9, 203),(9, 204),(9, 205),(9, 206),(9, 207),(9, 208),(9, 209),(9, 210),
(10, 203),(10, 204),(10, 205),(10, 206),(10, 207),(10, 208),(10, 209),(10, 210),
(11, 203),(11, 204),(11, 205),(11, 206),(11, 207),(11, 208),(11, 209),(11, 210);


INSERT INTO works_in (d_phone, h_id)
VALUES
(05112, 0201),
(05661, 0202),
(05221, 0203),
(05665, 0204),
(05881, 0205),
(05990, 0206),
(05771, 0207),
(05889, 0208),
(05991, 0209),
(05118, 0210);

INSERT INTO accepts (plan_identifier, lab_id)
VALUES
(1, 101),(1, 102),(1, 103),(1, 104),(1, 105),(1, 106),(1, 107),(1, 108),(1, 109),(1, 110),
(2, 101),(2, 102),(2, 103),(2, 104),(2, 105),(2, 106),(2, 107),(2, 108),(2, 109),(2, 110),
(3, 101),(3, 102),(3, 103),(3, 104),(3, 105),(3, 106),(3, 107),(3, 108),(3, 109),(3, 110),
(4, 101),(4, 102),(4, 103),(4, 104),(4, 105),(4, 106),(4, 107),(4, 108),(4, 109),(4, 110),
(5, 101),(5, 102),(5, 103),(5, 104),(5, 105),(5, 106),(5, 107),(5, 108),(5, 109),(5, 110),
(6, 101),(6, 102),(6, 103),(6, 104),(6, 105),(6, 106),(6, 107),(6, 108),(6, 109),(6, 110);

INSERT INTO tests (c_ssn, lab_id, description, price, date)
VALUES
(0001, 0101, 'Blood Test', 10, '2023-09-04'),
(0002, 0102, 'Urine Analysis', 15, '2023-09-06'),
(0003, 0103, 'X-Ray', 30, '2023-09-16'),
(0004, 0104, 'MRI Scan', 65, '2023-09-23'),
(0005, 0105, 'Blood Test', 10, '2023-09-29'),
(0006, 0106, 'Ultrasound', 45, '2023-10-03'),
(0007, 0107, 'Urine Analysis', 15, '2023-10-05'),
(0008, 0108, 'X-ray', 30, '2023-10-09'),
(0009, 0109, 'Blood Test', 10, '2023-10-13'),
(0010, 0110, 'MRI Scan', 65, '2023-10-17'),
(0001, 0101, 'X-Ray', 30, '2023-10-18'),
(0001, 0102, 'Urine Analysis', 15, '2023-10-24'),
(0003, 0103, 'Blood Test', 10, '2023-10-30'),
(0004, 0104, 'MRI Scan', 65, '2023-01-05'),
(0005, 0105, 'Ultrasound', 45, '2023-01-11'),
(0006, 0106, 'X-Ray', 30, '2023-01-17'),
(0002, 0107, 'Urine Analysis', 15, '2023-01-23'),
(0008, 0108, 'Blood Test', 10, '2023-01-29'),
(0009, 0109, 'MRI Scan', 65, '2023-02-04'),
(0004, 0110, 'Ultrasound', 45, '2023-02-10');

INSERT INTO lab_location (lab_id, location)
VALUES
(0101, 'Hamra'),
(0101, 'Jbeil'),
(0102, 'Hamra'),
(0103, 'Beirut'),
(0104, 'Ashrafieh'),
(0105, 'Ashrafieh'),
(0105, 'Saida'),
(0106, 'Saida'),
(0107, 'Hamra'),
(0108, 'Dekwaneh'),
(0108, 'Mansourieh'),
(0109, 'Dekwaneh'),
(0110, 'Hamra');

INSERT INTO customer_diseases (c_ssn, chronic_disease)
VALUES
(0007, 'Diabetes'),
(0009, 'Diabetes'),
(0004, 'Diabetes'),
(0007, 'Hypertension'),
(0007, 'Asthma'),
(0007, 'Arthritis'),
(0002, 'Asthma'),
(0004, 'Asthma'),
(0005, 'Epilepsy'),
(0005, 'Cancer'),
(0007, 'Alzheimers'),
(0010, 'Alzheimers');

INSERT INTO customer_exclusions (c_ssn, exclusion)
VALUES
(001, 'Dental care'),
(002, 'Dental care'),
(003, 'Dental care'),
(005, 'Dental care'),
(008, 'Dental care'),
(001, 'Cosmetic surgery'),
(002, 'Cosmetic surgery'),
(003, 'Cosmetic surgery'),
(005, 'Cosmetic surgery'),
(008, 'Cosmetic surgery'),
(010, 'Cosmetic surgery');

INSERT INTO f_member_diseases (c_ssn, f_first_name, f_last_name, chronic_disease)
VALUES
(0010, 'Grace', 'Jackson', 'Diabetes'),
(0010, 'Grace', 'Jackson', 'Alzheimers'),
(0010, 'Grace', 'Jackson', 'Hypertension'),
(0001, 'Jack', 'Madison', 'Asthma'),
(0008, 'Oliver', 'Wilson', 'Asthma'),
(0008, 'Oliver', 'Wilson', 'Alzheimers'),
(0008, 'Oliver', 'Wilson', 'Hypertension'),
(0008, 'Oliver', 'Wilson', 'Diabetes'),
(0010, 'Liam', 'Jackson', 'Asthma'),
(0001, 'Ethan', 'Madison', 'Asthma');

INSERT INTO operates_on (d_phone, h_id, c_ssn, date, description, price)
VALUES
(05881, 0205, 0001, '2022-03-12', 'Brain Surgery', 40000),
(05881, 0205, 0001, '2022-05-23', 'Brain Surgery', 32000),
(05221, 0203, 0004, '2022-12-21', 'Appendectomy', 10000),
(05991, 0209, 0004, '2022-06-30', 'Endoscopy', 3000),
(05881, 0208, 0005, '2021-04-21', 'Brain Surgery', 35000),
(05991, 0209, 0007, '2022-03-24', 'Endoscopy', 3000),
(05991, 0210, 0003, '2023-02-18', 'General Surgery', 8000),
(05221, 0203, 0003, '2023-06-04', 'Appendectomy', 10000),
(05771, 0207, 0010, '2023-01-31', 'General Surgery', 8000),
(05881, 0201, 0006, '2023-09-24', 'Brain Surgery', 30000),
(05112, 0201, 0001, '2023-05-15', 'General Surgery', 8000);


------------------ ALTERs

ALTER TABLE employee_table ADD CONSTRAINT fk_department
FOREIGN KEY (d_name) REFERENCES department_table (name)
ON DELETE SET DEFAULT ON UPDATE CASCADE;

ALTER TABLE department_table ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_ssn) REFERENCES employee_table (ssn)
ON DELETE SET DEFAULT ON UPDATE CASCADE;

ALTER TABLE employee_table ADD CONSTRAINT fk_supervisor
FOREIGN KEY (su_ssn) REFERENCES employee_table (ssn)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE employee_table ALTER COLUMN d_name SET NOT NULL;

ALTER TABLE employee_table ALTER COLUMN d_name SET DEFAULT 'Corporate';

ALTER TABLE customer_table ADD CONSTRAINT fk_broker
FOREIGN KEY (b_phone) REFERENCES broker_table (phone)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE customer_table ADD CONSTRAINT fk_employee
FOREIGN KEY (e_ssn) REFERENCES employee_table (ssn)
ON DELETE SET DEFAULT ON UPDATE CASCADE;

ALTER TABLE family_member_table ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pays ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pays ADD CONSTRAINT fk_bill
FOREIGN KEY (b_id) REFERENCES bill (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE insures ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE insures ADD CONSTRAINT fk_plan
FOREIGN KEY (plan_identifier) REFERENCES insurance_plan (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE covers ADD CONSTRAINT fk_plan
FOREIGN KEY (plan_identifier) REFERENCES insurance_plan (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE covers ADD CONSTRAINT fk_hospital
FOREIGN KEY (h_id) REFERENCES hospital (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE works_in ADD CONSTRAINT fk_doctor
FOREIGN KEY (d_phone) REFERENCES doctor_table (phone)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE works_in ADD CONSTRAINT fk_hospital
FOREIGN KEY (h_id) REFERENCES hospital (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE accepts ADD CONSTRAINT fk_plan
FOREIGN KEY (plan_identifier) REFERENCES insurance_plan (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE accepts ADD CONSTRAINT fk_lab
FOREIGN KEY (lab_id) REFERENCES lab (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tests ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tests ADD CONSTRAINT fk_lab
FOREIGN KEY (lab_id) REFERENCES lab (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE lab_location ADD CONSTRAINT fk_lab
FOREIGN KEY (lab_id) REFERENCES lab (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE customer_diseases ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE customer_exclusions ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE f_member_diseases ADD CONSTRAINT fk_family_member
FOREIGN KEY (c_ssn, f_first_name, f_last_name) REFERENCES family_member_table (c_ssn, first_name, last_name)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE operates_on ADD CONSTRAINT fk_doctor
FOREIGN KEY (d_phone) REFERENCES doctor_table (phone)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE operates_on ADD CONSTRAINT fk_hospital
FOREIGN KEY (h_id) REFERENCES hospital (id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE operates_on ADD CONSTRAINT fk_customer
FOREIGN KEY (c_ssn) REFERENCES customer_table (ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE employee_table ADD CONSTRAINT check_salary
CHECK (salary > 0);

ALTER TABLE employee_table ADD CONSTRAINT check_extension
CHECK (extension > 0);

ALTER TABLE employee_table ADD CONSTRAINT check_date_hired
CHECK (date_hired <= CURRENT_DATE);

ALTER TABLE employee_table ADD CONSTRAINT check_dob
CHECK (dob <= CURRENT_DATE);

ALTER TABLE employee_table ADD CONSTRAINT check_ssn
CHECK (ssn > 0);

ALTER TABLE employee_table ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE department_table ADD CONSTRAINT check_extension
CHECK (extension > 0);

ALTER TABLE broker_table ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE broker_table ADD CONSTRAINT check_commission
CHECK (commission > 0 AND commission < 20);

ALTER TABLE broker_table ADD CONSTRAINT check_start_date
CHECK (start_date <= CURRENT_DATE);

ALTER TABLE customer_table ADD CONSTRAINT check_ssn
CHECK (ssn > 0);

ALTER TABLE customer_table ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE customer_table ADD CONSTRAINT check_dob
CHECK (dob <= CURRENT_DATE);

ALTER TABLE family_member_table ADD CONSTRAINT check_dob
CHECK (dob <= CURRENT_DATE);

ALTER TABLE lab ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE lab ADD CONSTRAINT check_id 
CHECK (id > 0);

ALTER TABLE hospital ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE hospital ADD CONSTRAINT check_id
CHECK (id > 0);

ALTER TABLE insurance_plan ADD CONSTRAINT check_price
CHECK (price > 0);

ALTER TABLE insurance_plan ADD CONSTRAINT check_start_age
CHECK (start_age > 0);

ALTER TABLE insurance_plan ADD CONSTRAINT check_end_age
CHECK (end_age > 0 AND end_age > start_age);

ALTER TABLE insurance_plan ADD CONSTRAINT check_percentage_paid
CHECK (percentage_paid > 0 AND percentage_paid <= 100);

ALTER TABLE insurance_plan ADD CONSTRAINT check_time_limit
CHECK (time_limit > 0);

ALTER TABLE insurance_plan ADD CONSTRAINT check_financial_limit
CHECK (financial_limit > 0);

ALTER TABLE insurance_plan ADD CONSTRAINT check_identifier2
CHECK (id > 0);

ALTER TABLE doctor_table ADD CONSTRAINT check_phone
CHECK (phone > 0);

ALTER TABLE doctor_table ADD CONSTRAINT check_work_start
CHECK (work_start <= CURRENT_DATE);

ALTER TABLE doctor_table ADD CONSTRAINT check_nb_of_malpractices
CHECK (nb_of_malpractices >= 0);

ALTER TABLE bill ADD CONSTRAINT check_total_amount
CHECK (total_amount > 0);

ALTER TABLE bill ADD CONSTRAINT check_date
CHECK (date <= CURRENT_DATE);

ALTER TABLE bill ADD CONSTRAINT check_days_to_pay
CHECK (days_to_pay > 0);

ALTER TABLE pays ADD CONSTRAINT check_date
CHECK (date <= CURRENT_DATE);

ALTER TABLE pays ADD CONSTRAINT check_amount_paid
CHECK (amount_paid > 0);

ALTER TABLE insures ADD CONSTRAINT check_date_activated
CHECK (date_activated <= CURRENT_DATE);

ALTER TABLE tests ADD CONSTRAINT check_date
CHECK (date <= CURRENT_DATE);

ALTER TABLE tests ADD CONSTRAINT check_price
CHECK (price > 0);

ALTER TABLE operates_on ADD CONSTRAINT check_date
CHECK (date <= CURRENT_DATE);

ALTER TABLE operates_on ADD CONSTRAINT check_price
CHECK (price > 0);


---------- TRIGGERs

CREATE OR REPLACE function check_coverage_function()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
IF new.id NOT IN (SELECT DISTINCT plan_identifier FROM covers) THEN 
RAISE NOTICE 'Warning: The insurance plan with id % does not have corresponding coverage in the covers table.', NEW.id;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_coverage
BEFORE INSERT OR UPDATE ON insurance_plan
FOR EACH ROW 
EXECUTE FUNCTION check_coverage_function();


CREATE OR REPLACE function check_doctor_hospital()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
IF NEW.phone NOT IN (SELECT DISTINCT d_phone FROM works_in) THEN
RAISE NOTICE 'Doctor % % is not working in any hospital yet.', NEW.first_name, NEW.last_name;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_doctor_hospital_trigger
BEFORE INSERT OR UPDATE ON doctor_table
FOR EACH ROW
EXECUTE FUNCTION check_doctor_hospital();


CREATE OR REPLACE function check_hospital_doctors()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
IF NEW.id NOT IN (SELECT DISTINCT h_id FROM works_in) THEN
RAISE NOTICE 'Hospital with id % is not employing any doctors yet.', NEW.id;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_hospital_doctor_trigger
BEFORE INSERT OR UPDATE ON hospital
FOR EACH ROW
EXECUTE FUNCTION check_hospital_doctors();


CREATE OR REPLACE FUNCTION check_customer_insures()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
IF new.ssn NOT IN (SELECT DISTINCT c_ssn FROM insures) THEN
RAISE NOTICE 'Customer % % is not insured by a plan yet.', NEW.first_name, NEW.last_name;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_customer_insures_trigger
BEFORE INSERT OR UPDATE ON customer_table
FOR EACH ROW
EXECUTE FUNCTION check_customer_insures();


CREATE OR REPLACE FUNCTION check_customer_pays()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
IF new.ssn NOT IN (SELECT DISTINCT c_ssn FROM pays) THEN
RAISE NOTICE 'Customer % % has not paid any bills yet.', NEW.first_name, NEW.last_name;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_customer_pays_trigger
BEFORE INSERT OR UPDATE ON customer_table
FOR EACH ROW
EXECUTE FUNCTION check_customer_pays();


CREATE OR REPLACE FUNCTION check_bill_pays()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
IF new.id NOT IN (SELECT DISTINCT b_id FROM pays) THEN
RAISE NOTICE 'Bill with id % has not been paid yet.', NEW.id;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_bill_pays_trigger
BEFORE INSERT OR UPDATE ON bill
FOR EACH ROW
EXECUTE FUNCTION check_bill_pays();


CREATE OR REPLACE FUNCTION check_department_employees()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
IF new.name NOT IN (SELECT DISTINCT d_name FROM employee_table) THEN
RAISE NOTICE 'Department % has no employees yet.', NEW.name;
END IF;
RETURN NEW;
END;$$;

CREATE TRIGGER check_department_employees_trigger
BEFORE INSERT OR UPDATE ON department_table
FOR EACH ROW
EXECUTE FUNCTION check_department_employees();

---------------- FUNCTIONs

CREATE OR REPLACE FUNCTION insert_customer(ssn bigint,first_name text,last_name text,phone bigint,dob date,address text,b_phone bigint,e_ssn bigint)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
-- check if ssn already exists
IF (SELECT COUNT(*) FROM customer_table WHERE ssn = ssn) > 0 THEN
RAISE NOTICE 'Customer with ssn % already exists.', ssn;
RETURN;
END IF;
-- check if phone already exists
IF (SELECT COUNT(*) FROM customer_table WHERE phone = phone) > 0 THEN
RAISE NOTICE 'Customer with phone % already exists.', phone;
RETURN;
END IF;
INSERT INTO customer_table (ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn)
VALUES (ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn);
RAISE NOTICE 'Customer % % inserted successfully.', first_name, last_name;
END;$$;

CREATE OR REPLACE FUNCTION insert_family_member(c_ssn bigint,first_name text,last_name text,dob date,relation text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN

-- check if customer exists
IF (SELECT COUNT(*) FROM customer_table WHERE ssn = c_ssn) = 0 THEN
RAISE NOTICE 'Customer with ssn % does not exist.', c_ssn;
RETURN;
END IF;

-- check if family member already exists
IF (SELECT COUNT(*) FROM family_member_table WHERE c_ssn = c_ssn AND first_name = first_name AND last_name = last_name) > 0 THEN
RAISE NOTICE 'Family member % % already exists.', first_name, last_name;
RETURN;
END IF;
INSERT INTO family_member_table (c_ssn, first_name, last_name, dob, relation)
VALUES (c_ssn, first_name, last_name, dob, relation);
RAISE NOTICE 'Family member % % inserted successfully.', first_name, last_name;
END;$$;


CREATE OR REPLACE FUNCTION insure_customer(customer_ssn bigint, plan_type text, amount numeric)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
total_plans int;
total_amount numeric;
sum1 numeric;
sum2 numeric;
plan_iden2 int;
next_id int;
BEGIN

-- check if customer exists
IF (SELECT COUNT(*) FROM customer_table WHERE ssn = customer_ssn) = 0 THEN
RAISE NOTICE 'Customer with ssn % does not exist.', customer_ssn;
RAISE NOTICE 'Error';
RETURN;
END IF;

--check type
IF plan_type NOT IN ('in+out', 'in') THEN
RAISE NOTICE 'Plan type must be either in+out or in.';
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if amount is greater than 0
IF amount <= 0 THEN
RAISE NOTICE 'Amount must be greater than 0.';
RAISE NOTICE 'Error';
RETURN;
END IF;

-- get unique identifier and price of plan
SELECT id, price INTO plan_iden2, sum1 FROM insurance_plan p, customer c
WHERE (c.age BETWEEN p.start_age AND p.end_age) 
AND c.ssn=customer_ssn AND p.type=plan_type;

-- get number of plans
SELECT COUNT(*)+1 INTO total_plans
FROM family_member_table
WHERE c_ssn = customer_ssn;


--now need to get the price for the family members
SELECT COALESCE(SUM(price),0) INTO sum2
FROM insurance_plan p, family_member f
WHERE (f.age BETWEEN p.start_age AND p.end_age)
AND f.c_ssn = customer_ssn AND p.type=plan_type;

-- now put in total amount the addition of sum1 and sum2
total_amount := sum1 + sum2;

-- check if amount is greater than total amount
IF amount > total_amount THEN
RAISE NOTICE 'Amount is greater than total amount, please pay the exact amount or less.';
RAISE NOTICE 'Error';
RETURN;
END IF;


--insert in the table
INSERT INTO insures (plan_identifier, c_ssn, nb_of_plans)
VALUES (plan_iden2, customer_ssn, total_plans);


-- now insert into bill and set id to be the next value in sequence
SELECT MAX(id)+1 INTO next_id FROM bill;
INSERT INTO bill (id, total_amount, date, days_to_pay)
VALUES (next_id, total_amount, CURRENT_DATE, 30);

-- now update that the customer was billed for this plan
UPDATE insures SET billed = TRUE
WHERE plan_identifier = plan_iden2 AND c_ssn = customer_ssn AND date_activated=CURRENT_DATE;

-- now insert into pays
INSERT INTO pays (c_ssn, b_id, date, amount_paid)
VALUES (customer_ssn, next_id, CURRENT_DATE, amount);

RAISE NOTICE 'Customer with ssn % insured successfully, bill id is %', customer_ssn, next_id;
RAISE NOTICE 'Success';
END;$$;


CREATE OR REPLACE FUNCTION pay_amount(customer_ssn bigint, bill_id bigint, amount numeric)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    amount_left numeric;
BEGIN
-- check if this bill belongs to this customer
IF (SELECT COUNT(*) FROM pays WHERE c_ssn = customer_ssn AND b_id = bill_id) = 0 THEN
RAISE NOTICE 'Bill with id % does not belong to customer with ssn %.', bill_id, customer_ssn;
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if customer still has to pay for this bill
SELECT still_due INTO amount_left
FROM bill_view WHERE id=bill_id;

IF amount_left = 0 THEN
RAISE NOTICE 'Customer with ssn % has already paid this bill.', customer_ssn;
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if amount is greater than amount left
IF amount > amount_left THEN
RAISE NOTICE 'Amount paid is greater than amount left to pay, please pay the exact amount or less.';
RAISE NOTICE 'Error';
RETURN;
END IF;

-- now insert into pays
INSERT INTO pays (c_ssn, b_id, date, amount_paid)
VALUES (customer_ssn, bill_id, CURRENT_DATE, amount);

RAISE NOTICE 'Customer with ssn % paid successfully. Amount left to pay is %.', customer_ssn, amount_left-amount;
RAISE NOTICE 'Success';
END;$$;


CREATE OR REPLACE FUNCTION operate_on_customer(customer_ssn bigint, doctor_phone bigint, hospital_id int, date date, description text, price numeric)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
-- check if customer exists
IF (SELECT COUNT(*) FROM customer_table WHERE ssn = customer_ssn) = 0 THEN
RAISE NOTICE 'Customer with ssn % does not exist.', customer_ssn;
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if doctor exists
IF (SELECT COUNT(*) FROM doctor_table WHERE phone = doctor_phone) = 0 THEN
RAISE NOTICE 'Doctor with phone % does not exist.', doctor_phone;
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if hospital exists
IF (SELECT COUNT(*) FROM hospital WHERE id = hospital_id) = 0 THEN
RAISE NOTICE 'Hospital with id % does not exist.', hospital_id;
RAISE NOTICE 'Error';
RETURN;
END IF;

INSERT INTO operates_on (d_phone, h_id, c_ssn, date, description, price)
VALUES (doctor_phone, hospital_id, customer_ssn, date, description, price);

RAISE NOTICE 'Customer with ssn % operated on successfully.', customer_ssn;
RAISE NOTICE 'Success';
END;$$;


CREATE OR REPLACE FUNCTION perform_test(customer_ssn bigint, lab_id int, description text, price numeric, date date)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
-- check if customer exists
IF (SELECT COUNT(*) FROM customer_table WHERE ssn = customer_ssn) = 0 THEN
RAISE NOTICE 'Customer with ssn % does not exist.', customer_ssn;
RAISE NOTICE 'Error';
RETURN;
END IF;

-- check if lab exists
IF (SELECT COUNT(*) FROM lab WHERE id = lab_id) = 0 THEN
RAISE NOTICE 'Lab with id % does not exist.', lab_id;
RAISE NOTICE 'Error';
RETURN;
END IF;

INSERT INTO tests (c_ssn, lab_id, description, price, date)
VALUES (customer_ssn, lab_id, description, price, date);

RAISE NOTICE 'Customer with ssn % tested successfully.', customer_ssn;
RAISE NOTICE 'Success';
END;$$;