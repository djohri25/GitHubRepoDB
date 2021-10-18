/****** Object:  Procedure [dbo].[Del_LivingArrangements]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_LivingArrangements]

@RecNum int

as

set nocount on
Delete
MainLivingArrangements
Where RecordNumber = @RecNum