/****** Object:  Procedure [dbo].[sp_GetMeasureNote]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_GetMeasureNote]
(
	@mvdid varchar(500),
	@Abb varchar(500)
)
AS
BEGIN
	DECLARE @setval varchar(500)
	DECLARE @name varchar(500)
	DECLARE @Abb_Temp varchar(250)
	DECLARE @Abbreviations TABLE (ID int Identity (1,1), Abbreviation varchar(50))
	DECLARE @ID int, @Abbreviation varchar(50)

	CREATE TABLE #Note_Results
	(Major varchar(500), Minor varchar(500))

	SELECT @Abb_Temp = @Abb
	INSERT INTO @Abbreviations
	SELECT LTRIM(RTRIM(item))
	FROM [dbo].[splitstring](@Abb_Temp, ',')

	WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
	BEGIN
		SELECT TOP 1  @ID = ID, @Abbreviation = Abbreviation FROM @Abbreviations

		SELECT @name = [Name]
		FROM [dbo].[HedisSubmeasures]
		WHERE [Abbreviation] = @Abbreviation

		SELECT @setval = [dbo].[Get_HEDISMeasureNote] (@Abbreviation, @mvdid)
		
		INSERT #Note_Results
			SELECT @name + '.' + @setval AS Major, '' AS Minor

		DELETE @Abbreviations WHERE ID = @ID
	END

	SELECT * FROM #Note_Results
END