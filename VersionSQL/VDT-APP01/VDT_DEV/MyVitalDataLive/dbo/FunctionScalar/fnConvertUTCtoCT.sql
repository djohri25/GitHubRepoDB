/****** Object:  Function [dbo].[fnConvertUTCtoCT]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[fnConvertUTCtoCT]
(@utcTime DATETIME)
RETURNS DATETIME
AS
BEGIN
	DECLARE @ctTime DATETIME
	
	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	SET @ctTime = DATEADD(HH, -6, @utcTime)
	IF dbo.InDST(@ctTime) = 1
		RETURN DATEADD(HH, +1, @ctTime)
	RETURN @ctTime
END