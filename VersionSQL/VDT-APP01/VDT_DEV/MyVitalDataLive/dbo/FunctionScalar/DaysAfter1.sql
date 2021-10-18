/****** Object:  Function [dbo].[DaysAfter1]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 01/12/2017
-- Description:	SELECT dbo.DaysAfter (90, GETDATE())
-- intentionally cloned to support workflow parser "not" vocabulary
-- =============================================

CREATE FUNCTION [dbo].[DaysAfter1]
(
	@Days INT--, @FromDate DATE = NULL
)
RETURNS DATE
AS
BEGIN
Declare @FromDate DATE
	--IF @FromDate IS NULL
		SET @FromDate = GETDATE()

	DECLARE @ReturnDate DATE

	SET @ReturnDate = DATEADD(DD, @Days, @FromDate)

	RETURN @ReturnDate

END