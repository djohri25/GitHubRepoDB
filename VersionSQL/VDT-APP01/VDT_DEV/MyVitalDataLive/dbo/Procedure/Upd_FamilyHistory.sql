/****** Object:  Procedure [dbo].[Upd_FamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_FamilyHistory] 

	@IceNumber varchar(15),
	@FamilyHistoryId int,
	@NA bit,
	@Father bit,
	@Mother bit,
	@Sister bit,
	@Brother bit

as

	set nocount on

	DECLARE @Count int
	SELECT @Count = COUNT(*) FROM MainFamilyHistory WHERE IceNumber = @IceNumber 
	AND FamilyHistoryId = @FamilyHistoryId

	IF @Count = 0
		INSERT INTO MainFamilyHistory (ICENUMBER, FamilyHistoryId, NA, Father,
		Mother, Sister, Brother, CreationDate, ModifyDate) VALUES
		(@IceNumber, @FamilyHistoryId, @NA, @Father, @Mother, @Sister, @Brother,
		GETUTCDATE(), GETUTCDATE())
	ELSE
		UPDATE MainFamilyHistory SET
		NA = @NA,
		Father = @Father,
		Mother = @Mother,
		Brother = @Brother,
		Sister = @Sister,
		ModifyDate = GETUTCDATE()
		WHERE IceNumber = @IceNumber AND FamilyHistoryId = @FamilyHistoryId