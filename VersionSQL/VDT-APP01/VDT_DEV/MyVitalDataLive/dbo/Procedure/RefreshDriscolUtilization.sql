/****** Object:  Procedure [dbo].[RefreshDriscolUtilization]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RefreshDriscolUtilization]
AS
BEGIN
	SET NOCOUNT ON;

	--CREATE TABLE dbo.DriscolUtilization (Yr INT, Mon CHAR(2), Numer INT, Denom INT, Login VARCHAR(25), MeasureType VARCHAR(10), SubCat VARCHAR(25))

	DECLARE @StartDate DATE = '1/1/2014', @EndDate DATE = DATEFROMPARTS(YEAR(GETDATE()), '12', '31')

	TRUNCATE TABLE dbo.DriscolUtilization;

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'AWC', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 50

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'AWC', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 10

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'AWC', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 0

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W34', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 50

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W34', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 10

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W34', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 0

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W15', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 50

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W15', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 10

	INSERT INTO dbo.DriscolUtilization (Yr, Mon, Numer, Denom, [Login], MeasureType, SubCat)
	EXEC dbo.DriscollUtilization @Measure = 'W15', @StartDate = @StartDate, @EndDate = @EndDate, @Denom = 0

END