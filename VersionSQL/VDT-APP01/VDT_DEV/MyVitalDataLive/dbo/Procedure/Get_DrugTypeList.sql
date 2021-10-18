/****** Object:  Procedure [dbo].[Get_DrugTypeList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DrugTypeList] 
	@Language BIT = 1
As
Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		SELECT DrugId, DrugName FROM LookupDrugType
	END
ELSE
	BEGIN -- 0 = spanish
		SELECT DrugId, DrugNameSpanish DrugName FROM LookupDrugType
	END