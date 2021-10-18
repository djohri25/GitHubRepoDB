/****** Object:  Procedure [dbo].[Get_BloodTypeName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_BloodTypeName] 
	@Language BIT = 1
as

set nocount on
IF(@Language = 1)
	BEGIN -- 1 = english
		Select BloodTypeID, BloodTypeName From LookupBloodTypeID Order By BloodTypeID 
	END
ELSE
	BEGIN -- 0 = spanish
		Select BloodTypeID, BloodTypeNameSpanish BloodTypeName From LookupBloodTypeID Order By BloodTypeID 
	END