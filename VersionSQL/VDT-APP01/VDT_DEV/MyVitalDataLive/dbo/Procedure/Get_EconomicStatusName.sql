/****** Object:  Procedure [dbo].[Get_EconomicStatusName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_EconomicStatusName] 
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select EconomicStatusID, EconomicStatusName From LookupEconomicStatusID 
		Order By EconomicStatusID
	END
ELSE
	BEGIN -- 0 = spanish
		Select EconomicStatusID, EconomicStatusNameSpanish EconomicStatusName From LookupEconomicStatusID 
		Order By EconomicStatusID
	END