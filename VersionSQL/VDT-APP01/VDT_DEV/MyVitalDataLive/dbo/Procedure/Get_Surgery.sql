/****** Object:  Procedure [dbo].[Get_Surgery]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_Surgery] 
	@ICENUMBER varchar(15),
	@NoDups bit = 0
AS
BEGIN

	SET NOCOUNT ON

	IF @NoDups = 0
	BEGIN
		SELECT RecordNumber, YearDate, Condition, 
		     Treatment, 'Surgery' AS MobileDescription, 
		     MONTH(YearDate) AS Mon1, YEAR(YearDate) 
		     AS Year1, DAY(YearDate) AS Day1, 
		     ISNULL(ReadOnly, 0) AS ReadOnly
		FROM MainSurgeries
		WHERE (ICENUMBER = @ICENUMBER)
	END
	ELSE
	BEGIN
		SELECT RecordNumber, ICENUMBER, YearDate, 
		     Condition, Treatment, HVID, CreationDate, 
		     ModifyDate, HVFlag, ReadOnly
		INTO #Surgeries
		FROM MainSurgeries
		
		DECLARE currentRow CURSOR FOR
			SELECT DISTINCT Treatment, YearDate
			FROM MainSurgeries
			WHERE (ICENUMBER = @ICENUMBER)
			ORDER BY YearDate, Treatment

		OPEN currentRow
		
		IF @@CURSOR_ROWS > 0
		BEGIN
			DECLARE @RecordNumber INT, @Treatment VARCHAR(50), @YearDate DATETIME, @count INT
			
			WHILE 1 = 1
			BEGIN
				FETCH NEXT FROM currentRow INTO @Treatment, @YearDate
				IF @@FETCH_STATUS <> 0
					BREAK
				SELECT @count = count(*)
				FROM #Surgeries
				WHERE Treatment = @Treatment AND YearDate = @YearDate
				IF @count > 1
				BEGIN
					SELECT TOP (1) @RecordNumber = RecordNumber
					FROM #Surgeries
					WHERE (Treatment = @Treatment) AND (YearDate = @YearDate)
					ORDER BY ModifyDate DESC
					
					DELETE #Surgeries
					WHERE (RecordNumber <> @RecordNumber) AND 
					     (Treatment = @Treatment) AND (YearDate = @YearDate) 
				END
			END
		END
		
		CLOSE currentRow
		
		SELECT RecordNumber, YearDate, Condition, 
		     Treatment, 'Surgery' AS MobileDescription, 
		     MONTH(YearDate) AS Mon1, YEAR(YearDate) 
		     AS Year1, DAY(YearDate) AS Day1, 
		     ISNULL(ReadOnly, 0) AS ReadOnly
		FROM #Surgeries
		
		DROP TABLE #Surgeries
	END
END