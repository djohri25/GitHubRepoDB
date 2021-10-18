/****** Object:  Procedure [dbo].[SetImage]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.SetImage
	(
	@iceNumber varchar(15),
	@imageName nvarchar(256),
	@contentType varchar(64),
	@data varbinary(MAX),
	@dateModified datetime
	)
AS
BEGIN
	DECLARE @count int
	
	SELECT @count = COUNT(*)
	FROM MainImage
	WHERE ICENUMBER = @iceNumber
	
	IF @count = 0
		INSERT MainImage (ICENUMBER, ImageName, ContentType, Data, DateCreated, DateModified)
		VALUES (@iceNumber, @imageName, @contentType, @data, @dateModified, @dateModified)
	ELSE IF @count = 1
		UPDATE MainImage
		SET ImageName = @imageName, ContentType = @contentType, Data = @data, DateModified = @dateModified
		WHERE ICENUMBER = @iceNumber
	ELSE
		RETURN 1

	RETURN 0
END