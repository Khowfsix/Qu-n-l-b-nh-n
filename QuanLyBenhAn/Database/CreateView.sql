USE [QuanLiHoSoBenhAnNgoaiTru];
GO

-- create View
CREATE VIEW [basicInfo_patient]
AS
SELECT [P].[peopleID] AS [patientID],
       [P].[firstName] AS [patientFirstName],
       [P].[middleName] AS [patientMiddleName],
       [P].[lastName] AS [patientLastname],
       [P].[sex],
       [P].[birthDay],
       [P].[address],
       [P].[phone],
       [P].[cardID],
       [P2].[patientJob],
       [P2].[healthInsurance#],
       [P2].[reason]
FROM [dbo].[People] AS [P]
    INNER JOIN [dbo].[Patient] AS [P2]
        ON ([P].[peopleID] = [P2].[patientID]);
GO

CREATE VIEW [info_Employee]
AS
SELECT [P].[peopleID],
       [P].[firstName],
       [P].[middleName],
       [P].[lastName],
       [P].[sex],
       [P].[birthDay],
       [P].[address],
       [P].[phone],
       [P].[cardID],
       [E].[positon],
       [E].[departmentID]
FROM [dbo].[People] AS [P]
    INNER JOIN [dbo].[Employee] AS [E]
        ON [P].[peopleID] = [E].[employeeID];
GO

CREATE VIEW [info_Doctor]
AS
SELECT [P].[peopleID] AS [doctorID],
       [P].[firstName] AS [doctorFirstname],
       [P].[middleName] AS [doctorMiddleName],
       [P].[lastName] AS [doctorLastName],
       [P].[sex],
       [P].[birthDay],
       [P].[address],
       [P].[phone],
       [P].[cardID],
       [E].[departmentID],
       [D].[departmentName]
FROM([dbo].[People] AS [P]
    INNER JOIN [dbo].[Employee] AS [E]
        ON [P].[peopleID] = [E].[employeeID])
    JOIN [dbo].[Department] AS [D]
        ON ([E].[departmentID] = [D].[departmentID])
WHERE [E].[positon] = 'Bác s?';
GO

CREATE VIEW [medicalRecord]
AS
SELECT [BIP].[patientID],
       [BIP].[patientFirstName],
       [BIP].[patientMiddleName],
       [BIP].[patientLastname],
       [BIP].[sex],
       [BIP].[birthDay],
       [BIP].[healthInsurance#],
       [ID].[doctorID],
       [ID].[doctorFirstname],
       [ID].[doctorMiddleName],
       [ID].[doctorLastName],
       [E].[examinateDay],
       [E].[height],
       [E].[weight],
       [E].[temperature],
       [E].[breathing],
       [E].[symptom],
       [E].[veins],
       [E].[createdAt]
FROM([dbo].[basicInfo_patient] AS [BIP]
    JOIN [dbo].[Examination] AS [E]
        ON [BIP].[patientID] = [E].[patientID])
    JOIN [dbo].[info_Doctor] AS [ID]
        ON ([E].[employeeID] = [ID].[doctorID]);
GO

-- thêm 1 tr??ng name vào ??n thu?c
CREATE VIEW [Medicines_view]
AS
SELECT [M].[medicineID],
       [M].[medicineName],
       [M].[unit],
       [M].[medicinePrice],
       [M].[status],
       [M].[createdAt],
       [M].[updateAt],
       [PM].[patientID],
       [PM].[employeeID],
       [PM].[medicine]
FROM [dbo].[Medicine] AS [M]
    INNER JOIN [dbo].[Pre_Medicines] AS [PM]
        ON [M].[medicineID] = [PM].[medicine];
GO

CREATE VIEW [Prescription_Medicines]
AS
SELECT [BIP].[patientID],
       [BIP].[patientFirstName],
       [BIP].[patientMiddleName],
       [BIP].[patientLastname],
       [BIP].[birthDay],
       [ID].[doctorID],
       [ID].[doctorFirstname],
       [ID].[doctorMiddleName],
       [ID].[doctorLastName],
       [MV].[medicineID],
       [MV].[medicineName],
       [MV].[unit],
       [MV].[createdAt]
FROM(([dbo].[Prescription] AS [P]
    JOIN [dbo].[basicInfo_patient] AS [BIP]
        ON [P].[patientID] = [BIP].[patientID])
    JOIN [dbo].[info_Doctor] AS [ID]
        ON [P].[employeeID] = [ID].[doctorID])
    JOIN [dbo].[Medicines_view] AS [MV]
        ON ([P].[createdAt] = [MV].[createdAt]);
GO