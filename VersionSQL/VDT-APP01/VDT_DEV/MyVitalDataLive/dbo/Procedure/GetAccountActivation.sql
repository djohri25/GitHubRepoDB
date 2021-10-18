/****** Object:  Procedure [dbo].[GetAccountActivation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 1/19/2008
-- Description:	Retrieves increment
-- =============================================
CREATE PROCEDURE [dbo].[GetAccountActivation]
	@Email nvarchar(100),
	@Accounts int = 0 OUT,
	@Profiles int = 0 OUT
AS
BEGIN
	SELECT @Accounts = sum(Delta)
	FROM AccountActivation
	WHERE Email = @Email AND Type = 'A'
	
	SELECT @Profiles = sum(Delta)
	FROM AccountActivation
	WHERE Email = @Email AND Type = 'P'
END