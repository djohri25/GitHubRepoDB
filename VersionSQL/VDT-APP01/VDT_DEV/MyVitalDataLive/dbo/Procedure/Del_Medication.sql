/****** Object:  Procedure [dbo].[Del_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_Medication]

@RecNum int

as

SET NOCOUNT ON

DELETE MainMedication WHERE RecordNumber = @RecNum