USE [QuanLiHoSoBenhAnNgoaiTru] 
GO

--delete trigger

-- on service
DROP TRIGGER [dbo].[deleteService]

CREATE TRIGGER deleteService
ON [dbo].[Service]
AFTER DELETE
as
BEGIN
	ROLLBACK
	declare @delID VARCHAR(20)
	SELECT @delID = del.[serviceID] FROM [Deleted] del

	UPDATE [dbo].[usingService] SET serviceID = NULL
	WHERE [usingService].[serviceID] = (SELECT serviceID FROM deleted)

	UPDATE [dbo].[Service] SET [Service].[status] = 0
	WHERE [Service].[serviceID] = (SELECT serviceID FROM deleted)
END

INSERT INTO [dbo].[Service]
VALUES
(   '1',   -- serviceID - varchar(20)
    ';asdjf;lawks', -- serviceName - nvarchar(255)
    13, -- servicePrice - int
    1     -- status - tinyint
    )
INSERT INTO [dbo].[Service]
VALUES
(   '2',   -- serviceID - varchar(20)
    ';asdjf;lawks', -- serviceName - nvarchar(255)
    13, -- servicePrice - int
    1     -- status - tinyint
    )

DELETE FROM [dbo].[Service]

SELECT * FROM [dbo].[Service] AS [S]
