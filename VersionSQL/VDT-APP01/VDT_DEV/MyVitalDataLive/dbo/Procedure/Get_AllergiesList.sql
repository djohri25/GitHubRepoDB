/****** Object:  Procedure [dbo].[Get_AllergiesList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_AllergiesList]
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select AllergenTypeID, AllergenTypeName From LookupAllergies
	END
ELSE
	BEGIN -- 0 = spanish
		Select AllergenTypeID, AllergenTypeNameSpanish AllergenTypeName From LookupAllergies
	END