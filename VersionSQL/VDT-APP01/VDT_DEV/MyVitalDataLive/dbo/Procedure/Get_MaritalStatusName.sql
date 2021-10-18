/****** Object:  Procedure [dbo].[Get_MaritalStatusName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MaritalStatusName] 
	@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select MaritalStatusID, MaritalStatusName From LookupMaritalStatusID 
		Order by MaritalStatusId
	END
ELSE
	BEGIN -- 0 = spanish
		Select MaritalStatusID, MaritalStatusNameSpanish MaritalStatusName From LookupMaritalStatusID 
		Order by MaritalStatusId
	END