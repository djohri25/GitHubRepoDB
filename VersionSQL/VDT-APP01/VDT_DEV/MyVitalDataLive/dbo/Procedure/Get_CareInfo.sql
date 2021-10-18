/****** Object:  Procedure [dbo].[Get_CareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_CareInfo]

	@ICENUMBER varchar(15),
	@Language bit = 1
AS

SET NOCOUNT ON

SELECT RecordNumber, ISNULL(LastName,'') AS LastName, ISNULL(MiddleName,'') AS MiddleName, ISNULL(FirstName,'') AS FirstName, 
ISNULL(Address1,'') AS Address1, 
ISNULL(Address2,'') AS Address2, ISNULL(City,'') AS City, ISNULL(State,'') AS State, 
ISNULL(Postal,'') AS Postal, CareTypeId, RelationshipId,
MobileDescription = 'Contact List',
(
SELECT TOP 1 
CASE @Language
	WHEN  1 
		THEN CareTypeName
	WHEN 0 
		THEN CareTypeNameSpanish
END  
FROM LookupCareTypeId WHERE 
CareTypeId = MainCareInfo.CareTypeId) AS CareName,
(
SELECT TOP 1 
CASE @Language
	WHEN  1 
		THEN RelationshipName
	WHEN 0 
		THEN RelationshipNameSpanish
END  
FROM LookupRelationshipId WHERE 
RelationshipId = MainCareInfo.RelationshipId) AS RelationshipName,
Substring(PhoneHome,1,3) AS PhoneArea,
Substring(PhoneHome,4,3) AS PhonePrefix,
Substring(PhoneHome,7,4) AS PhoneSuffix,
Substring(PhoneCell,1,3) AS CellArea,
Substring(PhoneCell,4,3) AS CellPrefix,
Substring(PhoneCell,7,4) AS CellSuffix,
Substring(PhoneOther,1,3) AS OtherArea,
Substring(PhoneOther,4,3) AS OtherPrefix,
Substring(PhoneOther,7,4) AS OtherSuffix,
dbo.FormatPhone(PhoneHome) AS PhHome,
dbo.FormatPhone(PhoneCell) AS PhCell,
dbo.FormatPhone(PhoneOther) AS PhOther,
dbo.FullName(LastName, FirstName, MiddleName) AS FullName,
ContactType,ISNULL(EmailAddress,'') AS EmailAddress,NotifyByEmail,NotifyBySMS

FROM MainCareInfo WHERE ICENUMBER = @ICENUMBER