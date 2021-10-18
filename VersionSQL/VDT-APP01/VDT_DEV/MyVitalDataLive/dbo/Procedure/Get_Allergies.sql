/****** Object:  Procedure [dbo].[Get_Allergies]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_Allergies] 
	@ICENUMBER varchar(15),
	@Language BIT = 1
As
Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		SELECT RecordNumber, AllergenTypeId, 
		MobileDescription = 'Allergy',
		(SELECT AllergenTypeName FROM LookupAllergies WHERE AllergenTypeId = 
		MainAllergies.AllergenTypeId) AS AllergenTypeName,
		isnull(AllergenName,'') as AllergenName, 
		isnull(Reaction,'') as Reaction,
		isnull(ReadOnly,0) as ReadOnly 
		FROM MainAllergies WHERE ICENUMBER = @ICENUMBER
	END
ELSE
	BEGIN -- 0 = spanish
		SELECT RecordNumber, AllergenTypeId, 
		MobileDescription = 'Allergy',
		(SELECT AllergenTypeNameSpanish FROM LookupAllergies WHERE AllergenTypeId = 
		MainAllergies.AllergenTypeId) AS AllergenTypeName,
		isnull(AllergenName,'') as AllergenName, 
		isnull(Reaction,'') as Reaction,
		isnull(ReadOnly,0) as ReadOnly 
		FROM MainAllergies WHERE ICENUMBER = @ICENUMBER
	END