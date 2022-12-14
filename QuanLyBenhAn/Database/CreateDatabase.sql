USE [master];
GO

DROP DATABASE [QuanLiHoSoBenhAnNgoaiTru];
GO

CREATE DATABASE [QuanLiHoSoBenhAnNgoaiTru];
GO

USE [QuanLiHoSoBenhAnNgoaiTru];
GO

CREATE TABLE [Service]
(
    [serviceID] VARCHAR(20),
    [serviceName] NVARCHAR(255),
    [servicePrice] INT,
    [status] TINYINT NOT NULL,
    CONSTRAINT [sPrice] CHECK ([servicePrice] > 0),
    CONSTRAINT [serviceKey]
        PRIMARY KEY ([serviceID])
);
GO

CREATE TABLE [Medicine]
(
    [medicineID] VARCHAR(20),
    [medicineName] NVARCHAR(255),
    [unit] NVARCHAR(255),
    [medicinePrice] INT,
    [status] TINYINT NOT NULL,
    [createdAt] DATE NOT NULL,
    [updateAt] DATE NULL,
    CONSTRAINT [dPrice] CHECK ([medicinePrice] > 0),
    CONSTRAINT [drugKey]
        PRIMARY KEY ([medicineID])
);
GO

CREATE TABLE [Department]
(
    [departmentID] VARCHAR(20),
    [departmentName] NVARCHAR(255),
    [status] TINYINT NOT NULL,
    CONSTRAINT [departmentKey]
        PRIMARY KEY ([departmentID])
);
GO

CREATE TABLE [People]
(
    [peopleID] VARCHAR(20),
    [firstName] NVARCHAR(255) NOT NULL,
    [middleName] NVARCHAR(255),
    [lastName] NVARCHAR(255) NOT NULL,
    [sex] CHAR(1) NOT NULL,
    [birthDay] DATE NOT NULL,
    [address] NVARCHAR(510) NOT NULL,
    [phone] VARCHAR(15) NOT NULL,
    [cardID] VARCHAR(15) NULL
        UNIQUE,
    [role] TINYINT NOT NULL,
    [status] TINYINT NOT NULL,
    CONSTRAINT [peopleKey]
        PRIMARY KEY ([peopleID]),
    CONSTRAINT [sexCheck] CHECK ([sex] = 'M'
                                 OR [sex] = 'F'
                                 OR [sex] = 'O'
                                ),
    -- thân nhân = 0; bệnh nhân = 1; nhân viên = 2
    CONSTRAINT [role] CHECK ([role]
                             BETWEEN 0 AND 2
                            ),
    CONSTRAINT [birthdayCheck] CHECK ([birthDay] < GETDATE()),
    CONSTRAINT [chk_phone] CHECK ([phone] NOT LIKE '%[^0-9]%'),
);
GO

CREATE TABLE [Patient]
(
    [patientID] VARCHAR(20), --Khóa chính tương ứng lớp cha
    [patientJob] NVARCHAR(255),
    [healthInsurance#] VARCHAR(20),
    [reason] NVARCHAR(500),
    CONSTRAINT [patientKey]
        PRIMARY KEY ([patientID]),
    CONSTRAINT [people_patient]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[People] ([peopleID]) ON UPDATE CASCADE
);
GO

CREATE TABLE [Employee]
(
    [employeeID] VARCHAR(20), --Khóa chính tương ứng lớp cha
    [positon] NVARCHAR(255),
    CONSTRAINT [employeeKey]
        PRIMARY KEY ([employeeID]),
    CONSTRAINT [people_employee]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[People] ([peopleID]) ON UPDATE CASCADE,
);
GO

-- relationship Using
CREATE TABLE [usingService]
(
    [patientID] VARCHAR(20),
    [serviceID] VARCHAR(20),
    [useday] DATE,
    [quantity] TINYINT,
    [status] TINYINT NOT NULL,
    CONSTRAINT [usingPKEY]
        PRIMARY KEY (
                        [patientID],
                        [serviceID]
                    ),
    CONSTRAINT [pUsingFKEY]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[Patient] ([patientID]) ON UPDATE CASCADE,
    CONSTRAINT [sUsingFKEY]
        FOREIGN KEY ([serviceID])
        REFERENCES [dbo].[Service] ([serviceID]) ON UPDATE CASCADE,
    CONSTRAINT [using#] CHECK ([quantity] > 0)
);
GO

-- relationship belong
ALTER TABLE [dbo].[Employee] ADD [departmentID] VARCHAR(20);
GO

ALTER TABLE [dbo].[Employee]
ADD CONSTRAINT [belongDepartment]
    FOREIGN KEY ([departmentID])
    REFERENCES [dbo].[Department] ([departmentID]) ON DELETE SET NULL ON UPDATE CASCADE;
GO

CREATE TABLE [Receipt]
(
    [receiptID] VARCHAR(20),
    [receiptName] NVARCHAR(255),
    [status] TINYINT NOT NULL,
    CONSTRAINT [receiptKey]
        PRIMARY KEY ([receiptID])
);
GO

CREATE TABLE [Pay]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
    [receiptID] VARCHAR(20),
    [payTotal] INT,
    [status] TINYINT NOT NULL,
    [createdAt] DATE NOT NULL,
    CONSTRAINT [payKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [receiptID]
                    ),
    CONSTRAINT [patientPay]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[Patient] ([patientID]),
    CONSTRAINT [employeePay]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[Employee] ([employeeID]),
    CONSTRAINT [receiptPay]
        FOREIGN KEY ([receiptID])
        REFERENCES [dbo].[Receipt] ([receiptID])
);
GO

CREATE TABLE [Examination]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
    [examinateID] VARCHAR(20),
    [examinateDay] DATE NOT NULL,
    [height] FLOAT NOT NULL,
    [weight] FLOAT NOT NULL,
    [temperature] FLOAT NOT NULL,
    [breathing] INT NOT NULL,
    [symptom] NVARCHAR(510) NULL,
    [veins] INT NOT NULL,
    [status] TINYINT NOT NULL,
    [createdAt] DATE NOT NULL,
    CONSTRAINT [examKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [examinateID]
                    ),
    CONSTRAINT [patientExam]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[Patient] ([patientID]),
    CONSTRAINT [employeeExam]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[Employee] ([employeeID]),
    CONSTRAINT [examID]
        UNIQUE ([examinateID]),
    CONSTRAINT [gtZero] CHECK ([height] > 0
                               AND [weight] > 0
                               AND [temperature] > 0
                               AND [breathing] > 0
                               AND [veins] > 0
                              )
);
GO

CREATE TABLE [Prescription]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
    [createdAt] DATE NOT NULL,
    [status] TINYINT NOT NULL,
    CONSTRAINT [preKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [createdAt]
                    ),
    CONSTRAINT [patientPrescription]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[Patient] ([patientID]),
    CONSTRAINT [employeePrescription]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[Employee] ([employeeID])
);
GO

--Multivalue attribute
CREATE TABLE [Pre_Medicines]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
    [createdAt] DATE NOT NULL,
    [medicine] VARCHAR(20),
    CONSTRAINT [pre_medicineKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [createdAt]
                    ),
    CONSTRAINT [medicinePre_Med]
        FOREIGN KEY ([medicine])
        REFERENCES [dbo].[Medicine] ([medicineID]),
    CONSTRAINT [presFkey]
        FOREIGN KEY (
                        [patientID],
                        [employeeID],
                        [createdAt]
                    )
        REFERENCES [dbo].[Prescription] (
                                            [patientID],
                                            [employeeID],
                                            [createdAt]
                                        )
);
GO

--cycle relationship of relatives
CREATE TABLE [Relatives]
(
    [personA] VARCHAR(20),
    [personB] VARCHAR(20),
    CONSTRAINT [relativeKey]
        PRIMARY KEY (
                        [personA],
                        [personB]
                    ),
    CONSTRAINT [twoPeople] CHECK ([personA] <> [personB]),
    CONSTRAINT [existPerson1]
        FOREIGN KEY ([personA])
        REFERENCES [dbo].[People] ([peopleID]),
    CONSTRAINT [existPerson2]
        FOREIGN KEY ([personB])
        REFERENCES [dbo].[People] ([peopleID])
);
GO

CREATE TABLE [Roles]
(
    [roleID] VARCHAR(20),
    [roleName] NVARCHAR(255),
    CONSTRAINT [roleKey]
        PRIMARY KEY ([roleID])
);
GO

CREATE TABLE [Account]
(
    [accountId] VARCHAR(20),
    [password] VARCHAR(20),
    [status] TINYINT,
    [role] VARCHAR(20)
        CONSTRAINT [accountKey]
        PRIMARY KEY ([accountId]),
    CONSTRAINT [roleFkey]
        FOREIGN KEY ([role])
        REFERENCES [dbo].[Roles] ([roleID]) ON DELETE SET NULL ON UPDATE CASCADE
);
GO
