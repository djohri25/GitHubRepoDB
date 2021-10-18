/****** Object:  Procedure [dbo].[MD_ResetPasswordAndSecQuestions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
create PROCEDURE [dbo].[MD_ResetPasswordAndSecQuestions]
	@Result int OUT,
	@Username varchar(50),
	@Password varchar(50),
	@SecurityQ1 int,
	@SecurityA1 varchar(50),
	@SecurityQ2 int,
	@SecurityA2 varchar(50),
	@SecurityQ3 int,
	@SecurityA3 varchar(50)
AS
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT TOP 1 ID FROM MDUser WHERE Username = @Username)
		SET @Result = -1
	else
	BEGIN
		update MDUser
		set Password = @Password,
			SecurityQ1 = @SecurityQ1,
			SecurityA1 = @SecurityA1,
			SecurityQ2 = @SecurityQ2,
			SecurityA2 = @SecurityA2,
			SecurityQ3 = @SecurityQ3,
			SecurityA3 = @SecurityA3,
			ForcePasswordReset = 0,
			ModifyDate = GETUTCDATE()
		where Username = @Username
			
		set @Result = 0
	END