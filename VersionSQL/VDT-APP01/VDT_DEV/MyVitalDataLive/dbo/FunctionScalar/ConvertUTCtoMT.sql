/****** Object:  Function [dbo].[ConvertUTCtoMT]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: sw		
-- Create date: 11/25/2008
-- Description:	 Converts UTC time to PT considering daylight saving
-- =============================================
CREATE FUNCTION [dbo].[ConvertUTCtoMT](@utcTime DateTime)
RETURNS DateTime
AS
BEGIN
	declare @ptTime DateTime
	
	-- TODO: calculate subtracted value dynamically, instead of hard coding e.g. -8
	set @ptTime = dateadd(hh,-7, @utcTime)    
    
    RETURN @ptTime
END