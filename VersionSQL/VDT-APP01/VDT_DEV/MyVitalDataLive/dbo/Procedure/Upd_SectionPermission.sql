/****** Object:  Procedure [dbo].[Upd_SectionPermission]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Upd_SectionPermission]
	@IceNumber Varchar(15),
	@SectionId int,
	@IsPermitted bit
AS

	SET NOCOUNT ON

	DECLARE @Count int
	SELECT @Count = COUNT(*) FROM SectionPermission WHERE IceNumber = @IceNumber 
			AND SectionID = @SectionId

	IF @Count = 0
		INSERT INTO SectionPermission (ICENUMBER,SectionID,IsPermitted,CreationDate,ModifyDate) 
			VALUES(@IceNumber,@SectionID,@IsPermitted,GETUTCDATE(),GETUTCDATE())
	ELSE
		UPDATE SectionPermission SET
			IsPermitted = @IsPermitted,
			ModifyDate = GETUTCDATE()
		WHERE ICENUMBER = @IceNumber AND SectionID = @SectionId