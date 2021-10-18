/****** Object:  Procedure [dbo].[Del_Allergies]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Del_Allergies]

@RecNum int

as

set nocount on
Delete
From MainAllergies
Where RecordNumber = @RecNum