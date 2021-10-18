/****** Object:  Procedure [dbo].[DecreaseAccountActivation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 1/19/2008
-- Description:	Inserts records into AccountActivation
-- =============================================
CREATE PROCEDURE dbo.DecreaseAccountActivation
	@Email nvarchar(100),
	@Accounts int = 0,
	@Profiles int = 0
AS
BEGIN
	IF @Accounts > 0
	INSERT AccountActivation (Email, Type, Delta, CreationDate)
	VALUES (@Email, 'A', -1 * @Accounts, GETUTCDATE())
	
	IF @Profiles > 0
	INSERT AccountActivation (Email, Type, Delta, CreationDate)
	VALUES (@Email, 'P', -1 * @Profiles, GETUTCDATE())
END