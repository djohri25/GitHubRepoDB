/****** Object:  Procedure [dbo].[Get_GenderName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_GenderName]
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select GenderId, GenderName From LookupGenderID Order By GenderId
	END
ELSE
	BEGIN -- 0 = spanish
		Select GenderId, GenderNameSpanish GenderName From LookupGenderID Order By GenderId
	END