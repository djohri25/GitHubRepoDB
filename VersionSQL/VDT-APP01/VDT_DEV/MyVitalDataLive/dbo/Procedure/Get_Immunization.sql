/****** Object:  Procedure [dbo].[Get_Immunization]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_Immunization] 
	@ICENUMBER varchar(15),
	@NoDups bit = 0
AS
BEGIN

	SET NOCOUNT ON

	IF @NoDups = 0
		SELECT     RecordNumber, ImmunId, DateDone, DateDue, DateApproximate, ISNULL
								  ((SELECT     ImmunName
									  FROM         LookupImmunization
									  WHERE     (MainImmunization.ImmunId = ImmunId)), ImmunizationName) AS ImmunName, CASE WHEN DateDone IS NULL OR
							  DateApproximate = 1 THEN NULL ELSE Day(DateDone) END AS Day1, CASE DateDone WHEN NULL THEN 0 ELSE Month(DateDone) END AS Month1, 
							  CASE DateDone WHEN NULL THEN '' ELSE Year(DateDone) END AS Year1, CASE WHEN DateDue IS NULL OR
							  DateApproximate = 1 THEN NULL ELSE Day(DateDue) END AS Day2, CASE DateDue WHEN NULL THEN 0 ELSE Month(DateDue) END AS Month2, 
							  CASE DateDue WHEN NULL THEN '' ELSE Year(DateDue) END AS Year2, ISNULL(ReadOnly, 0) AS ReadOnly
		FROM         MainImmunization
		WHERE     (ICENUMBER = @ICENUMBER)
	ELSE
	BEGIN
		SELECT RecordNumber, ICENUMBER, ImmunId, 
		     ImmunizationName, DateDone, DateDue, 
		     DateApproximate, CreationDate, ModifyDate, 
		     HVID, HVFlag, ReadOnly
		INTO #Immunization
		FROM MainImmunization
		WHERE (ICENUMBER = @ICENUMBER)
		
		DECLARE currentRow CURSOR FOR
		SELECT DISTINCT ISNULL
			  ((SELECT     ImmunName
				  FROM         LookupImmunization
				  WHERE     (MainImmunization.ImmunId = ImmunId)), ImmunizationName) AS ImmunizationName
		FROM MainImmunization
		WHERE (ICENUMBER = @ICENUMBER)
		ORDER BY ImmunizationName

		OPEN currentRow
		
		IF @@CURSOR_ROWS > 0
		BEGIN
			DECLARE @RecordNumber INT, @ImmunizationName NVARCHAR(127), @count INT
			
			WHILE 1 = 1
			BEGIN
				FETCH NEXT FROM currentRow INTO @ImmunizationName 
				IF @@FETCH_STATUS <> 0
					BREAK
				SELECT @count = count(*)
				FROM #Immunization
				WHERE ISNULL
				  ((SELECT     ImmunName
					  FROM         LookupImmunization
					  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName
				IF @count > 1
				BEGIN
					SELECT TOP (1) @RecordNumber = RecordNumber
					FROM #Immunization
					WHERE ISNULL
					  ((SELECT     ImmunName
						  FROM         LookupImmunization
						  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName
					ORDER BY DateDone DESC
					
					DELETE #Immunization
					WHERE (RecordNumber <> @RecordNumber) AND 
					     (ISNULL
							  ((SELECT     ImmunName
								  FROM         LookupImmunization
								  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName) 
				END
			END
		END
		CLOSE currentRow
		
		SELECT     RecordNumber, ImmunId, DateDone, DateDue, DateApproximate, ISNULL
						  ((SELECT     ImmunName
							  FROM         LookupImmunization
							  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) AS ImmunName, CASE WHEN DateDone IS NULL OR
					  DateApproximate = 1 THEN NULL ELSE Day(DateDone) END AS Day1, CASE DateDone WHEN NULL THEN 0 ELSE Month(DateDone) END AS Month1, 
					  CASE DateDone WHEN NULL THEN '' ELSE Year(DateDone) END AS Year1, CASE WHEN DateDue IS NULL OR
					  DateApproximate = 1 THEN NULL ELSE Day(DateDue) END AS Day2, CASE DateDue WHEN NULL THEN 0 ELSE Month(DateDue) END AS Month2, 
					  CASE DateDue WHEN NULL THEN '' ELSE Year(DateDue) END AS Year2, ISNULL(ReadOnly, 0) AS ReadOnly

		FROM #Immunization
		
		DROP TABLE #Immunization

	END
END