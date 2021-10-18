/****** Object:  Procedure [dbo].[Get_InsuranceTypeList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_InsuranceTypeList]
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select InsuranceTypeID, InsuranceTypeName From  LookupInsuranceTypeID Order By InsuranceTypeId
	END
ELSE
	BEGIN -- 0 = spanish
		Select InsuranceTypeID, InsuranceTypeNameSpanish InsuranceTypeName From  LookupInsuranceTypeID Order By InsuranceTypeId
	END