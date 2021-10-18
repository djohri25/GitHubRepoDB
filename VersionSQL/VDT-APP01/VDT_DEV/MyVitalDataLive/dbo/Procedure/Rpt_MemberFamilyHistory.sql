/****** Object:  Procedure [dbo].[Rpt_MemberFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

--SELECT * FROM LookupFamilyHistoryID
--SELECT * FROM MainFamilyHistory
--SELECT * FROM SubFamilyHistory
--CREATE 
--
CREATE 
Procedure [dbo].[Rpt_MemberFamilyHistory] 
	@IceNumber varchar(15)
as
	DECLARE @COUNT INT
	SET @COUNT = 0
	SELECT FamilyHistoryID,FamilyHistoryName [Name], CONVERT(bit, 0) AS NotApplicable , CONVERT(bit, 0) AS Father,
	CONVERT(bit, 0) AS Mother, CONVERT(bit, 0) AS Sister, CONVERT(bit, 0) AS Brother,
	CONVERT(bit, 0) AS FatherDeceased, CONVERT(bit, 0) AS MotherDeceased,
	CONVERT(varchar(3), null) AS Anesthesia, CONVERT(int, null) AS YearFather,CONVERT(int, null) AS YearMother,
	CONVERT(varchar(250), null) AS Note, CONVERT(varchar(3), null) AS MonthFather,
	CONVERT(varchar(3), null) AS MonthMother,CONVERT(varchar(3), null) AS MonthFatherDeceased,
	CONVERT(varchar(3), null) AS MonthMotherDeceased,CONVERT(int, null) AS YearFatherDeceased,
	CONVERT(int, null) AS YearMotherDeceased, CONVERT(varchar(15), null) AS IceNumber
	INTO #TmpFamily	
	FROM LookupFamilyHistoryID 
	WHERE FamilyHistoryID IN (SELECT FamilyHistoryID FROM 
	MainFamilyHistory WHERE IceNumber = @IceNumber
	AND (NA = 1 OR Father = 1 OR Mother = 1 OR Sister = 1 OR Brother = 1))
	SELECT @COUNT = COUNT(*) FROM #TmpFamily
	IF @COUNT > 0
		BEGIN
			UPDATE #TmpFamily
			SET NotApplicable = MFH.NA,
			Father = MFH.Father,
			Mother = MFH.Mother,
			Sister = MFH.Sister,
			Brother = MFH.Brother,
			FatherDeceased = SFH.FatherAlive,
			MotherDeceased = SFH.MotherAlive,
			Anesthesia = (CASE SFH.Anesthesia WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END),
			YearFather = SFH.FatherAge,
			YearMother = SFH.MotherAge,
			Note = SFH.Note,
			MonthFather = SFH.MonthFather,
			MonthMother = SFH.MonthMother,
			MonthFatherDeceased = SFH.MonthFatherDeceased,
			MonthMotherDeceased = SFH.MonthMotherDeceased,
			YearFatherDeceased = SFH.YearFatherDeceased,
			YearMotherDeceased = SFH.YearMotherDeceased,
			IceNumber = @IceNumber
			FROM MainFamilyHistory AS MFH 
			JOIN SubFamilyHistory SFH ON MFH.ICENUMBER = SFH.ICENUMBER
			WHERE MFH.ICENUMBER = @IceNumber AND
			MFH.FamilyHistoryId = #TmpFamily.FamilyHistoryId	
			SELECT * FROM #TmpFamily
		END
	ELSE
		BEGIN
			SELECT 
			[Name] = 'No Family History Available',
			NotApplicable = NULL,
			Father = NULL,
			Mother = NULL,
			Sister = NULL,
			Brother = NULL,
			FatherDeceased = SFH.FatherAlive,
			MotherDeceased = SFH.MotherAlive,
			Anesthesia = (CASE SFH.Anesthesia WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END),
			YearFather = SFH.FatherAge,
			YearMother = SFH.MotherAge,
			Note = SFH.Note,
			MonthFather = SFH.MonthFather,
			MonthMother = SFH.MonthMother,
			MonthFatherDeceased = SFH.MonthFatherDeceased,
			MonthMotherDeceased = SFH.MonthMotherDeceased,
			YearFatherDeceased = SFH.YearFatherDeceased,
			YearMotherDeceased = SFH.YearMotherDeceased,
			IceNumber = @IceNumber
			FROM SubFamilyHistory SFH
			WHERE SFH.ICENUMBER = @IceNumber
			AND SFH.FatherAlive IS NOT NULL	
		END
	
	DROP TABLE #TmpFamily