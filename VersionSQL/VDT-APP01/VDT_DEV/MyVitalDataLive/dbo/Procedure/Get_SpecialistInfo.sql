/****** Object:  Procedure [dbo].[Get_SpecialistInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_SpecialistInfo] 
	@ICENUMBER varchar(15),
	@Language BIT = 1
As

Set Nocount On


Select RecordNumber, LastName, FirstName, Address1, 
Address2, City, State, Postal, RoleId, 
(
SELECT TOP 1 
CASE @Language
	WHEN  1 
		THEN
			RoleName
	WHEN 0 
		THEN
			RoleNameSpanish 
	END 
	From LookupRoleId Where RoleId = MainSpecialist.RoleId
) As RoleName,
Substring(Phone,1,3) As PhoneArea,
Substring(Phone,4,3) As PhonePrefix,
Substring(Phone,7,4) As PhoneSuffix,
Substring(FaxPhone,1,3) As FaxArea,
Substring(FaxPhone,4,3) As FaxPrefix,
Substring(FaxPhone,7,4) As FaxSuffix,
Substring(PhoneCell,1,3) As CellArea,
Substring(PhoneCell,4,3) As CellPrefix,
Substring(PhoneCell,7,4) As CellSuffix,
dbo.FullName(LastName, FirstName, NULL) As FullName,
dbo.FormatPhone(Phone) As FullPhone,
dbo.FormatPhone(FaxPhone) As FullFax,
dbo.FormatPhone(PhoneCell) As FullCell

From MainSpecialist Where ICENUMBER = @ICENUMBER