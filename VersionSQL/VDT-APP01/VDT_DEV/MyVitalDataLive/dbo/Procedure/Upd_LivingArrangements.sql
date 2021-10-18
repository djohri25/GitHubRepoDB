/****** Object:  Procedure [dbo].[Upd_LivingArrangements]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_LivingArrangements]

@RecNum int,
@ContactName varchar(50),
@ContactPhone char(10)


As

Set Nocount On

Update MainLivingArrangements 
Set 
ContactName = @ContactName,
ContactPhone = @ContactPhone,
ModifyDate = GETUTCDATE()
Where RecordNumber = @RecNum