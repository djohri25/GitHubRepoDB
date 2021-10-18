/****** Object:  Procedure [dbo].[Get_CallCategory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].Get_CallCategory

as

set nocount on

Select CategoryID,CategoryName From LookupCS_Category Order By CategoryId