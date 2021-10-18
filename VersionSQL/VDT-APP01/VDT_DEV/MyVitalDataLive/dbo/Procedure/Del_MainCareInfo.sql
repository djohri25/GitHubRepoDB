/****** Object:  Procedure [dbo].[Del_MainCareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_MainCareInfo]

@RecNum int

AS


SET NOCOUNT ON
DELETE MainCareInfo WHERE RecordNumber = @RecNum