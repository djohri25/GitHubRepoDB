/****** Object:  Procedure [dbo].[GetImage]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.GetImage
	(
	@iceNumber varchar(15),
	@imageName nvarchar(256) OUTPUT,
	@contentType varchar(64) OUTPUT,
	@data varbinary(MAX) OUTPUT,
	@dateModified datetime OUTPUT
	)
AS
BEGIN
	SELECT @imageName = ImageName, @contentType = ContentType, @data = Data, @dateModified = DateModified
	FROM MainImage
	WHERE ICENUMBER = @iceNumber
END