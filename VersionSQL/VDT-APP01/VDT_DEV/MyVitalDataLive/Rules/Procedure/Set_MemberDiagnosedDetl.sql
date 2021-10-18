/****** Object:  Procedure [Rules].[Set_MemberDiagnosedDetl]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC [Rules].[Set_MemberDiagnosedDetl]
(
	@CustID		INT = NULL
)

AS 
BEGIN
SET NOCOUNT ON;
--Declare @CustID INT 
--SET @CustID = NULL

	IF OBJECT_ID('tempDB.dbo.#DSCodes','U') is not null
	Drop table #DSCodes
	Create table #DSCodes
	(
		Code	VARCHAR(30)
	)
	INSERT INTO #DSCodes
	SELECT distinct Code FROM [dbo].[HEDISValueSetsToCodes2017]
	WHERE [value set name] in ('Diabetes',
								'Diabetes Diagnosis',
								'Diabetes Long Term Complications',
								'Diabetes Mellitus Without Complications',
								'Diabetes Short Term Complications',
								'Diabetic Retinal Screening',
								'Diabetic Retinal Screening Negative',
								'Diabetic Retinal Screening With Eye Care Professional'
							 )


	IF OBJECT_ID('tempDB.dbo.#HTNCodes','U') is not null
	Drop table #HTNCodes
	Create table #HTNCodes
	(
		Code	VARCHAR(30)
	)
	INSERT INTO #HTNCodes
	SELECT distinct Code FROM [dbo].[HEDISValueSetsToCodes2017]
	WHERE [value set name] in ('Essential Hypertension','Hypertension')

	IF OBJECT_ID('tempDB.dbo.#ASMCodes','U') is not null
	Drop table #ASMCodes
	Create table #ASMCodes
	(
		Code	VARCHAR(30)
	)
	INSERT INTO #ASMCodes
	SELECT distinct Code FROM [dbo].[HEDISValueSetsToCodes2017]
	WHERE [value set name] in ('Asthma Diagnosis','Asthma')


	IF OBJECT_ID('tempDB.dbo.#MDCodes','U') is not null
	Drop table #MDCodes
	Create table #MDCodes
	(
		Code	VARCHAR(30)
	)
	INSERT INTO #MDCodes
	SELECT distinct Code FROM [dbo].[HEDISValueSetsToCodes2017]
	WHERE [value set name] in ('Depression Encounter','Major Depression','Major Depression and Dysthymia', 'Bipolar Disorder','Bipolar Disorder ECDS','Other Bipolar Disorder''Other Psychotic Disorders','Psychiatry','Psychosis','Psychosocial Care','Psychotic Disorders','Schizophrenia', 'Mental and Behavioral Disorders')



	IF OBJECT_ID('tempDB.dbo.#First_Diagnosed','U') is not null
	Drop table #First_Diagnosed
	Create Table #First_Diagnosed
	(
		ICENUMBER		VARCHAR(30),
		MemberID		VARCHAR(30),
		Cust_ID			INT,
		DIA_1stDiagDate	Datetime,
		HTN_1stDiagDate	Datetime,
		ASM_1stDiagDate Datetime,
		--MD_1stDiagDate	Datetime,
		--BP_1stDiagDate Datetime,
		--PSYC_1stDiagDate Datetime,
		BH_1stDiagDate	Datetime
	)
	-- DIA
	INSERT INTO #First_Diagnosed (ICENUMBER, MemberID, Cust_ID, DIA_1stDiagDate )
	SELECT A.ICENUMBER, A.MemberID, A.Cust_ID, A.ReportDate 
	FROM (
			Select ICENUMBER, L.InsMemberID as MemberID, L.Cust_ID, ReportDate, ROW_NUMBER() OVER(Partition By ICENUMBER ORDER BY ReportDate) as RowRnk from MainCondition MC JOIN Link_MemberID_MVD_Ins L ON L.MVDID = MC.ICENUMBER
			JOIN HPCustomer C ON C.Cust_ID = L.Cust_ID
			Where  RTRIM(MC.Code) IN (SELECT * FROM #DSCodes) and (L.Cust_ID = @CustID or @CustID is null) and C.Active = 1
			--ORDER BY MC.ICENUMBER
		 ) A Where A.RowRnk =1
	
	CREATE UNIQUE NONCLUSTERED INDEX IX_NCI_First_Diagnosed
	ON #First_Diagnosed (Cust_ID, ICENUMBER, MemberID)

	-- HTN
	MERGE #First_Diagnosed AS  T
	USING (SELECT A.ICENUMBER, A.MemberID, A.Cust_ID, A.ReportDate
			FROM (
					Select ICENUMBER, L.InsMemberID as MemberID, L.Cust_ID, ReportDate, ROW_NUMBER() OVER(Partition By ICENUMBER ORDER BY ReportDate) as RowRnk from MainCondition MC JOIN Link_MemberID_MVD_Ins L ON L.MVDID = MC.ICENUMBER
					JOIN HPCustomer C ON C.Cust_ID = L.Cust_ID
					Where  RTRIM(MC.Code) IN (SELECT * FROM #HTNCodes) and (L.Cust_ID = @CustID or @CustID is null) and C.Active = 1
					--ORDER BY MC.ICENUMBER
				) A Where A.RowRnk =1 
		 ) As S
	ON 
		T.ICENUMBER = S.ICENUMBER
		WHEN NOT MATCHED 	BY TARGET 
		THEN INSERT 
		(
			ICENUMBER, MemberID, Cust_ID, HTN_1stDiagDate
		)
		VALUES
			(
				S.ICENUMBER 
				,S.MemberID
				,S.Cust_ID
				,S.ReportDate 
			)
		WHEN MATCHED 
		THEN UPDATE
			SET	T.HTN_1stDiagDate = S.ReportDate;
	--ASM
	MERGE #First_Diagnosed AS  T
	USING (SELECT A.ICENUMBER, A.MemberID, A.Cust_ID, A.ReportDate
			FROM (
					Select ICENUMBER, L.InsMemberID as MemberID, L.Cust_ID, ReportDate, ROW_NUMBER() OVER(Partition By ICENUMBER ORDER BY ReportDate) as RowRnk from MainCondition MC JOIN Link_MemberID_MVD_Ins L ON L.MVDID = MC.ICENUMBER
					JOIN HPCustomer C ON C.Cust_ID = L.Cust_ID
					Where  RTRIM(MC.Code) IN (SELECT * FROM #ASMCodes) and (L.Cust_ID = @CustID or @CustID is null) and C.Active = 1
					--ORDER BY MC.ICENUMBER
				) A Where A.RowRnk =1 
		 ) As S
	ON 
		T.ICENUMBER = S.ICENUMBER
		WHEN NOT MATCHED 	BY TARGET 
		THEN INSERT 
		(
			ICENUMBER, MemberID, Cust_ID, ASM_1stDiagDate
		)
		VALUES
			(
				S.ICENUMBER
				,S.MemberID
				,S.Cust_ID 
				,S.ReportDate 
			)
		WHEN MATCHED 
		THEN UPDATE
			SET	T.ASM_1stDiagDate = S.ReportDate;

	--Behavioral Health
	MERGE #First_Diagnosed AS  T
	USING (SELECT A.ICENUMBER, A.MemberID, A.Cust_ID, A.ReportDate
			FROM (
					Select ICENUMBER, L.InsMemberID as MemberID, L.Cust_ID, ReportDate, ROW_NUMBER() OVER(Partition By ICENUMBER ORDER BY ReportDate) as RowRnk from MainCondition MC JOIN Link_MemberID_MVD_Ins L ON L.MVDID = MC.ICENUMBER
					JOIN HPCustomer C ON C.Cust_ID = L.Cust_ID
					Where  RTRIM(MC.Code) IN (SELECT * FROM #MDCodes) and (L.Cust_ID = @CustID or @CustID is null) and C.Active = 1
					--ORDER BY MC.ICENUMBER
				) A Where A.RowRnk =1 
		 ) As S
	ON 
		T.ICENUMBER = S.ICENUMBER
		WHEN NOT MATCHED 	BY TARGET 
		THEN INSERT 
		(
			ICENUMBER, MemberID, Cust_ID, BH_1stDiagDate
		)
		VALUES
			(
				S.ICENUMBER 
				,S.MemberID
				,S.Cust_ID
				,S.ReportDate 
			)
		WHEN MATCHED 
		THEN UPDATE
			SET	T.BH_1stDiagDate = S.ReportDate;


	INSERT INTO Rules.MemberDiagnosedDetl (ICENUMBER, MemberID, Cust_ID, DIA_1stDiagDate, HTN_1stDiagDate, ASM_1stDiagDate, BH_1stDiagDate )
	SELECT T.ICENUMBER, T.MemberID, T.Cust_ID, T.DIA_1stDiagDate, T.HTN_1stDiagDate, T.ASM_1stDiagDate, T.BH_1stDiagDate 
	FROM  #First_Diagnosed T LEFT JOIN Rules.MemberDiagnosedDetl DD ON DD.ICENUMBER = T.ICENUMBER and DD.Cust_ID = T.Cust_ID
	Where DD.ICENUMBER is NULL

END