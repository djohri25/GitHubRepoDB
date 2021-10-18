/****** Object:  Procedure [dbo].[Get_StateName]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Get_StateName] 

as

set nocount on
Select * From LookupState
Order By StateCode