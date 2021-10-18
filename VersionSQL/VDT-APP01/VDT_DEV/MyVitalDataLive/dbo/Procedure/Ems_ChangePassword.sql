/****** Object:  Procedure [dbo].[Ems_ChangePassword]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Ems_ChangePassword]
	@Email varchar(50),
	@OldPwd varchar(50),
	@NewPwd varchar(50),
	@Result int OUT
AS

	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM MainEMS WHERE Email = @Email AND Password = @OldPwd)
	BEGIN
		UPDATE MainEMS SET Password = @NewPwd,
		ModifyDate = GETUTCDATE()		
		WHERE Email = @Email AND Password = @OldPwd
		SET @Result = 1
	END
	ELSE
		SET @Result = 0
		