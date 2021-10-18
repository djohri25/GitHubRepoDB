/****** Object:  Procedure [dbo].[Set_LivingArrangements]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_LivingArrangements]

@ICENUMBER varchar(15),
@LivingWithId int,
@ContactName varchar(50),
@ContactPhone varchar(10)

as

Set NoCount On

Insert Into MainLivingArrangements (ICENUMBER, LivingWithId, ContactName,
ContactPhone, CreationDate) Values (@ICENUMBER, @LivingWithId, @ContactName,
@ContactPhone, GETUTCDATE())