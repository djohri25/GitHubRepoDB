/****** Object:  Procedure [dbo].[Get_CallStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].Get_CallStatus

as

set nocount on

Select StatusID,StatusName From LookupCS_Status Order By StatusID