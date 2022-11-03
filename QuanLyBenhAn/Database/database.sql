use QuanLiHoSoBenhAnNgoaiTru
go

CREATE TABLE [People]
(
    [peopleID] VARCHAR(20) DEFAULT 'XX0000',
    [firstName] NVARCHAR(32) NOT NULL,
    [lastName] NVARCHAR(32) NOT NULL,
	[slug] NVARCHAR(100) NOT NULL DEFAULT '',
    [sex] CHAR(1) NOT NULL,
    [birthDay] DATE NOT NULL,
    [address] NVARCHAR(510) NOT NULL,
    [phone] VARCHAR(15) NOT NULL,
    [cardID] VARCHAR(15) NULL UNIQUE,
    [role] TINYINT NOT NULL,
    [status] TINYINT NOT NULL DEFAULT 1,
	createdAt DATETIME,
	updatedAt DATETIME,
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
    [patientID] VARCHAR(20) DEFAULT 'XX0000', --Khóa chính tương ứng lớp cha
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

--cycle relationship of relatives
CREATE TABLE [Relatives]
(
    [relativeID] VARCHAR(20),
    [patientID] VARCHAR(20),
    CONSTRAINT [relativeKey]
        PRIMARY KEY (
						[relativeID],
                        [patientID]
                    ),
    CONSTRAINT [twoPeople] CHECK ([patientID] <> [relativeID]),
    CONSTRAINT [existPerson1]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[People] ([peopleID]),
    CONSTRAINT [existPerson2]
        FOREIGN KEY ([relativeID])
        REFERENCES [dbo].[People] ([peopleID])
);
GO

CREATE TABLE [Employee]
(
    [employeeID] VARCHAR(20), --Khóa chính tương ứng lớp cha
    [position] NVARCHAR(25),
    CONSTRAINT [employeeKey]
        PRIMARY KEY ([employeeID]),
	CONSTRAINT positionCheck CHECK (position = N'Bác sĩ' OR position = N'Nhân viên'),
    CONSTRAINT [people_employee]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[People] ([peopleID]) ON UPDATE CASCADE,
);
GO

CREATE TABLE [Service]
(
    [serviceID] VARCHAR(20) DEFAULT 'XX0000',
    [serviceName] NVARCHAR(255),
    [servicePrice] INT,
    [status] TINYINT NOT NULL DEFAULT 1,
    CONSTRAINT [sPrice] CHECK ([servicePrice] > 0),
    CONSTRAINT [serviceKey]
        PRIMARY KEY ([serviceID])
);
GO

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

CREATE TABLE [Department]
(
    [departmentID] VARCHAR(20) DEFAULT 'XXX0000',
    [departmentName] NVARCHAR(255),
    [status] TINYINT NOT NULL DEFAULT 1,
    CONSTRAINT [departmentKey]
        PRIMARY KEY ([departmentID])
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
    [receiptID] VARCHAR(20) DEFAULT 'XXX0000',
    [receiptName] NVARCHAR(255),
    [status] TINYINT NOT NULL DEFAULT 1,
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

CREATE TABLE [Medicine]
(
    [medicineID] VARCHAR(20) DEFAULT 'XX0000',
    [medicineName] NVARCHAR(255),
    [unit] NVARCHAR(255),
    [medicinePrice] INT,
    [status] TINYINT NOT NULL DEFAULT 1,
	expiry INT NOT NULL, --số ngày sử dụng
	amount INT NOT NULL CHECK(amount >= 0), -- số tồn trong kho
    [createdAt] DATETIME,
    [updateAt] DATETIME,
    CONSTRAINT [dPrice] CHECK ([medicinePrice] > 0),
    CONSTRAINT [drugKey]
        PRIMARY KEY ([medicineID])
);
GO

CREATE TABLE [Prescription]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
	medicineId VARCHAR(20),
	prescriptionId VARCHAR(20) UNIQUE NOT NULL,
    [createdAt] DATE NOT NULL,
	descriptionPrescription NVARCHAR(500),
    [status] TINYINT NOT NULL,
    CONSTRAINT [preKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [medicineId],
						prescriptionId
                    ),
    CONSTRAINT [patientPrescription]
        FOREIGN KEY ([patientID])
        REFERENCES [dbo].[Patient] ([patientID]),
    CONSTRAINT [employeePrescription]
        FOREIGN KEY ([employeeID])
        REFERENCES [dbo].[Employee] ([employeeID]),
	CONSTRAINT medicinePrescription
		FOREIGN KEY (medicineId)
		REFERENCES dbo.Medicine(medicineID)
);
GO

--Multivalue attribute
CREATE TABLE [Pre_Medicines]
(
    [patientID] VARCHAR(20),
    [employeeID] VARCHAR(20),
	medicineId VARCHAR(20),
	prescriptionId VARCHAR(20),
	pre_MedicineId VARCHAR(20) UNIQUE NOT NULL,
	amount INT NOT NULL CHECK(amount >= 0),
    CONSTRAINT [Pre_MedicinesKey]
        PRIMARY KEY (
                        [patientID],
                        [employeeID],
                        [medicineId],
						prescriptionId,
						pre_MedicineId
                    ),
	CONSTRAINT Pre_MedicinesFK FOREIGN KEY (patientID, employeeID, medicineId, prescriptionId)
	REFERENCES dbo.Prescription(patientID, employeeID, medicineId, prescriptionId)
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

----------------------------------------------------------------------------
--Begin: createdAt and updatedAt in People
CREATE TRIGGER People_CreatedAt_UpdatedAt ON dbo.People
FOR INSERT, UPDATE
AS
DECLARE @createdAt DATETIME
DECLARE @updatedAt DATETIME
DECLARE @peopleID VARCHAR(20)
BEGIN
	IF TRIGGER_NESTLEVEL() > 1
    RETURN

	SELECT @peopleID = Inserted.peopleID, @createdAt = Inserted.createdAt, @updatedAt = Inserted.updatedAt
	FROM Inserted
	IF (@createdAt IS NULL)
	BEGIN
		SET @createdAt = GETDATE()
		UPDATE dbo.People SET createdAt = @createdAt WHERE peopleID = @peopleID
	END
	ELSE
	BEGIN
		SET @updatedAt = GETDATE()
		UPDATE dbo.People SET updatedAt = @updatedAt WHERE peopleID = @peopleID
	END
END
GO
--End: createdAt and updatedAt in People
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: slug people
CREATE TRIGGER People_Slug ON dbo.People
FOR INSERT, UPDATE
AS
DECLARE @firstName NVARCHAR(32)
DECLARE @lastName NVARCHAR(32)
DECLARE @slug NVARCHAR(100)
DECLARE @peopleID NVARCHAR(20)
BEGIN
	IF TRIGGER_NESTLEVEL() > 1
    RETURN

	SELECT @peopleID = Inserted.peopleID, @firstName = Inserted.firstName, @lastName = Inserted.lastName 
	FROM Inserted
	SET @slug = @lastName + ' ' + @firstName
	UPDATE dbo.People SET slug = @slug WHERE peopleID = @peopleID
END
GO
--End: slug people
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: id people
CREATE FUNCTION func_Auto_PeopleId(@role TINYINT)
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @id_next VARCHAR(20)
DECLARE @max INT
DECLARE @object VARCHAR(2)
IF @role = 0
BEGIN
	SET @object = 'TN'
END
ELSE
BEGIN
	IF @role = 1
	BEGIN
		SET @object = 'BN'
	END
	ELSE
	BEGIN
		SET @object = 'NV'
	END
END
SELECT @max = COUNT(role) FROM dbo.People WHERE role = @role
SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
-- Kiểm tra id đã tồn tại chưa
WHILE(EXISTS(SELECT peopleID FROM dbo.People WHERE peopleID = @id_next))
BEGIN
	SET @max = @max + 1
	SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
END
RETURN @id_next
END
GO

CREATE TRIGGER Auto_PeopleId ON dbo.People
FOR INSERT
AS
DECLARE @peopleId VARCHAR(20)
DECLARE @role TINYINT
BEGIN
	SELECT @role = Inserted.role FROM Inserted
	SET @peopleId = dbo.func_Auto_PeopleId(@role)
	UPDATE dbo.People SET peopleID = @peopleId WHERE peopleID = 'XX0000'
	-- Kế thừa id qua Patient
	IF (@role = 1)
	BEGIN
		INSERT INTO dbo.Patient (patientID)
		VALUES (@peopleId)
	END
	ELSE
	BEGIN
		IF (@role = 2)
		BEGIN
			INSERT INTO dbo.Employee (employeeID)
			VALUES (@peopleId)
		END
	END
END
GO
--End: id people
----------------------------------------------------------------------------


----------------------------------------------------------------------------
--Begin: id service
CREATE FUNCTION func_Auto_serviceID(@serviceid varchar(20))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @id_next VARCHAR(20)
	DECLARE @max INT
	DECLARE @object VARCHAR(2)
	BEGIN
		SET @object = 'SV'
	END
	SELECT @max = COUNT(serviceID) + 1 FROM [Service] WHERE serviceID = @serviceid
	SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	-- Kiểm tra id đã tồn tại chưa
	WHILE(EXISTS(SELECT serviceID FROM [Service] WHERE serviceID = @id_next))
	BEGIN
		SET @max = @max + 1
		SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	END
		RETURN @id_next
END
GO

CREATE TRIGGER Auto_serviceID ON [Service]
FOR INSERT
AS
BEGIN
	DECLARE @serviceID VARCHAR(20)
	SET @serviceID = dbo.func_Auto_serviceID(@serviceID)
	UPDATE [Service] SET serviceID = @serviceID WHERE serviceID = 'XX0000'
END
GO
--End: id service
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: id Department
CREATE FUNCTION func_Auto_departmentID(@departmentID varchar(20))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @id_next VARCHAR(20)
	DECLARE @max INT
	DECLARE @object VARCHAR(3)
	BEGIN
		SET @object = 'Dep'
	END
	SELECT @max = COUNT(departmentID) + 1 FROM [Department] WHERE departmentID = @departmentID
	SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	-- Kiểm tra id đã tồn tại chưa
	WHILE(EXISTS(SELECT departmentID FROM [Department] WHERE departmentID = @id_next))
	BEGIN
		SET @max = @max + 1
		SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	END
		RETURN @id_next
END
GO

CREATE TRIGGER Auto_departmentID ON [Department]
FOR INSERT
AS
BEGIN
	DECLARE @departmentID VARCHAR(20)
	SET @departmentID = dbo.func_Auto_departmentID(@departmentID)
	UPDATE [Department] SET departmentID = @departmentID WHERE departmentID = 'XXX0000'
END
GO
--End: id Department
----------------------------------------------------------------------------


----------------------------------------------------------------------------
--Begin: id Receipt
CREATE FUNCTION func_Auto_ReceiptID(@receiptid varchar(20))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @id_next VARCHAR(20)
	DECLARE @max INT
	DECLARE @object VARCHAR(3)
	BEGIN
		SET @object = 'Rec'
	END
	SELECT @max = COUNT(receiptID) + 1 FROM [Receipt] WHERE receiptID = @receiptid
	SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	-- Kiểm tra id đã tồn tại chưa
	WHILE(EXISTS(SELECT receiptID FROM [Receipt] WHERE receiptID = @id_next))
	BEGIN
		SET @max = @max + 1
		SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	END
		RETURN @id_next
END
GO

CREATE TRIGGER Auto_serviceID1 ON [Receipt]
FOR INSERT
AS
BEGIN
	DECLARE @receiptID VARCHAR(20)
	SET @receiptID = dbo.func_Auto_receiptID(@receiptID)
	UPDATE [receipt] SET receiptID = @receiptID WHERE receiptID = 'XXX0000'
END
GO
--End: id Receipt
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: id Medicine
CREATE FUNCTION func_Auto_medicineID(@medicineid varchar(20))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @id_next VARCHAR(20)
	DECLARE @max INT
	DECLARE @object VARCHAR(2)
	BEGIN
		SET @object = 'MC'
	END
	SELECT @max = COUNT(medicineID) + 1 FROM [Medicine] WHERE medicineID = @medicineid
	SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	-- Kiểm tra id đã tồn tại chưa
	WHILE(EXISTS(SELECT medicineID FROM [Medicine] WHERE medicineID = @id_next))
	BEGIN
		SET @max = @max + 1
		SET @id_next = @object + RIGHT('0' + CAST(@max AS VARCHAR(17)), 18)
	END
		RETURN @id_next
END
GO

CREATE TRIGGER Auto_medicineID ON [Medicine]
FOR INSERT
AS
BEGIN
	DECLARE @medicineID VARCHAR(20)
	SET @medicineID = dbo.func_Auto_medicineID(@medicineID)
	UPDATE [Medicine] SET medicineID = @medicineID WHERE medicineID = 'XX0000'
END
GO
--End: id Medicine
----------------------------------------------------------------------------



--------------------------------------------------------------------------------
--- Tự động tạo ngày createAt cho Pay
DROP TRIGGER IF EXISTS [trPay_CreatedAt]
GO

create trigger [trPay_CreatedAt]
on [dbo].[Pay]
for insert
as
declare @createdAt  date
      , @patientID  varchar(20)
      , @employeeID varchar(20)
      , @receiptID  varchar(20);
select @patientID  = [Inserted].[patientID]
     , @employeeID = [Inserted].[employeeID]
     , @receiptID  = [Inserted].[receiptID]
from [Inserted];
begin
    if (@createdAt is null)
    begin
        set @createdAt = getdate();
        update [dbo].[Pay]
        set [Pay].[createdAt] = @createdAt
        where [Pay].[patientID] = @patientID
              and [Pay].[employeeID] = @employeeID
              and [Pay].[receiptID] = @receiptID;
    end;
end;
go

------------------------------------------------------------------
--- tạo function lấy danh sách những dịch vụ mà người dùng sử dụng trong ngày đấy
create function [func_UsingService]
(
    @patientID varchar(20)
  , @dateUse date
)
returns @a table
(
    [patientID] varchar(20)
  , [serviceID] varchar(20)
  , [quantity] tinyint
  , [servicePrice] int
  , [useDay] date
  , [totalPay] int
)
as
begin
    insert into @a
    select [US].[patientID]
         , [US].[serviceID]
         , [US].[quantity]
         , [S].[servicePrice]
         , [US].[useday]
         , [S].[servicePrice] * [US].[quantity]
    from [dbo].[usingService]      as [US]
        inner join [dbo].[Service] as [S]
            on [US].[serviceID] = [S].[serviceID]
    where [US].[patientID] = @patientID
          and [US].[useday] = @dateUse;

    return;
end;
go

-------------------------------------------------------------------------------------
--- function lấy danh sách đơn thuốc tương ứng bệnh nhân, ngày khám
create function [func_ListMedicine-patient-Day]
(
    @patientID varchar(20)
  , @day date
)
returns @a table
(
    [medicine] varchar(20)
  , [pricePerUnit] int
  , [amount] int
  , [totalPrice] int
)
as
begin
    insert into @a
    select [MV].[medicineID]
         , [MV].[medicinePrice]
         , [MV].[amount]
         , [MV].[medicineID] * [MV].[amount]
    from [dbo].[Medicines_view] as [MV]
    where [MV].[patientID] = @patientID
          and [MV].[createdAt] = @day;
    return;
end;
go

-------------------------------------------------------------------------------------
--- function lấy tổng giá những dịch vụ
create function [func_totalPay_service]
(
    @patientID varchar(20)
  , @dateUse date
)
returns int
as
begin
    declare @sum int;
    select @sum = sum([FUS].[totalPay])
    from [dbo].[func_UsingService](@patientID, @dateUse) as [FUS];
    return @sum;
end;
go

-------------------------------------------------------------------------------------
--- function lấy tổng giá những thuốc trong đơn
create function [func_totalPay_medicine]
(
    @patientID varchar(20)
  , @dateUse date
)
returns int
as
begin
    declare @sum int;
    select @sum = sum([FLMPD].[totalPrice])
    from [dbo].[func_ListMedicine-patient-Day](@patientID, @dateUse) as [FLMPD];
    return @sum;
end;
go

-------------------------------------------------------------------------------------
--- function lấy tổng giá trong đơn
create trigger [trPay_CreatedAt]
on [dbo].[Pay]
after insert
as
declare @createdAt  date
      , @patientID  varchar(20)
      , @employeeID varchar(20)
      , @receiptID  varchar(20);
select @patientID  = [Inserted].[patientID]
     , @employeeID = [Inserted].[employeeID]
     , @receiptID  = [Inserted].[receiptID]
     , @createdAt  = [Inserted].[createdAt]
from [Inserted];
begin
    update [dbo].[Pay]
    set [Pay].[payTotal] = [dbo].[func_totalPay_service](@patientID, @createdAt)
                           + [dbo].[func_totalPay_medicine](@patientID, @createdAt)
    where [Pay].[patientID] = @patientID
          and [Pay].[employeeID] = @employeeID
          and [Pay].[receiptID] = @receiptID
          and [Pay].[createdAt] = @createdAt;
end;
go





----------------------------------------------------------------------------
--Begin: PROCEDURE UpdatePatient
CREATE PROCEDURE UpdatePatient (@patientFirstName nvarchar(32),
								@patientLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@patientJob nvarchar(255),
								@healthInsurance# varchar(20),
								@reason nvarchar(500),
								@peopleID VARCHAR(20))
AS
BEGIN
	BEGIN TRANSACTION Tran_UpdatePatient
	BEGIN TRY
		UPDATE dbo.People SET firstName = @patientFirstName,
								lastName = @patientLastname,
								sex = @sex,
								birthDay = @birthDay,
								address = @address,
								phone = @phone,
								cardID = @cardID
		WHERE peopleID = @peopleID

		UPDATE dbo.Patient SET patientJob = @patientJob,
								healthInsurance# = @healthInsurance#,
								reason = @reason
		WHERE patientID = @peopleID

		COMMIT TRANSACTION Tran_UpdatePatient
	END TRY
	BEGIN CATCH
		PRINT('Cập nhật không thành công')
		ROLLBACK TRANSACTION Tran_UpdatePatient
	END CATCH
END
GO
--End: PROCEDURE UpdatePatient
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: PROCEDURE UpdatePatient
CREATE PROCEDURE InsertPatient (@patientFirstName nvarchar(32),
								@patientLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@patientJob nvarchar(255),
								@healthInsurance# varchar(20),
								@reason nvarchar(500))
AS
BEGIN
	BEGIN TRANSACTION Tran_InsertPatient
	BEGIN TRY
		DECLARE @role TINYINT
        SET @role = 1
		INSERT INTO dbo.People (firstName, lastName, sex, birthDay, address, phone, cardID, role)
		VALUES (@patientFirstName, @patientLastname, @sex, @birthDay, @address, @phone, @cardID, @role)

		DECLARE @patientID VARCHAR(20)
		SELECT @patientID = MAX(peopleID) FROM dbo.People WHERE role = @role
		
		UPDATE dbo.Patient SET patientJob = @patientJob, healthInsurance# = @healthInsurance#, reason = @reason 
		WHERE patientID = @patientID

		COMMIT TRANSACTION Tran_InsertPatient
    END TRY
	BEGIN CATCH
		PRINT('Thêm không thành công!')
		COMMIT TRANSACTION Tran_InsertPatient
	END CATCH
END
GO
--End: PROCEDURE UpdatePatient
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: PROCEDURE InsertEmployee
CREATE PROCEDURE InsertEmployee (@employeeFirstName nvarchar(32),
								@employeeLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@position NVARCHAR(25))
AS
BEGIN
	BEGIN TRANSACTION Tran_InsertEmployee
	BEGIN TRY
		DECLARE @role TINYINT
        SET @role = 2
		INSERT INTO dbo.People (firstName, lastName, sex, birthDay, address, phone, cardID, role)
		VALUES (@employeeFirstName, @employeeLastname, @sex, @birthDay, @address, @phone, @cardID, @role)

		DECLARE @employeeID VARCHAR(20)
		SELECT @employeeID = MAX(peopleID) FROM dbo.People WHERE role = @role

		UPDATE dbo.Employee SET position = @position WHERE employeeID = @employeeID

		COMMIT TRANSACTION Tran_InsertEmployee
	END TRY
	BEGIN CATCH
		PRINT('Thêm không thành công')
		ROLLBACK TRANSACTION Tran_InsertEmployee
	END CATCH
END
GO
--End: PROCEDURE InsertEmployee
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: PROCEDURE UpdateEmployee
CREATE PROCEDURE UpdateEmployee (@employeeFirstName nvarchar(32),
								@employeeLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@position NVARCHAR(25),
								@peopleID VARCHAR(20))
AS
BEGIN
	BEGIN TRANSACTION Tran_UpdateEmployee
	BEGIN TRY
		UPDATE dbo.People SET firstName = @employeeFirstName,
								lastName = @employeeLastname,
								sex = @sex,
								birthDay = @birthDay,
								address = @address,
								phone = @phone,
								cardID = @cardID
		WHERE peopleID = @peopleID

		UPDATE dbo.Employee SET position = @position WHERE employeeID = @peopleID

		COMMIT TRANSACTION Tran_UpdateEmployee
	END TRY
    BEGIN CATCH
		PRINT('Cập nhật không thành công!')
		ROLLBACK TRANSACTION Tran_UpdateEmployee
	END CATCH
END
GO
--End: PROCEDURE UpdateEmployee
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: PROCEDURE InsertRelative
CREATE PROCEDURE InsertRelative (@relativeFirstName nvarchar(32),
								@relativeLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@patientID VARCHAR(20))
AS
BEGIN
	BEGIN TRANSACTION Tran_InsertRelative
	BEGIN TRY
		DECLARE @role TINYINT
        SET @role = 0
		INSERT INTO dbo.People (firstName, lastName, sex, birthDay, address, phone, cardID, role)
		VALUES (@relativeFirstName, @relativeLastname, @sex, @birthDay, @address, @phone, @cardID, @role)


		DECLARE @relativeID VARCHAR(20)
		SELECT @relativeID = MAX(peopleID) FROM dbo.People WHERE role = @role

		INSERT INTO dbo.Relatives (relativeID, patientID)
		VALUES(@relativeID, @patientID)

		COMMIT TRANSACTION Tran_InsertRelative
	END TRY
    BEGIN CATCH
		PRINT('Thêm không thành công')
		ROLLBACK TRANSACTION Tran_InsertRelative
	END CATCH
END
GO
--End: PROCEDURE InsertRelative
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--Begin: PROCEDURE UpdateRelative
CREATE PROCEDURE UpdateRelative (@relativeFirstName nvarchar(32),
								@relativeLastname nvarchar(32),
								@sex char(1),
								@birthDay DATE,
								@address nvarchar(510),
								@phone varchar(15),
								@cardID varchar(15),
								@patientID VARCHAR(20),
								@relativeID VARCHAR(20))
AS
BEGIN
	BEGIN TRANSACTION Tran_UpdateRelative
	BEGIN TRY
		UPDATE dbo.People SET firstName = @relativeFirstName,
								lastName = @relativeLastname,
								sex = @sex,
								birthDay = @birthDay,
								address = @address,
								phone = @phone,
								cardID = @cardID
		WHERE peopleID = @relativeID

		UPDATE dbo.Relatives SET patientID = @patientID WHERE relativeID = @relativeID

		COMMIT TRANSACTION Tran_UpdateRelative
	END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION Tran_UpdateRelative
	END CATCH
END
GO
--End: PROCEDURE UpdateRelative
----------------------------------------------------------------------------


EXEC dbo.InsertPatient @patientFirstName = N'Tĩnh',  -- nvarchar(32)
                       @patientLastname = N'Bùi Quốc',   -- nvarchar(32)
                       @sex = 'F',                -- char(1)
                       @birthDay = '2002-10-10', -- date
                       @address = N'484 Lê Văn Việt',           -- nvarchar(510)
                       @phone = '0946541256',              -- varchar(15)
                       @cardID = '111111111',             -- varchar(15)
                       @patientJob = N'Học sinh',        -- nvarchar(255)
                       @healthInsurance# = '111111111',   -- varchar(20)
                       @reason = N'Bị đau dạ dày'             -- nvarchar(500)

EXEC dbo.InsertPatient @patientFirstName = N'A',  -- nvarchar(32)
                       @patientLastname = N'Nguyễn Văn',   -- nvarchar(32)
                       @sex = 'F',                -- char(1)
                       @birthDay = '2002-10-11', -- date
                       @address = N'123 Hàm Minh',           -- nvarchar(510)
                       @phone = '0123456789',              -- varchar(15)
                       @cardID = '111111112',             -- varchar(15)
                       @patientJob = N'Sinh viên',        -- nvarchar(255)
                       @healthInsurance# = '111111112',   -- varchar(20)
                       @reason = NULL             -- nvarchar(500)

EXEC dbo.InsertPatient @patientFirstName = N'B',  -- nvarchar(32)
                       @patientLastname = N'Nguyễn Thị',   -- nvarchar(32)
                       @sex = 'M',                -- char(1)
                       @birthDay = '1999-10-02', -- date
                       @address = N'321 Nguyễn Bỉnh Khiêm',           -- nvarchar(510)
                       @phone = '0987654321',              -- varchar(15)
                       @cardID = '111111113',             -- varchar(15)
                       @patientJob = N'Kế toán',        -- nvarchar(255)
                       @healthInsurance# = '111111113',   -- varchar(20)
                       @reason = Null             -- nvarchar(500)

EXEC dbo.InsertEmployee @employeeFirstName = N'A', -- nvarchar(32)
                        @employeeLastname = N'Bùi Thái',  -- nvarchar(32)
                        @sex = 'F',                -- char(1)
                        @birthDay = '1980-02-02', -- date
                        @address = N'145 Hoàng Diệu',           -- nvarchar(510)
                        @phone = '0112233445',              -- varchar(15)
                        @cardID = '111111114',             -- varchar(15)
                        @position = N'Bác sĩ'           -- nvarchar(25)

EXEC dbo.InsertEmployee @employeeFirstName = N'C', -- nvarchar(32)
                        @employeeLastname = N'Bùi Thị',  -- nvarchar(32)
                        @sex = 'M',                -- char(1)
                        @birthDay = '1981-01-01', -- date
                        @address = N'146 Dân Chủ',           -- nvarchar(510)
                        @phone = '0112233446',              -- varchar(15)
                        @cardID = '111111115',             -- varchar(15)
                        @position = N'Bác sĩ'           -- nvarchar(25)

EXEC dbo.InsertEmployee @employeeFirstName = N'D', -- nvarchar(32)
                        @employeeLastname = N'Nguyễn Thị',  -- nvarchar(32)
                        @sex = 'M',                -- char(1)
                        @birthDay = '1983-06-01', -- date
                        @address = N'101 Võ Văn Ngân',           -- nvarchar(510)
                        @phone = '0112233447',              -- varchar(15)
                        @cardID = '111111116',             -- varchar(15)
                        @position = N'Bác sĩ'           -- nvarchar(25)

EXEC dbo.InsertEmployee @employeeFirstName = N'Một', -- nvarchar(32)
                        @employeeLastname = N'Đỗ Thị',  -- nvarchar(32)
                        @sex = 'M',                -- char(1)
                        @birthDay = '1983-06-06', -- date
                        @address = N'134 Đỗ Xuân Hợp',           -- nvarchar(510)
                        @phone = '0112233448',              -- varchar(15)
                        @cardID = '111111117',             -- varchar(15)
                        @position = N'Nhân viên'           -- nvarchar(25)

EXEC dbo.InsertEmployee @employeeFirstName = N'Hai', -- nvarchar(32)
                        @employeeLastname = N'Đỗ Thị',  -- nvarchar(32)
                        @sex = 'M',                -- char(1)
                        @birthDay = '1984-07-07', -- date
                        @address = N'345 Đỗ Xuân Hợp',           -- nvarchar(510)
                        @phone = '0112233449',              -- varchar(15)
                        @cardID = '111111118',             -- varchar(15)
                        @position = N'Nhân viên'           -- nvarchar(25)

EXECUTE dbo.InsertRelative @relativeFirstName = N'Một', -- nvarchar(32)
                           @relativeLastname = N'Lê văn',  -- nvarchar(32)
                           @sex = 'F',                -- char(1)
                           @birthDay = '1999-07-08', -- date
                           @address = N'194 Hàm Thuận Nam',           -- nvarchar(510)
                           @phone = '0334488221',              -- varchar(15)
                           @cardID = '222222222',             -- varchar(15)
                           @patientID = 'BN01'           -- varchar(20)

EXECUTE dbo.InsertRelative @relativeFirstName = N'Hai', -- nvarchar(32)
                           @relativeLastname = N'Lê văn',  -- nvarchar(32)
                           @sex = 'M',                -- char(1)
                           @birthDay = '1999-08-08', -- date
                           @address = N'146 Hàm Cường',           -- nvarchar(510)
                           @phone = '0334488222',              -- varchar(15)
                           @cardID = '222222223',             -- varchar(15)
                           @patientID = 'BN02'           -- varchar(20)

EXECUTE dbo.InsertRelative @relativeFirstName = N'Ba', -- nvarchar(32)
                           @relativeLastname = N'Lê văn',  -- nvarchar(32)
                           @sex = 'F',                -- char(1)
                           @birthDay = '2002-08-08', -- date
                           @address = N'147 Minh Tiến',           -- nvarchar(510)
                           @phone = '0334488332',              -- varchar(15)
                           @cardID = '222222333',             -- varchar(15)
                           @patientID = 'BN03'           -- varchar(20)

INSERT INTO [Service]
(
    [serviceName],
    [servicePrice]
)
VALUES
( 
	N'Xét nghiệm máu',
	500000
    )
GO

INSERT INTO [Service]
(
    [serviceName],
    [servicePrice]
)
VALUES
( 
	N'Xét nghiệm nước tiểu',
	50000
    )
GO

Select * from [Service]
GO


INSERT INTO [Department]
(
    [DepartmentName]
)
VALUES
( 
	N'Khoa Cấp cứu'
    )
GO

INSERT INTO [Department]
(
    [DepartmentName]
)
VALUES
( 
	N'Khoa Nhi'
    )
GO

Select * from [Department]
GO

INSERT INTO [Receipt]
(
    [receiptName]
)
VALUES
(
	N'Hóa đơn 1'
)
GO
SELECT * FROM [Receipt]

INSERT INTO dbo.Medicine
(
    medicineName,
    unit,
    medicinePrice,
    expiry,
    amount
)
VALUES
(
    NULL,      -- medicineName - nvarchar(255)
    NULL,      -- unit - nvarchar(255)
    NULL,      -- medicinePrice - int
    0,         -- expiry - int
    0         -- amount - int
    )
SELECT * FROM dbo.Medicine

SELECT * FROM dbo.People
SELECT * FROM dbo.Patient
SELECT * FROM dbo.Relatives
SELECT * FROM dbo.Employee


-- create View
-------------------------------------------------------------
-- Hiển thị các Phòng ban
create view Department_view
as
select De.departmentID, De.departmentName, De.status
from Department as De
where De.status = 1;
go


-- Hiển thị các Biên nhận
create view Receipt_view
as
select Re.receiptID, Re.receiptName, Re.status
from Receipt as Re
where Re.status = 1
With check option;
go

-- Hiển thị các thông tin các hóa đơn 
create view pay_view
as
select Pe1.firstName as patientName,
		Pe.firstName as employeeName,
		Re.receiptName,	
		Pa.payTotal, 
		Pa.createdAt
from ((((Patient as Pt inner join Pay as Pa
	on Pa.patientID = Pt.patientID)
	inner join Employee as Em on Pa.employeeID = Em.employeeID)
	inner join Receipt as Re on Pa.receiptID = Re.receiptID)
	inner join People as Pe on Em.employeeID = Pe.peopleID)
	inner join People as Pe1 on Pa.patientID = Pe1.peopleID
where Pa.status = 1;
go 


-- hiển thị thông tin Examination
create view Examination_view
as
select Ex.examinateID,
		Pe.firstName as Employeename, 
		Pe1.firstName as Patientname, 
		Ex.breathing, 
		Ex.examinateDay, 
		Ex.height, 
		Ex.symptom, 
		Ex.temperature,
		Ex.veins,
		Ex.weight
from ((((Examination as Ex inner join Employee as Em 
		on Ex.employeeID = Em.employeeID)		
		inner join Patient as Pa on Ex.patientID = Pa.patientID))
		inner join People as Pe on Em.employeeID = Pe.peopleID)
		inner join People as Pe1 on Pa.patientID = Pe1.peopleID
where Ex.status = 1;
go

if object_id('[dbo].[basicInfo_patient]', 'V') is not null
    drop view [dbo].[basicInfo_patient];
go
;
create view [basicInfo_patient]
as
select [P].[peopleID]   as [patientID]
     , [P].[firstName]  as [patientFirstName]
     , [P].[lastName]   as [patientLastname]
     , [P].[sex]
     , [P].[birthDay]
     , [P].[address]
     , [P].[phone]
     , [P].[cardID]
     , [P2].[patientJob]
     , [P2].[healthInsurance#]
     , [P2].[reason]
from [dbo].[People]            as [P]
    inner join [dbo].[Patient] as [P2]
        on ([P].[peopleID] = [P2].[patientID]);
go

if object_id('[dbo].[info_Employee]', 'V') is not null
    drop view [dbo].[info_Employee];
go
create view [info_Employee]
as
select [P].[peopleID]
     , [P].[firstName]
     , [P].[lastName]
     , [P].[sex]
     , [P].[birthDay]
     , [P].[address]
     , [P].[phone]
     , [P].[cardID]
     , [E].[position]
     , [E].[departmentID]
from [dbo].[People]             as [P]
    inner join [dbo].[Employee] as [E]
        on [P].[peopleID] = [E].[employeeID];
go

if object_id('[dbo].[info_Doctor]', 'V') is not null
    drop view [dbo].[info_Doctor];
go
create view [info_Doctor]
as
select [P].[peopleID]   as [doctorID]
     , [P].[firstName]  as [doctorFirstname]
     , [P].[lastName]   as [doctorLastName]
     , [P].[sex]
     , [P].[birthDay]
     , [P].[address]
     , [P].[phone]
     , [P].[cardID]
     , [E].[departmentID]
     , [D].[departmentName]
from([dbo].[People]             as [P]
    inner join [dbo].[Employee] as [E]
        on [P].[peopleID] = [E].[employeeID])
    join [dbo].[Department] as [D]
        on ([E].[departmentID] = [D].[departmentID])
where [E].[position] = 'Bác sĩ';
go

if object_id('[dbo].[medicalRecord]', 'V') is not null
    drop view [dbo].[medicalRecord];
go
create view [medicalRecord]
as
select [BIP].[patientID]
     , [BIP].[patientFirstName]
     , [BIP].[patientLastname]
     , [BIP].[sex]
     , [BIP].[birthDay]
     , [BIP].[healthInsurance#]
     , [ID].[doctorID]
     , [ID].[doctorFirstname]
     , [ID].[doctorLastName]
     , [E].[examinateDay]
     , [E].[height]
     , [E].[weight]
     , [E].[temperature]
     , [E].[breathing]
     , [E].[symptom]
     , [E].[veins]
     , [E].[createdAt]
from([dbo].[basicInfo_patient] as [BIP]
    join [dbo].[Examination]   as [E]
        on [BIP].[patientID] = [E].[patientID])
    join [dbo].[info_Doctor] as [ID]
        on ([E].[employeeID] = [ID].[doctorID]);
go

-- thêm 1 trường name vào đơn thuốc
if object_id('[dbo].[Medicines_view]', 'V') is not null
    drop view [dbo].[Medicines_view];
go
create view [Medicines_view]
as
select [M].[medicineID]
     , [M].[medicineName]
     , [M].[unit]
     , [M].[medicinePrice]
     , [M].[status]
     , [M].[createdAt]
     , [M].[updateAt]
     , [PM].[patientID]
     , [PM].[employeeID]
from [dbo].[Medicine]                as [M]
    inner join [dbo].[Pre_Medicines] as [PM]
        on [M].[medicineID] = [PM].[medicineId];
go

if object_id('[dbo].[Prescription_Medicines]', 'V') is not null
    drop view [dbo].[Prescription_Medicines];
go
create view [Prescription_Medicines]
as
select [BIP].[patientID]
     , [BIP].[patientFirstName]
     , [BIP].[patientLastname]
     , [BIP].[birthDay]
     , [ID].[doctorID]
     , [ID].[doctorFirstname]
     , [ID].[doctorLastName]
     , [MV].[medicineID]
     , [MV].[medicineName]
     , [MV].[unit]
     , [MV].[createdAt]
from(([dbo].[Prescription]         as [P]
    join [dbo].[basicInfo_patient] as [BIP]
        on [P].[patientID] = [BIP].[patientID])
    join [dbo].[info_Doctor] as [ID]
        on [P].[employeeID] = [ID].[doctorID])
    join [dbo].[Medicines_view] as [MV]
        on ([P].[createdAt] = [MV].[createdAt]);
go