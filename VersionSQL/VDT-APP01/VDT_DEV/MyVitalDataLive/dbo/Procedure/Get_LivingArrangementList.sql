/****** Object:  Procedure [dbo].[Get_LivingArrangementList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_LivingArrangementList]
@Language BIT = 1
as

Set NoCount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select LivingWithID, LivingWithName From LookupLivingWithId 
	END
ELSE
	BEGIN -- 0 = spanish
		Select LivingWithID, LivingWithNameSpanish LivingWithName From LookupLivingWithId 
	END