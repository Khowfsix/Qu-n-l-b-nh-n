USE [QuanLiHoSoBenhAnNgoaiTru]
GO

CREATE TABLE Service
(
	serviceID VARCHAR(20),
	serviceName NVARCHAR(255),
	servicePrice INT,
	CONSTRAINT sPrice CHECK ([servicePrice] > 0),
	CONSTRAINT serviceKey PRIMARY KEY([ServiceID])
)
GO

CREATE TABLE Drug
(
	drugID VARCHAR(20),
	drugName NVARCHAR(255),
	unit NVARCHAR(255),
	drugPrice INT,
	CONSTRAINT dPrice CHECK ([drugPrice] > 0),
	CONSTRAINT drugKey PRIMARY KEY([drugID])
)
GO

CREATE TABLE Department
(
	departmentID VARCHAR(20),
	departmentName NVARCHAR(255),
	CONSTRAINT departmentKey PRIMARY KEY ([departmentID])
)

CREATE TABLE People
(
	peopleID VARCHAR(20),
	firstName NVARCHAR(255) NOT	NULL,
	middleName NVARCHAR(255),
	lastName NVARCHAR(255) NOT NULL,
	sex CHAR(1) NOT	NULL,
	birthDay DATE NOT NULL,
	address NVARCHAR(510) NOT NULL,
	phone VARCHAR(15) NOT NULL,
	cardID VARCHAR(15) NULL UNIQUE,
	
	CONSTRAINT peopleKey PRIMARY KEY([peopleID]),
	CONSTRAINT sexCheck CHECK([sex]='M' OR [sex]='F' OR [sex]='O'),
	--CONSTRAINT birthdayCheck CHECK ([birthDay] < getDate)
	CONSTRAINT chk_phone CHECK ([phone] not like '%[^0-9]%'),
)
GO

CREATE TABLE Patient
(
	patientID VARCHAR(20), --Khóa chính tương ứng lớp cha
	patientJob NVARCHAR(255),
	healthInsurance# VARCHAR(20),
	reason NVARCHAR(500),

	CONSTRAINT patientKey PRIMARY KEY([patientID]),
	CONSTRAINT people_patient FOREIGN KEY([patientID]) REFERENCES [dbo].[People]([peopleID]),
)
GO

CREATE TABLE Employee
(
	employeeID VARCHAR(20), --Khóa chính tương ứng lớp cha
	positon NVARCHAR(255),

	CONSTRAINT employeeKey PRIMARY KEY([employeeID]),
	CONSTRAINT people_employee FOREIGN KEY([employeeID]) REFERENCES [dbo].[People]([peopleID]),
)
GO

-- relationship Using
CREATE TABLE usingService
(
	patientID VARCHAR(20),
	serviceID VARCHAR(20),
	useday DATE,
	quantity TINYINT,

	CONSTRAINT usingPKEY PRIMARY KEY([patientID],[serviceID]),
	CONSTRAINT pUsingFKEY FOREIGN KEY([patientID]) REFERENCES [dbo].[Patient]([patientID]),
	CONSTRAINT sUsingFKEY FOREIGN KEY([serviceID]) REFERENCES [dbo].[Service]([serviceID]),
	CONSTRAINT using# CHECK ([quantity] > 0)
)
GO

-- relationship belong
ALTER TABLE [dbo].[Employee] ADD departmentID VARCHAR(20)
GO

ALTER TABLE [dbo].[Employee] 
ADD CONSTRAINT belongDepartment 
FOREIGN KEY (departmentID) REFERENCES [dbo].[Department]([departmentID])
GO

CREATE TABLE Receipt
(
	receiptID VARCHAR(20),
	receiptName NVARCHAR(255),

	CONSTRAINT receiptKey PRIMARY KEY([receiptID])
)
GO

CREATE TABLE Pay
(
	patientID VARCHAR(20),
	employeeID VARCHAR(20),
	receiptID VARCHAR(20),

	payDay DATE,
	payTotal INT,

	CONSTRAINT payKey PRIMARY KEY([patientID],[employeeID],[receiptID]),
	CONSTRAINT patientPay FOREIGN KEY([patientID]) REFERENCES [dbo].[Patient]([patientID]),
	CONSTRAINT employeePay FOREIGN KEY([employeeID]) REFERENCES [dbo].[Employee]([employeeID]),
	CONSTRAINT receiptPay FOREIGN KEY([receiptID]) REFERENCES [dbo].[Receipt]([receiptID]),
)