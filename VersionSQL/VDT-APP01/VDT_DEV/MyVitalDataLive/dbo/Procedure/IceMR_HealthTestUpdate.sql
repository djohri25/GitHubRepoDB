/****** Object:  Procedure [dbo].[IceMR_HealthTestUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_HealthTestUpdate]  

@ICENUMBER varchar(15),
@TestId int,
@DateDone datetime

AS


SET NOCOUNT ON

INSERT INTO MainHealthTest (ICENUMBER, TestId, DateDone, CreationDate, ModifyDate) 
VALUES (@ICENUMBER, @TestId, @DateDone, GETUTCDATE(), GETUTCDATE())