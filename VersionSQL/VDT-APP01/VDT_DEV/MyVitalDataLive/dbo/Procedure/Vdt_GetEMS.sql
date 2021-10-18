/****** Object:  Procedure [dbo].[Vdt_GetEMS]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Vdt_GetEMS]
	
AS

SELECT Email, Active, LastName, FirstName, Company, dbo.FormatPhone(Phone) AS Phone, Address1,
	Address2, City, State, Zip, WebUrl, --License, 
	SSN, dbo.FormatPhone(Fax) AS Fax, LastLogin,
    SecureQu, SecureAn, Substring(SSN,1,3) + '-' +	Substring(SSN,4,2) + '-' + Substring(SSN,6,4) As FullSSN,
	Substring(SSN,1,3) AS SSN1, Substring(SSN,4,2) AS SSN2, Substring(SSN,6,4) As SSN3,
	Substring(Phone,1,3) AS PhArea, Substring(Phone,4,3) AS PhPrefix, Substring(Phone,7,4) As PhSuffix,
	Substring(Fax,1,3) AS FxArea, Substring(Fax,4,3) AS FxPrefix, Substring(Fax,7,4) As FxSuffix
  FROM MainEMS ORDER BY Email