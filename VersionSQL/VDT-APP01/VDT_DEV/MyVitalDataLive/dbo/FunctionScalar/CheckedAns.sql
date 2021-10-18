/****** Object:  Function [dbo].[CheckedAns]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[CheckedAns](@Required bit)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @ImgLink varchar(30)
	IF @Required = 0 
		SET @ImgLink = 'No'
	ELSE 
		IF @Required = 1
			SET @ImgLink = 'Yes'
		ELSE
			SET @ImgLink = NULL
	RETURN @ImgLink
	
END