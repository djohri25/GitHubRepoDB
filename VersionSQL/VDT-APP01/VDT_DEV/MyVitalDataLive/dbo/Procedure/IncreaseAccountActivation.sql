/****** Object:  Procedure [dbo].[IncreaseAccountActivation]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[IncreaseAccountActivation]
@Email NVARCHAR (100), @Accounts INT=0, @Profiles INT=0, @Years INT=0, @OrderTransactionID VARCHAR (50)=null
AS
BEGIN
	IF @Accounts > 0
	INSERT AccountActivation (Email, Type, Delta, Years, CreationDate,OrderTransactionID)
	VALUES (@Email, 'A', @Accounts, @Years, GETUTCDATE(), @OrderTransactionID)
	
	IF @Profiles > 0
	INSERT AccountActivation (Email, Type, Delta, Years, CreationDate)
	VALUES (@Email, 'P', @Profiles, @Years, GETUTCDATE())
END