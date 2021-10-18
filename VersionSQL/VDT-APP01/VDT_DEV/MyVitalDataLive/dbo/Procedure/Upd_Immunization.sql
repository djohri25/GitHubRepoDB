/****** Object:  Procedure [dbo].[Upd_Immunization]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_Immunization] 

	@RecNum int,
	@ImmunId int = NULL,
	@ImmunName nvarchar(127) = NULL,
	@DateDone datetime,
	@DateDue datetime,
	@DateApproximate bit

as
	SET NOCOUNT ON

	UPDATE MainImmunization
	SET DateDone = @DateDone, 
	DateDue = @DateDue, 
	ImmunId = @ImmunId,
	ImmunizationName = @ImmunName,
	DateApproximate = @DateApproximate,
	ModifyDate = GETUTCDATE()
	WHERE RecordNumber = @RecNum