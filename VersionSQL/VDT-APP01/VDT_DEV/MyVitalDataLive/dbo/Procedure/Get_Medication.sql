/****** Object:  Procedure [dbo].[Get_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_Medication]
	@ICENUMBER varchar(15),
	@NoDups bit = 0,
	@Language bit = 1
AS
BEGIN

	SET NOCOUNT ON

	IF @NoDups = 0
	BEGIN
		SELECT RecordNumber, DrugId,
			(SELECT TOP 1 
			CASE @Language 
				WHEN  1 
					THEN
						DrugName
				WHEN  0 
					THEN
						DrugNameSpanish
			END
			FROM LookupDrugType
			WHERE (DrugId = MainMedication.DrugId)) AS DrugName, 
			'Medication' AS MobileDescription, StartDate, StopDate, RefillDate, ISNULL(PrescribedBy, '') AS PrescribedBy, ISNULL(RxDrug, '') AS RxDrug, 
			ISNULL(RxPharmacy, '') AS RxPharmacy, ISNULL(HowMuch, '') AS HowMuch, ISNULL(HowOften, '') AS HowOften, ISNULL(WhyTaking, '') AS WhyTaking, 
			ApproxDate, 
			MONTH(StartDate) AS MonStart, YEAR(StartDate) AS YearStart, DAY(StartDate) AS DayStart, 
			MONTH(StopDate) AS MonStop, YEAR(StopDate) AS YearStop, DAY(StopDate) AS DayStop, 
			MONTH(RefillDate) AS MonRefill, YEAR(RefillDate) AS YearRefill, DAY(RefillDate) AS DayRefill, 
			ISNULL(ReadOnly, 0) AS ReadOnly, ISNULL(Strength, '') AS Strength, ISNULL(Route, '') AS Route
		FROM MainMedication
		WHERE (ICENUMBER = @ICENUMBER)
	END
	ELSE
	BEGIN
		SELECT RecordNumber, ICENUMBER, StartDate, 
		     StopDate,RefillDate, PrescribedBy, DrugId, RxDrug, 
		     RxPharmacy, HowMuch, HowOften, 
		     WhyTaking, HVID, CreationDate, ModifyDate, 
		     ApproxDate, HVFlag, ReadOnly, Strength, Route
		INTO [#Medication]
		FROM MainMedication
		WHERE (ICENUMBER = @ICENUMBER)

		DECLARE currentRow CURSOR FOR
			SELECT DISTINCT RxDrug
			FROM MainMedication
			WHERE (ICENUMBER = @ICENUMBER)
			ORDER BY RxDrug

		OPEN currentRow

		IF @@CURSOR_ROWS > 0
		BEGIN
			DECLARE @RecordNumber INT, @RxDrug VARCHAR(50), @count INT

			WHILE 1 = 1
			BEGIN
				FETCH NEXT FROM currentRow INTO @RxDrug
				IF @@FETCH_STATUS <> 0
					BREAK
				SELECT @count = count(*)
				FROM #Medication
				WHERE RxDrug = @RxDrug
				IF @count > 1
				BEGIN
					SELECT TOP (1) @RecordNumber = RecordNumber
					FROM #Medication
					WHERE (RxDrug = @RxDrug)
					ORDER BY ModifyDate DESC

					DELETE #Medication
					WHERE (RecordNumber <> @RecordNumber) AND 
					     (RxDrug = @RxDrug) 
				END
			END
		END

		CLOSE currentRow

		SELECT RecordNumber, DrugId,
			(SELECT DrugName
			FROM LookupDrugType
			WHERE (DrugId = #Medication.DrugId)) AS DrugName, 
			'Medication' AS MobileDescription, StartDate, StopDate, RefillDate, ISNULL(PrescribedBy, '') AS PrescribedBy, ISNULL(RxDrug, '') AS RxDrug, 
			ISNULL(RxPharmacy, '') AS RxPharmacy, ISNULL(HowMuch, '') AS HowMuch, ISNULL(HowOften, '') AS HowOften, ISNULL(WhyTaking, '') AS WhyTaking, 
			ApproxDate, 
			MONTH(StartDate) AS MonStart, YEAR(StartDate) AS YearStart, DAY(StartDate) AS DayStart, 
			MONTH(StopDate) AS MonStop, YEAR(StopDate) AS YearStop, DAY(StopDate) AS DayStop, 
			MONTH(RefillDate) AS MonRefill, YEAR(RefillDate) AS YearRefill, DAY(RefillDate) AS DayRefill, 
			ISNULL(ReadOnly, 0) AS ReadOnly, ISNULL(Strength, '') AS Strength, ISNULL(Route, '') AS Route
		FROM #Medication

		DROP TABLE #Medication
	END
END