/****** Object:  Function [dbo].[ETtoUTC]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Tim Thein
-- Create date: 9/22/2009
-- Description:	 Converts ET time to UTC considering daylight saving
-- =============================================
CREATE FUNCTION [dbo].[ETtoUTC](@etTime datetime)
RETURNS datetime
AS
BEGIN
	DECLARE @utcTime datetime

	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	IF dbo.InDST(@etTime) = 1
		SET @utcTime = DATEADD(HH, +4, @etTime)
	ELSE
		SET @utcTime = DATEADD(HH, +5, @etTime)
	RETURN @utcTime
END