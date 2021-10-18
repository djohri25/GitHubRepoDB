/****** Object:  Procedure [dbo].[IceMR_LivingUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_LivingUpdate]  

@ICENUMBER varchar(15),
@LivingWithID int,
@ContactName varchar(50),
@ContactPhone varchar(10)
AS

SET NOCOUNT ON

INSERT INTO MainLivingArrangements
(ICENUMBER, LivingWithID, ContactName, ContactPhone, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @LivingWithID, @ContactName, @ContactPhone, GETUTCDATE(), GETUTCDATE())