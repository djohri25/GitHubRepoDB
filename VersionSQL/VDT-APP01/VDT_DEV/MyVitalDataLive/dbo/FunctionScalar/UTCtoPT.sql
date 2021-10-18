/****** Object:  Function [dbo].[UTCtoPT]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Tim Thein
-- Create date: 4/30/2009
-- Description:	 Converts UTC time to PT considering daylight saving
-- =============================================
CREATE FUNCTION [dbo].[UTCtoPT](@utcTime datetime)
RETURNS datetime
AS
BEGIN
	DECLARE @ptTime datetime
	
	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	SET @ptTime = DATEADD(HH, -8, @utcTime)
	IF dbo.InDST(@ptTime) = 1
		RETURN DATEADD(HH, +1, @ptTime)
	RETURN @ptTime
END