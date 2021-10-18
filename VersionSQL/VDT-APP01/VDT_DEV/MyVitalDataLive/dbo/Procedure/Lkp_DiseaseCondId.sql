/****** Object:  Procedure [dbo].[Lkp_DiseaseCondId]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE  PROCEDURE [dbo].[Lkp_DiseaseCondId]
	@DiseaseId int,
	@CondName varchar(50),
	@CondId int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @CondId = DiseaseCondId FROM LookupDiseaseCond WHERE 
	DiseaseId = @DiseaseId AND DiseaseCondName = @CondName
	IF @CondId IS NULL SET @CondId = 0
END