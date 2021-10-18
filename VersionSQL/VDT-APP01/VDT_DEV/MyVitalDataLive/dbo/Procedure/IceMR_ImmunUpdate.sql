/****** Object:  Procedure [dbo].[IceMR_ImmunUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_ImmunUpdate]  

@ICENUMBER varchar(15),
@ImmunId int,
@DateDone datetime,
@DateDue datetime

AS

SET NOCOUNT ON

INSERT INTO MainImmunization
(ICENUMBER, ImmunId, DateDone, DateDue, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @ImmunId, @DateDone, @DateDue, GETUTCDATE(), GETUTCDATE())