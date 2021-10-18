/****** Object:  Procedure [dbo].[Get_LanguageName]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Get_LanguageName] 

as

set nocount on
Select id, name From LookupLanguage
Order By name