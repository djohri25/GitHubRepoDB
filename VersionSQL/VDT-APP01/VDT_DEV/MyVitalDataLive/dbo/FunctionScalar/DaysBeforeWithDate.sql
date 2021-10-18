/****** Object:  Function [dbo].[DaysBeforeWithDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 01/12/2017
-- Description:	SELECT dbo.DaysBefore (-90, GETDATE())
-- =============================================
CREATE FUNCTION [dbo].[DaysBeforeWithDate]
(
	@Days INT, @FromDate DATE 
)
RETURNS DATE	
AS
BEGIN
--Declare  @FromDate DATE
	--IF @FromDate IS NULL
		--SET @FromDate = GETDATE()

	DECLARE @ReturnDate DATE

	SET @ReturnDate = DATEADD(DD, -@Days, @FromDate)

	RETURN @ReturnDate

END