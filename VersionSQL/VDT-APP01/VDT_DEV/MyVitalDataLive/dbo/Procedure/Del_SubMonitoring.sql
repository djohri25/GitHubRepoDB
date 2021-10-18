/****** Object:  Procedure [dbo].[Del_SubMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_SubMonitoring]

@RecNum int

as

SET NOCOUNT ON

DELETE SubMonitoring WHERE RecordNumber = @RecNum