/****** Object:  Procedure [dbo].[Storage_IncreaseMax]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.Storage_IncreaseMax
	(
	@userName varchar(50),
	@delta int
	)
AS
BEGIN
	UPDATE MainUserName
	SET MaxAttachment = MaxAttachment + @delta, ModifyDate = GetUTCDate()
	WHERE UserName = @userName
END