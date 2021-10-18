/****** Object:  Function [dbo].[ConcatenateHealthTestDates]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE
--
CREATE 
FUNCTION dbo.ConcatenateHealthTestDates(@IceNumber varchar(15), @TestID int)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @Output VARCHAR(8000)
	SELECT @Output = COALESCE(@Output+', ', '') + CONVERT(varchar(10), MHT.DateDone, 101)
	FROM	dbo.MainHealthTest MHT 
	JOIN dbo.LookupHealthTest LHT
	ON MHT.TestID = LHT.TestID
	WHERE	MHT.ICENUMBER = @IceNumber
	AND LHT.TestID = @TestID
	RETURN @Output
END