/****** Object:  Function [dbo].[SplitMeasuresToRows]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 03/11/2010
-- Description:	Returns a table with input measures separated into rows
-- =============================================
CREATE FUNCTION [dbo].[SplitMeasuresToRows]
(
	@memberID varchar(10), 
	@measures nvarchar(4000)
)
RETURNS 
@resultTable TABLE 
(
	MemberID varchar(10), 
	Major nvarchar(100),
	Minor nvarchar(100)
)
AS
BEGIN
	DECLARE @measure nvarchar(200)
	DECLARE	@major nvarchar(100)
	DECLARE @minor nvarchar(100)
	DECLARE @start int
	DECLARE @len int
	DECLARE @index int
	
	SET	@start = 0
	SET @len = LEN(@measures)

	WHILE @start < @len
	BEGIN
		SET @index = CHARINDEX(';', @measures, @start)
		IF @index = 0
			BREAK
		SET @major = SUBSTRING(@measures, @start, @index - @start)
		SET @start = @index + 1
		SET @index = CHARINDEX('|', @measures, @start)
		IF @index = 0
			BREAK
		SET @minor = SUBSTRING(@measures, @start, @index - @start)
		SET @start = @index + 1
		INSERT @resultTable (MemberID, Major, Minor)
		VALUES (@memberID, @major, @minor)
	END

	RETURN 
END