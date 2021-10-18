/****** Object:  Procedure [dbo].[Get_HEDIS_Members]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes: 05/08/2018	MDeLuca	Added: AND hs.LOB IS NULL
-- Changes: 10/31/2018	MDeLuca	Added: AND EXISTS (SELECT 1 FROM dbo.Link_MemberId_MVD_Ins I WHERE I.Active = 1 AND I.Cust_ID = m.CustID AND I.MVDId = m.mvdid)
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Members]
	@SubmeasureAbbreviation varchar(20), --@DiseaseID
	@CustID int = 0,
	@MonthID char(6) = NULL,
	@Completed bit = NULL,
	@User varchar(50) = NULL,
	@TIN varchar(250) = 'ALL',
	@NPI varchar(4000) = 'ALL',
	@LOB varchar(50) = 'ALL',
	@Status varchar(50) = 'ALL',
	@Page int = NULL,
	@RecsPerPage int = NULL,
	@OrderBY varchar(20) = NULL,
	@NextXDays int = NULL,
	@EMS varchar(50) = NULL,
	@UserID_SSO varchar(50) = NULL,
	@TotalRecords int OUTPUT,
	@MVDIDList varchar(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	----------------------------------------------------------------------------
	--declare
	--@SubmeasureAbbreviation varchar(20), --@DiseaseID
	--@CustID int = 0,
	--@MonthID char(6) = NULL,
	--@Completed bit = NULL,
	--@User varchar(50) = NULL,
	--@TIN varchar(250) = 'ALL',
	--@NPI varchar(4000) = 'ALL',
	--@LOB varchar(50) = 'ALL',
	--@Status varchar(50) = 'ALL',
	--@Page int,
	--@RecsPerPage int,
	--@OrderBY varchar(20) = null,
	--@NextXDays int,
	--@EMS varchar(50) = null,
	--@UserID_SSO varchar(50) = null

	--select
	--@CustID = 11, -- good
	--@MonthID = NULL,
	--@SubmeasureAbbreviation = 'AWC', --good --, --@DiseaseID
	--@Completed = NULL, -- good
	----@User = '741662481',
	--@TIN = '741662481',
	----@NPI = '1487602728',
	--@LOB = 'C',
	--@Status = 'ALL',
	
	--@Page = 1,
	--@RecsPerPage = 10000,
	--@OrderBY = null,
	--@NextXDays  = 120,
	--@EMS = null,
	--@UserID_SSO = null
	----------------------------------------------------------------------------

	DECLARE @SubmeasureID int, @MonthID_Check char(6), @CustID_Import int
	DECLARE @TIN_Temp varchar(250), @NPI_Temp varchar(250), @LOB_Temp varchar(30)
	DECLARE @TIN_Array Table (TIN varchar(50))
	DECLARE @NPI_Array Table (NPI varchar(50))
	DECLARE @LOB_Array Table (LOB varchar(10))
	DECLARE @StatusID int
	DECLARE @Count int = 0
	DECLARE @DRLink bit, @PlanLink bit

	DECLARE @MVDIDListLocal varchar(MAX)
	
	DECLARE 
	 @Today DATE = GETDATE()
	,@MeasurementStart DATE
	,@MeasurementEnd DATE
	,@DRLink_BirthdayFilter BIT = 0

	SELECT @MeasurementStart = CASE WHEN MONTH(@Today) >= CAST(LEFT(MeasurementStart,2) AS INT) THEN DATEFROMPARTS(YEAR(GETDATE()), LEFT(MeasurementStart,2), RIGHT(MeasurementStart,2))
								ELSE DATEFROMPARTS(YEAR(GETDATE()-366), LEFT(MeasurementStart,2), RIGHT(MeasurementStart,2))
								END
	FROM dbo.HedisSubmeasures 
	WHERE Abbreviation = @SubmeasureAbbreviation

	SELECT @MeasurementEnd = DATEADD(MM, 12, @MeasurementStart)

	SELECT @DRLink = 0, @PlanLink = 0
	IF (@EMS IS NULL AND @UserID_SSO IS NULL)
	BEGIN
		SELECT @PlanLink = 1
	END
	ELSE
	BEGIN
		SELECT @DRLink = 1
	END
	
	--Submeasure ID
	SELECT @SubmeasureID = [ID]
	FROM [dbo].[HedisSubmeasures]
	WHERE [Abbreviation] = @SubmeasureAbbreviation

	--CustID
	SET @CustID_Import = @CustID
	IF (@CustID_Import = 0)
	BEGIN
		SELECT DISTINCT @CustID_Import = CustID_Import
		FROM [dbo].[MDUser] a
		JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
		JOIN MDGroup c ON b.mdGroupID = c.ID
		WHERE username = @User
	END

	-- BirthdayFilter
	IF (@NextXDays IS NULL)
	BEGIN
		SELECT @DRLink_BirthdayFilter = 0
	END
	ELSE
	BEGIN
		SELECT @DRLink_BirthdayFilter = DRLink_BirthdayFilter 
		FROM HedisSubmeasures s
		JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = @CustID_Import AND s.Abbreviation = @SubmeasureAbbreviation AND hs.LOB IS NULL
	END

	--MonthID
	SELECT @MonthID_Check = Max(MonthID)
	FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE CustID = @CustID_Import
		AND [TestID] = @SubmeasureID

	IF (@MonthID IS NULL OR @MonthID > @MonthID_Check)
	BEGIN
		SET @MonthID = @MonthID_Check
	END

	--TIN
	SELECT @TIN = (CASE WHEN @TIN = '' THEN 'ALL' ELSE @TIN END)
	INSERT INTO @TIN_Array
	SELECT *
	FROM [dbo].[Get_TinArray](@User, @TIN)
	IF (@TIN = 'ALL' AND @User IS NOT NULL)
	BEGIN
		SELECT @TIN = '' -- TIN list is specified by the logged in user
	END

	--NPI
	IF (@NPI != 'ALL')
	BEGIN
		SELECT @NPI_Temp = @NPI
		INSERT INTO @NPI_Array
		SELECT LTRIM(RTRIM(item))
		FROM [dbo].[splitstring](@NPI_Temp, ',')
	END

	--LOB
	SELECT @LOB = (CASE WHEN @LOB = '' THEN 'ALL' ELSE @LOB END)
	IF (@LOB != 'ALL')
	BEGIN
		SELECT @LOB_Temp = @LOB
		INSERT INTO @LOB_Array
		SELECT LTRIM(RTRIM(item))
		FROM [dbo].[splitstring](@LOB_Temp, ',')
	END

	--Status ID
	SELECT @StatusID = CASE WHEN @Status = 'ALL' THEN NULL WHEN ISNUMERIC(@Status) = 1 THEN CONVERT(INT, @Status) ELSE NULL END

	IF (@SubmeasureAbbreviation IN ('AST', 'DIA', 'FPL'))
	BEGIN
		IF OBJECT_ID('tempdb.dbo.#TempTable3') IS NOT NULL DROP TABLE #TempTable3
		;WITH CTE AS
			(
				SELECT DISTINCT
				m.MemberID,
				m.MVDID,
				ISNULL(m.MemberFirstName, '') as FirstName, 
				m.MemberLastName as LastName,
				CASE ISNULL(m.[NPI], '')
					WHEN '' THEN 'No Assigned NPI'
					ELSE m.NPI
				END AS 'NPI',
				m.TIN as 'TIN',
				m.LOB as 'LOB',
				0 AS [Completed],
				CAST(ISNULL(m.HasAsthma, 0) AS varchar(1)) AS HasAsthma,
				CAST(ISNULL(m.HasDiabetes, 0) AS varchar(1)) AS HasDiabetes,
				CAST(ISNULL(m.ERVisitCount, 0) AS varchar(1)) AS ERVisitCount,
				0 AS TestStatusID,
				0 AS ParentStatusID,
				0 AS RemindInDays,
				'' AS StatusUpdateDate,
				0 AS NoteCount,
				'' AS MeasureNote,
				SUBSTRING((SELECT DISTINCT ',' + CAST(hm.Abbreviation AS varchar(10)) 
						   FROM [Final_HEDIS_Member_FULL] h
						   JOIN HedisSubmeasures s ON h.TestID = s.id
						   JOIN HedisMeasures hm ON hm.ID = s.MeasureID
						   JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = m.CustID AND hs.LOB IS NULL
						   LEFT JOIN [dbo].[HedisScorecard_TIN] d ON hs.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = m.TIN
						   WHERE h.CustID = m.CustID
								AND h.MVDID = m.MVDID
								AND h.MonthID = m.MonthID
								AND (CASE WHEN @DRLink = 1 THEN ISNULL(hs.DRLink_Active, 0) ELSE 1 END = 1
									OR CASE WHEN @DRLink = 1 THEN ISNULL(d.DRLink_Active, 0) ELSE 1 END = 1)
						FOR XML PATH('')), 2, 200000) AS TestList
				FROM [dbo].[Final_ALLMember] m
				WHERE
					1 = 
					CASE @SubmeasureAbbreviation
						WHEN 'AST' THEN HasAsthma
						WHEN 'DIA' THEN HasDiabetes
						WHEN 'FPL' THEN 1
					END
					AND m.CustID = @CustID_Import
					AND (@TIN = 'ALL' OR (m.[TIN] IN (SELECT TIN from @TIN_Array)))
					AND (@NPI = 'ALL' OR (m.[NPI] IN (SELECT NPI from @NPI_Array)))
					AND (@LOB = 'ALL' OR (m.[LOB] IN (SELECT LOB from @LOB_Array)))
					AND EXISTS (SELECT 1 FROM dbo.Link_MemberId_MVD_Ins I WHERE I.Active = 1 AND I.Cust_ID = m.CustID AND I.MVDId = m.mvdid)
			)
			SELECT *
			INTO #TempTable3
			FROM CTE

			SET @Count = (SELECT COUNT(*) FROM #TempTable3)

			IF (@DRLink = 1)
			BEGIN
				SELECT @MVDIDListLocal = COALESCE(@MVDIDListLocal + ',' ,'') + MVDID FROM #TempTable3 ORDER BY LastName
				--SELECT @MVDIDList  = SUBSTRING((SELECT DISTINCT ',' + CAST(MVDID AS varchar(10)) FROM #TempTable3 FOR XML PATH('')), 2, 200000)
			END

			SELECT * FROM #TempTable3
			ORDER BY
				CASE @OrderBY WHEN 'MVDID' THEN MVDID END DESC,
				CASE @OrderBY WHEN 'HasAsthma' THEN HasAsthma END DESC,
				CASE @OrderBY WHEN 'HasDiabetes' THEN HasDiabetes END DESC,
				CASE @OrderBY WHEN 'ERVisitCount' THEN ERVisitCount END DESC,
				CASE @OrderBY WHEN 'NoteCount' THEN NoteCount END DESC,
				CASE @OrderBY WHEN 'TestList' THEN TestList
				ELSE LastName END
			OFFSET (ISNULL(@Page, 0) - 1) * ISNULL(@RecsPerPage, 0) ROWS FETCH NEXT ISNULL(@RecsPerPage, 10000000) ROWS ONLY
		
			 DROP TABLE #TempTable3

			--OPTION (RECOMPILE)
	END
	ELSE
	BEGIN
		IF (@MonthID = @MonthID_Check)
		BEGIN
			;WITH CTE AS
			(
				SELECT DISTINCT
				m.MemberID,
				m.MVDID,
				ISNULL(m.MemberFirstName, '') as FirstName, 
				m.MemberLastName as LastName,
				CASE ISNULL(m.[PCP_NPI], '')
					WHEN '' THEN 'No Assigned NPI'
					ELSE m.PCP_NPI
				END AS 'NPI',
				m.PCP_TIN as 'TIN',
				m.LOB as 'LOB',
				m.IsTestDue AS [Completed],
				CAST(ISNULL(m.HasAsthma, 0) AS varchar(1)) AS HasAsthma,
				CAST(ISNULL(m.HasDiabetes, 0) AS varchar(1)) AS HasDiabetes,
				CAST(ISNULL(am.ERVisitCount, 0) AS varchar(1)) AS ERVisitCount,
				ISNULL(mt.StatusID, 0) AS TestStatusID,
				ISNULL(s.ParentID, 0) AS ParentStatusID,
				ISNULL(mt.RemindInDaysCount, 0) AS RemindInDays,
				CAST(ISNULL(mt.Created, '') AS varchar(50)) AS StatusUpdateDate,
				(SELECT COUNT(ID) FROM MD_Note n WHERE n.MvdID = m.mvdid AND n.ModifyDate > DATEADD(dd, -14, GETDATE())) AS NoteCount,
				CASE
					WHEN ISNULL(m.[MeasureNote],'') = '' THEN dbo.Get_HEDISMeasureNote(@SubmeasureAbbreviation, m.mvdid)
					ELSE m.[MeasureNote]
				END AS MeasureNote,
				SUBSTRING((SELECT DISTINCT ',' + CAST(hm.Abbreviation AS varchar(10)) 
						   FROM [Final_HEDIS_Member] h
						   JOIN [HedisSubmeasures] s ON h.TestID = s.id
						   JOIN [HedisMeasures] hm ON hm.ID = s.MeasureID
						   JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = m.CustID AND hs.LOB IS NULL
						   LEFT JOIN [dbo].[HedisScorecard_TIN] d ON hs.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = m.PCP_TIN
						   WHERE h.CustID = @CustID_Import
								AND h.MVDID = m.MVDID
								AND (CASE WHEN @DRLink = 1 THEN ISNULL(hs.DRLink_Active, 0) ELSE 1 END = 1
									OR CASE WHEN @DRLink = 1 THEN ISNULL(d.DRLink_Active, 0) ELSE 1 END = 1)
						FOR XML PATH('')), 2, 200000) AS TestList
				FROM [Final_HEDIS_Member] m
				LEFT JOIN [Final_ALLMember] am ON m.mvdid = am.mvdid AND m.custid = am.custid
				LEFT JOIN HedisTestStatus mt ON m.mvdid = mt.mvdid AND m.testid = mt.TestID
				LEFT JOIN LookupTestDueStatus s ON (ISNULL(mt.StatusID, 0) = s.ID OR ISNULL(mt.StatusID, 0) = s.ParentID)
				WHERE
					m.CustID = @CustID_Import
					AND m.TestID = @SubmeasureID
					AND (m.[IsTestDue] = @Completed OR @Completed IS NULL)
					AND (@TIN = 'ALL' OR (m.[PCP_TIN] IN (SELECT TIN from @TIN_Array)))
					AND (@NPI = 'ALL' OR (m.[PCP_NPI] IN (SELECT NPI from @NPI_Array)))
					AND (@LOB = 'ALL' OR (m.[LOB] IN (SELECT LOB from @LOB_Array)))
					AND ISNULL(mt.StatusID, 0) = COALESCE(@StatusID, mt.StatusID, 0)
					AND (@DRLink_BirthdayFilter = 0
						OR
							(
							@DRLink_BirthdayFilter = 1
							AND CASE WHEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) < @MeasurementEnd THEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) ELSE DATEADD(YY, -1, DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB)) END >= @MeasurementStart
							AND CASE WHEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) < @MeasurementEnd THEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) ELSE DATEADD(YY, -1, DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB)) END < @MeasurementEnd
							AND CASE WHEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) < @MeasurementEnd THEN DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB) ELSE DATEADD(YY, -1, DATEADD(YY, DATEDIFF(YY, m.DOB, @Today), m.DOB)) END <= DATEADD(DD, @NextXDays, @Today)
							)
						)
					--AND (@NextXDays IS NULL OR ((DateDiff(d, GetDate(),
					--		CASE WHEN ISDATE(CAST(DATEPART(YYYY, GetDate()) as VARCHAR(4))+'-'+ CAST(DatePart(MM, m.DOB) as VARCHAR(2))+'-'+ CAST(DatePart(DD, m.DOB) as VARCHAR(2))) = 0 then DateFromParts(DATEPART(YYYY, GetDate()), DatePart(MM, m.DOB), DatePart(DD, DATEADD(d, -1,m.DOB)))
					--			ELSE DateFromParts(DATEPART(YYYY, GetDate()), DatePart(MM, m.DOB), DatePart(DD, m.DOB)) END ) BETWEEN 0 AND @NextXDays)
					--	OR (DateDiff(d, GetDate(), 
					--		CASE WHEN ISDATE(CAST(DATEPART(YYYY, GetDate()) as VARCHAR(4))+'-'+ CAST(DatePart(MM, m.DOB) as VARCHAR(2))+'-'+ CAST(DatePart(DD, m.DOB) as VARCHAR(2))) = 0 then DateFromParts(DATEPART(YYYY, GetDate()), DatePart(MM, m.DOB), DatePart(DD, DATEADD(d, -1,m.DOB)))
					--			ELSE DateFromParts(DATEPART(YYYY, GetDate()), DatePart(MM, m.DOB), DatePart(DD, m.DOB))END ) < GETDATE() and m.IsTestDue = 0)))
			)
			SELECT *
			INTO #TempTable1
			FROM CTE
		
			SET @Count = (SELECT COUNT(*) FROM #TempTable1)

			IF (@DRLink = 1)
			BEGIN
				SELECT @MVDIDListLocal = COALESCE(@MVDIDListLocal + ',' ,'') + MVDID FROM #TempTable1 ORDER BY LastName
				--SELECT @MVDIDList  = SUBSTRING((SELECT DISTINCT ',' + CAST(MVDID AS varchar(10)) FROM #TempTable1 FOR XML PATH('')), 2, 200000)
			END

			SELECT * FROM #TempTable1
			ORDER BY
				CASE @OrderBY WHEN 'MVDID' THEN MVDID END DESC,
				CASE @OrderBY WHEN 'HasAsthma' THEN HasAsthma END DESC,
				CASE @OrderBY WHEN 'HasDiabetes' THEN HasDiabetes END DESC,
				CASE @OrderBY WHEN 'ERVisitCount' THEN ERVisitCount END DESC,
				CASE @OrderBY WHEN 'NoteCount' THEN NoteCount END DESC,
				CASE @OrderBY WHEN 'TestList' THEN TestList END DESC,
				CASE @SubmeasureAbbreviation WHEN 'W15' THEN CONVERT(varchar, CONVERT(date, dbo.Get_HEDISW15_NextVisitDueDate(mvdid)))
				ELSE LastName END
			OFFSET (ISNULL(@Page, 0) - 1) * ISNULL(@RecsPerPage, 0) ROWS FETCH NEXT ISNULL(@RecsPerPage, 10000000) ROWS ONLY
			
			DROP TABLE #TempTable1

			--OPTION (RECOMPILE)
		END
		ELSE
		BEGIN
			;WITH CTE AS
			(
				SELECT DISTINCT
				m.MemberID,
				m.MVDID,
				ISNULL(m.MemberFirstName, '') as FirstName, 
				m.MemberLastName as LastName,
				CASE ISNULL(m.[PCP_NPI], '')
					WHEN '' THEN 'No Assigned NPI'
					ELSE m.PCP_NPI
				END AS 'NPI',
				m.PCP_TIN as 'TIN',
				m.LOB as 'LOB',
				m.IsTestDue AS [Completed],
				CAST(ISNULL(m.HasAsthma, 0) AS varchar(1)) AS HasAsthma,
				CAST(ISNULL(m.HasDiabetes, 0) AS varchar(1)) AS HasDiabetes,
				'0' AS ERVisitCount,
				0 AS TestStatusID,
				0 AS ParentStatusID,
				0 AS RemindInDays,
				'' AS StatusUpdateDate,
				0 AS NoteCount,
				'' AS MeasureNote,
				SUBSTRING((SELECT DISTINCT ',' + CAST(hm.Abbreviation AS varchar(10)) 
						   FROM [Final_HEDIS_Member_FULL] h
						   JOIN HedisSubmeasures s ON h.TestID = s.id
						   JOIN HedisMeasures hm ON hm.ID = s.MeasureID
						   JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = m.CustID AND hs.LOB IS NULL
						   LEFT JOIN [dbo].[HedisScorecard_TIN] d ON hs.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = m.PCP_TIN
						   WHERE h.CustID = m.CustID
								AND h.MVDID = m.MVDID
								AND h.MonthID = m.MonthID
								AND (CASE WHEN @DRLink = 1 THEN ISNULL(hs.DRLink_Active, 0) ELSE 1 END = 1
									OR CASE WHEN @DRLink = 1 THEN ISNULL(d.DRLink_Active, 0) ELSE 1 END = 1)
						FOR XML PATH('')), 2, 200000) AS TestList
				FROM [dbo].[Final_HEDIS_Member_FULL] m
				WHERE
					m.CustID = @CustID_Import
					AND m.MonthID = @MonthID
					AND m.TestID = @SubmeasureID
					AND (m.[IsTestDue] = @Completed OR @Completed IS NULL)
					AND (@TIN = 'ALL' OR (m.[PCP_TIN] IN (SELECT TIN from @TIN_Array)))
					AND (@NPI = 'ALL' OR (m.[PCP_NPI] IN (SELECT NPI from @NPI_Array)))
					AND (@LOB = 'ALL' OR (m.[LOB] IN (SELECT LOB from @LOB_Array)))
			)
			SELECT *
			INTO #TempTable2
			FROM CTE

			SET @Count = (SELECT COUNT(*) FROM #TempTable2)

			IF (@DRLink = 1)
			BEGIN
				SELECT @MVDIDListLocal = COALESCE(@MVDIDListLocal + ',' ,'') + MVDID FROM #TempTable2 ORDER BY LastName
				--SELECT @MVDIDList  = SUBSTRING((SELECT DISTINCT ',' + CAST(MVDID AS varchar(10)) FROM #TempTable2 FOR XML PATH('')), 2, 200000)
			END

			SELECT * FROM #TempTable2
			ORDER BY
				CASE @OrderBY WHEN 'MVDID' THEN MVDID END DESC,
				CASE @OrderBY WHEN 'HasAsthma' THEN HasAsthma END DESC,
				CASE @OrderBY WHEN 'HasDiabetes' THEN HasDiabetes END DESC,
				CASE @OrderBY WHEN 'ERVisitCount' THEN ERVisitCount END DESC,
				CASE @OrderBY WHEN 'NoteCount' THEN NoteCount END DESC,
				CASE @OrderBY WHEN 'TestList' THEN TestList END DESC,
				CASE @SubmeasureAbbreviation WHEN 'W15' THEN CONVERT(varchar, CONVERT(date, dbo.Get_HEDISW15_NextVisitDueDate(mvdid)))
				ELSE LastName END
			OFFSET (ISNULL(@Page, 0) - 1) * ISNULL(@RecsPerPage, 0) ROWS FETCH NEXT ISNULL(@RecsPerPage, 10000000) ROWS ONLY
		
			DROP TABLE #TempTable2

			--OPTION (RECOMPILE)
		END
	END

	SET @TotalRecords = @Count

	IF (ISNULL(@EMS, '') != '' OR ISNULL(@UserID_SSO, '') != '')
	BEGIN
		-- Record SP Log
		DECLARE @params nvarchar(1000) = null
		SET @params = '@SubmeasureAbbreviation=' + @SubmeasureAbbreviation + ';' +
					  '@CustID=' + CONVERT(varchar(50), @CustID_Import) + ';' +
					  '@MonthID=' + ISNULL(@MonthID, 'null') + ';' +
					  '@Completed=' + ISNULL(CAST(@Completed AS VARCHAR(4)), 'null') + ';' +
					  '@User=' + ISNULL(@User, 'null') + ';' +
					  '@TIN=' + ISNULL(@TIN, 'null') + ';' +
					  '@NPI=' + ISNULL(@NPI, 'null') + ';' +
					  '@LOB=' + ISNULL(@LOB, 'null') + ';' +
					  '@Status=' + ISNULL(@Status, 'null') + ';'
		EXEC [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_HEDIS_Members]', @EMS, @UserID_SSO, @params
	END

	SET @MVDIDList = @MVDIDListLocal
END