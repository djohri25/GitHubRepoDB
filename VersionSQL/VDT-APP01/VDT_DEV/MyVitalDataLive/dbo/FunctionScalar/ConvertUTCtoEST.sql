/****** Object:  Function [dbo].[ConvertUTCtoEST]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: sw		
-- Create date: 11/25/2008
-- Description:	 Converts UTC time to EST considering daylight saving
-- =============================================
CREATE FUNCTION dbo.ConvertUTCtoEST(@utcTime DATETIME)
RETURNS DATETIME
AS
BEGIN
	DECLARE @etTime DATETIME
	
	-- IMPORTANT: when you change this function, change same function in MVD_Reports database as well
	SET @etTime = DATEADD(HH, -5, @utcTime)
	IF dbo.InDST(@etTime) = 1
		RETURN DATEADD(HH, +1, @etTime)
	RETURN @etTime
END