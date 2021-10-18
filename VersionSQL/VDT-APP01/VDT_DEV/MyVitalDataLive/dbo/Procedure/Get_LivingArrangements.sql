/****** Object:  Procedure [dbo].[Get_LivingArrangements]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_LivingArrangements]
	@ICENUMBER varchar(15) ,
	@Language BIT = 1

as

set nocount on

SELECT RecordNumber, LivingWithId, 
(
SELECT TOP 1 
	CASE @Language
		WHEN  1 
			THEN LivingWithName
		WHEN 0 
			THEN LivingWithNameSpanish 
	END 
From LookupLivingWithId 
Where LivingWithId = MainLivingArrangements.LivingWithId)
As LivingWithName,
ContactName,
Substring(ContactPhone,1,3) As PhoneArea,
Substring(ContactPhone,4,3) As PhonePrefix,
Substring(ContactPhone,7,4) As PhoneSuffix,
dbo.FormatPhone(ContactPhone) As Phone
From MainLivingArrangements
Where ICENUMBER = @ICENUMBER