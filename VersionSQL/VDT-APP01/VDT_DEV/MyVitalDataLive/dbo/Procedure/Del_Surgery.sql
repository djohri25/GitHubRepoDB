/****** Object:  Procedure [dbo].[Del_Surgery]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_Surgery]

@RecNum int

AS

SET NOCOUNT ON
DELETE  MainSurgeries WHERE RecordNumber = @RecNum