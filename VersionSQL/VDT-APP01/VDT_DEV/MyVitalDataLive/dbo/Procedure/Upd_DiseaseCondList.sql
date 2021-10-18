/****** Object:  Procedure [dbo].[Upd_DiseaseCondList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_DiseaseCondList]

@ICENUMBER varchar(15),
@DiseaseCondId int,
@Checked bit
As

SET NOCOUNT ON

BEGIN

	DECLARE @DiseaseId int, @Count int
	
	IF @Checked = 1
	BEGIN
		SELECT @Count = COUNT(*) FROM MainDiseaseCond WHERE 
		ICENUMBER = @IceNumber AND DiseaseCondId = @DiseaseCondId
		IF @Count = 0
		BEGIN
		
			SELECT @DiseaseId = DiseaseId FROM LookupDiseaseCond WHERE 
			DiseaseCondId = @DiseaseCondId
						
			INSERT INTO MainDiseaseCond (ICENUMBER, DiseaseCondId, DiseaseId, CreationDate,
			ModifyDate) VALUES (@ICENUMBER, @DiseaseCondId , @DiseaseId , GETUTCDATE(), GETUTCDATE())
		END
	END
	ELSE
		DELETE MainDiseaseCond WHERE ICENUMBER = @IceNumber AND DiseaseCondId = @DiseaseCondId
END