/****** Object:  Function [dbo].[CheckedImg]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[CheckedImg](@Required bit)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @ImgLink varchar(30)
	IF @Required = 0 
		SET @ImgLink = 'Images/unchecked.gif'
	ELSE 
		SET @ImgLink = 'Images/checked.gif'
	
	RETURN @ImgLink
	
END