/****** Object:  Procedure [dbo].[IceMR_FamilyHistorySubUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_FamilyHistorySubUpdate] 

	@IceNumber varchar(15),
	@FatherAge int,
	@MotherAge int,
	@Anesthesia bit,
	@Note varchar(250)

as
	SET NOCOUNT ON
	DECLARE @Count int
	
	SELECT @Count = COUNT(*) FROM SubFamilyHistory WHERE IceNumber = @IceNumber


	IF @Count = 0
		INSERT INTO SubFamilyHistory(IceNumber, FatherAge, MotherAge, Anesthesia, Note, CreationDate, ModifyDate) 
		VALUES(@IceNumber, @FatherAge, @MotherAge, @Anesthesia, @Note, GETUTCDATE(), GETUTCDATE())

	ELSE
		UPDATE SubFamilyHistory
		SET FatherAge = @FatherAge, MotherAge = @MotherAge, Anesthesia = @Anesthesia, Note = @Note, ModifyDate = GETUTCDATE()
		WHERE IceNumber = @IceNumber