/****** Object:  Procedure [dbo].[Get_EMSSecurityQuestion]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Get_EMSSecurityQuestion]
	@Email varchar(100),
	@SecurityQuestion int OUT
As

SET NOCOUNT ON

	SELECT @SecurityQuestion = SecureQu FROM MainEMS WHERE Email = @Email 