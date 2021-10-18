/****** Object:  Procedure [dbo].[Set_HealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_HealthTest]

@ICENUMBER varchar(15),
@TestId int,
@DateDone datetime

as

SET NOCOUNT ON

INSERT INTO MainHealthTest (ICENUMBER, TestId, DateDone, CreationDate, ModifyDate) 
	VALUES (@IceNumber, @TestId, @DateDone, GETUTCDATE(), GETUTCDATE())