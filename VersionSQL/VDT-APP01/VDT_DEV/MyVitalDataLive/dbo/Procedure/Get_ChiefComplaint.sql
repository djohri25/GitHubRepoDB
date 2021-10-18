/****** Object:  Procedure [dbo].[Get_ChiefComplaint]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_ChiefComplaint] 

as

set nocount on
Select ID, Name From LookupChiefComplaint
Order By Name