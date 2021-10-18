/****** Object:  Procedure [dbo].[Storage_DecreaseMax]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.Storage_DecreaseMax
	(
	@userName varchar(50),
	@delta int
	)
AS
BEGIN
	UPDATE MainUserName
	SET MaxAttachment = MaxAttachment - @delta, ModifyDate = GetUTCDate()
	WHERE UserName = @userName
END