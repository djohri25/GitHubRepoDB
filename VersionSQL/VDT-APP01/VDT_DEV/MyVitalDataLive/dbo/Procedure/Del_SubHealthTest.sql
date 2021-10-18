/****** Object:  Procedure [dbo].[Del_SubHealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_SubHealthTest]

@RecNum int

as

SET NOCOUNT ON

DELETE MainHealthTest WHERE RecordNumber = @RecNum