/****** Object:  Function [dbo].[ConvertMTtoUTC]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[ConvertMTtoUTC]
(@ctTime DATETIME)
RETURNS DATETIME
AS
BEGIN
	DECLARE @utcTime DATETIME
	
	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	SET @utcTime = DATEADD(HH, 7, @ctTime)
	IF dbo.InDST(@utcTime) = 1
		RETURN DATEADD(HH, -1, @utcTime)
	RETURN @utcTime
END