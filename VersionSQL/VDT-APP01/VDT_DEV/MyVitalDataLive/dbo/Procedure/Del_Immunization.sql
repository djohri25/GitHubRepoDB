/****** Object:  Procedure [dbo].[Del_Immunization]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_Immunization]

@RecNum int

AS

SET NOCOUNT ON
DELETE MainImmunization WHERE RecordNumber = @RecNum