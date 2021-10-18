/****** Object:  Procedure [dbo].[GetAvailableProfileCount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/15/2008
-- Description:	Retrieves increment
-- =============================================
CREATE PROCEDURE dbo.GetAvailableProfileCount
	@UserName VARCHAR(50),
	@Profiles INT = 0 OUTPUT
AS
BEGIN
	DECLARE @BillingEmail VARCHAR(100)
	
	SELECT @BillingEmail = BillingEmail
	FROM dbo.MainUserName
	WHERE UserName = @UserName
	
	SELECT @Profiles = sum(Delta)
	FROM AccountActivation
	WHERE Email = @BillingEmail AND Type = 'P'
END