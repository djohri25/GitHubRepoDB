/****** Object:  Procedure [dbo].[Upd_HealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_HealthTest]

@RecNum int,
@DateDone datetime

as

SET NOCOUNT ON



UPDATE MainHealthTest
SET 
DateDone = @DateDone, 
ModifyDate = GETUTCDATE()
WHERE RecordNumber = @RecNum