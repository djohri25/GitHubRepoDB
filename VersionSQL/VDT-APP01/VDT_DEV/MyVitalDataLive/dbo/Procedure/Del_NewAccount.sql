/****** Object:  Procedure [dbo].[Del_NewAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_NewAccount]

	@Email varchar(50),
	@BillingEmail nvarchar(100)

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IceGrp varchar(10)

	SELECT @IceGrp = ICEGROUP FROM MainUserName WHERE UserName = @Email

	DELETE MainUserName WHERE UserName = @Email

	EXEC IncreaseAccountActivation @BillingEmail, 1, 0
END