/****** Object:  View [dbo].[MainSpecialist_RoleID1]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.MainSpecialist_RoleID1
AS
SELECT     RecordNumber, ICENUMBER, LastName, FirstName, Address1, Address2, City, State, Postal, Specialty, Phone, PhoneCell, FaxPhone, NurseName, NursePhone, 
                      RoleID, CreationDate, ModifyDate, NPI
FROM         dbo.MainSpecialist
WHERE     (RoleID = 1)