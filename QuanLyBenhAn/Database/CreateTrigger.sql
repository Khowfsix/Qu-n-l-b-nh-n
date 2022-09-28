USE [QuanLiHoSoBenhAnNgoaiTru];
GO

--delete trigger

-- on service
-- change status of service to 0
CREATE TRIGGER [deleteService]
ON [dbo].[Service]
INSTEAD OF DELETE
AS
DECLARE @delID VARCHAR(20);
SELECT @delID = [del].[serviceID]
FROM [Deleted] AS [del];
BEGIN
    UPDATE [dbo].[Service]
    SET [Service].[status] = 0
    WHERE [Service].[serviceID] = @delID;
END;
GO

-- on medicine
-- ch? set 0 status c?a thu?c, nh?ng ??n thu?c ?ã có thu?c ??y thì gi? nguyên kh?i s?a, 
-- nó ch? mang ý ngh?a là thu?c ??y không còn t?n t?i trong kho n?a
CREATE TRIGGER [deleteMedicine]
ON [dbo].[Medicine]
INSTEAD OF DELETE
AS
DECLARE @delID VARCHAR(20);
SELECT @delID = [del].[medicineID]
FROM [Deleted] AS [del];
BEGIN
    UPDATE [dbo].[Medicine]
    SET [Medicine].[status] = 0
    WHERE [Medicine].[medicineID] = @delID;
END;
GO

-- on department
CREATE TRIGGER [deleteDepartment]
ON [dbo].[Department]
INSTEAD OF DELETE
AS
DECLARE @delID VARCHAR(20);
SELECT @delID = [del].[departmentID]
FROM [Deleted] AS [del];
BEGIN
    UPDATE [dbo].[Employee]
    SET [Employee].[departmentID] = NULL
    WHERE [Employee].[departmentID] = @delID;

    UPDATE [dbo].[Department]
    SET [Department].[status] = 0
    WHERE [Department].[departmentID] = @delID;
END;
GO

-- on Receipt
-- m?c ??nh là không cho nó xóa nh?ng v?n ph?i t?o trigger vì b?ng 1 cách nào ?ó nó b? xóa thì sao :))
CREATE TRIGGER [deleteReceipt]
ON [dbo].[Receipt]
FOR DELETE
AS
BEGIN
    RAISERROR('Do not delete Receipt', 16, 25);
    ROLLBACK;
END;
GO

-- on Account
-- khi công nhân thoát ly kh?i t? b?n ?? tìm ki?m t? do
CREATE TRIGGER [deleteAccount]
ON [dbo].[Account]
INSTEAD OF DELETE
AS
DECLARE @delID VARCHAR(20);
SELECT @delID = [del].[accountId]
FROM [Deleted] AS [del];
BEGIN
    UPDATE [dbo].[Account]
    SET [Account].[status] = 0
    WHERE [Account].[accountId] = @delID;
END;

-- on Pay
