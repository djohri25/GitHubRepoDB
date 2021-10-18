/****** Object:  Function [dbo].[UTCtoET]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Tim Thein
-- Create date: 9/22/2009
-- Description:	 Converts UTC time to ET considering daylight saving
-- =============================================
CREATE FUNCTION [dbo].[UTCtoET](@utcTime datetime)
RETURNS datetime
AS
BEGIN
	DECLARE @etTime datetime
	
	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	SET @etTime = DATEADD(HH, -5, @utcTime)
	IF dbo.InDST(@etTime) = 1
		RETURN DATEADD(HH, +1, @etTime)
	RETURN @etTime
END