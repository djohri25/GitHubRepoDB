/****** Object:  Procedure [dbo].[UpdFinal_ALLMemberHedisList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC dbo.UpdFinal_ALLMemberHedisList @CustID = 10, @MonthID  = NULL
-- =============================================
CREATE PROCEDURE [dbo].[UpdFinal_ALLMemberHedisList]
	 @CustID INT
	,@MonthID CHAR(6) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	IF @MonthID IS NULL
		SELECT @MonthID = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = @CustID

	DROP TABLE IF EXISTS #F
	SELECT CustID, MVDID, TestID, IsTestDue
	INTO #F
	FROM dbo.Final_HEDIS_Member_FULL  F
	WHERE CustID = @CustID 
	AND MonthID = @MonthID 
	ORDER BY CustID, MVDID, TestID

	-- Rollup the full list
	DROP TABLE IF EXISTS #L
	SELECT DISTINCT
	 CustID
	,MVDID
	,CAST(SUBSTRING(
	( 
		SELECT DISTINCT ','+CAST(Abbreviation AS VARCHAR(10)) 
		FROM #F h 
		JOIN dbo.lookupHedis l ON h.TestID = l.id
		WHERE h.CustID = F.CustID 
		AND h.MVDID = F.MVDID
		FOR XML PATH('')),2,200000
	) AS VARCHAR(2000)) AS HedisList
	INTO #L
	FROM #F F
	ORDER BY MVDID

	-- Rollup the list due
	DROP TABLE IF EXISTS #D
	SELECT DISTINCT
	 CustID
	,MVDID
	,CAST(SUBSTRING(
	( 
		SELECT DISTINCT ','+CAST(Abbreviation AS VARCHAR(10)) 
		FROM #F h 
		JOIN dbo.lookupHedis l ON h.TestID = l.id
		WHERE h.CustID = F.CustID 
		AND h.MVDID = F.MVDID
		AND h.IsTestDue = 0
		AND NOT EXISTS -- If the member has been manually marked as completed, do not add them to the list
		(
			SELECT 1
			FROM dbo.HedisTestStatus TS
			WHERE TS.TestID IS NOT NULL
			AND TS.StatusID = 16
			AND TS.Created >= DATEFROMPARTS(YEAR(GETDATE()),'01', '01')
			AND TS.TestID = h.TestID
			AND TS.MVDID = h.MVDID
		)
		FOR XML PATH('')),2,200000
	) AS VARCHAR(2000)) AS HedisDue
	INTO #D
	FROM #F F
	WHERE F.IsTestDue = 0
	ORDER BY MVDID

		-- Final_ALLMember
	UPDATE dbo.Final_ALLMember
	SET TestList = NULL, TestDueList = NULL
	WHERE CustID = @CustID
	AND MonthID = @MonthID

	UPDATE F
	SET F.TestList = L.HedisList
	FROM dbo.Final_ALLMember F
	JOIN #L L ON F.CustID = L.CustID AND F.mvdid = L.MVDID
	WHERE F.CustID = @CustID
	AND F.MonthID = @MonthID

	UPDATE F
	SET F.TestDueList = D.HedisDue
	FROM dbo.Final_ALLMember F
	JOIN #D D ON F.CustID = D.CustID AND F.mvdid = D.MVDID
	WHERE F.CustID = @CustID
	AND F.MonthID = @MonthID

END