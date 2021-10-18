/****** Object:  Procedure [dbo].[Del_MainSpecialistInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_MainSpecialistInfo]

@RecNum int

as

set nocount on

Delete MainSpecialist
Where RecordNumber = @RecNum