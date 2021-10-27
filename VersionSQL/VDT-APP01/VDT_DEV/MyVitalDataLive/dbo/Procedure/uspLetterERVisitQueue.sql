/****** Object:  Procedure [dbo].[uspLetterERVisitQueue]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.usp_LetterERVisitQueue 
AS
/*

note:	This procedure will replace CFR 268 and 272.  Those procedures are no longer populate the CareFlowTask queue.
		Their Exclusions are still used though, in this procedure.

		This procedure will get the the members who have had 2-4 ER visits in 90 days OR 2-4 visits within 12 months.  
        The same exclusions for the previous rules will be used. Two new exclusions have been added, one for those who
		have received a letter within 90 days (31), and those who have received 2 letters within on year (32). This is determined
		by a query to LetterMember.LetterType IN (49,50,51,52,53,54,55,56).

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Created per TFS 6213/6199

EXEC usp_LetterERVisitQueue

prerequisites:  

INSERT INTO CFR_Exclusion (Family, Exclusion,Description) VALUES
('ERVisitLetter','90Day','Member received a letter within 90 days.'), 
('ERVisitLetter','365Day','Member received 2 letters within 365 days.') 

EXEC uspCFR_MapRuleExclusion @RuleID = '268', @Action = 'ADD', @ExclusionID = '31,32'

*/
BEGIN
SET NOCOUNT ON 

PRINT 'ER Visit Letter Queue Refresh by '+ OBJECT_NAME(@@PROCID) + ' ' + CAST(GETDATE() AS VARCHAR)

DECLARE @AddedMVDID int, @RemovedMVDID int

--generate the base tables if necessary
IF OBJECT_ID('dbo.LetterERVisitQueue') IS NULL CREATE TABLE LetterERVisitQueue (MVDID varchar(50), Category varchar(25), CreateDate datetime)
IF OBJECT_ID('dbo.LetterERVisitHistory') IS NULL CREATE TABLE LetterERVisitHistory (MVDID varchar(50), Category varchar(25), CreateDate datetime)

GetExcludedMVDID:

	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	--get the exclusions from the former CFR.  The letter exclusions have been added (31,32)
	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = 'uspCFR_ERVisit_Strat90_268_MVDID'
	 
ERLettersWithin90:
	--ER Visit Letter within 90 days
	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT MVDID
	  FROM LetterMembers 
	 WHERE LetterType IN (49,50,51,52,53,54,55,56)
	   AND DATEDIFF(dd, LetterDate, GETDATE()) <= 90
	 GROUP BY MVDID

ERLettersWithin365:
	--2 ER Visit Letters within 365 days
	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT MVDID
	  FROM LetterMembers 
	 WHERE LetterType IN (49,50,51,52,53,54,55,56)
	   AND DATEDIFF(dd, LetterDate, GETDATE()) <= 365
	 GROUP BY MVDID
	HAVING COUNT(*) >= 2

INSERT INTO #ExcludedMVDID (MVDID) VALUES
('162AE6883C28043ED880'),('16D841B564FDFBBA19A6'),('169E1CBFB246134D92A'),('164806BD3106613A9A74'),('16BCAEA4D4E13B75E592'),
('16873CBEC4434959EFBB'),('1617751AE4230935B3DB'),('16E4200864714810453A'),('16626DC844A7B98C016E'),('16A9C25694E3791F8CA2'),
('16BC3C44446AE816FA42'),('169610A9C4184A9DC002'),('16D74297B59135EB386A'),('166D3434345C8931D974'),('1672CB07E4D3EAF6D16B'),
('16BB40478BE28701C607'),('16EE3471B4472AD77549'),('1669472AA894625082DC'),('16207FF54427499A6106')

	DROP TABLE IF EXISTS #ERVisits
	CREATE TABLE #ERVisits (MVDID varchar(30), Category varchar(25), Cnt int)

		;WITH ERVisits AS
		(--get Members with 2-4 ER Visits within 90 days
		 SELECT mvdid, '90 Day' AS Category, COUNT(distinct claimnumber) AS cnt
		   FROM FinalClaimsHeader
		  WHERE ISNULL(EmergencyIndicator,0) = 1
		    AND DATEDIFF(day,StatementFromDate, GETDATE()) <= 90
		    AND ISNULL(AdjustmentCode,'O') != 'A'
		  GROUP BY MVDID
		  HAVING COUNT(*) BETWEEN 2 AND 4
		  UNION 
		  --get Members with 2-4 ER Visits within 365 days
		 SELECT MVDID, '365 day' AS Category, COUNT(DISTINCT claimnumber) AS cnt
		   FROM FinalClaimsHeader
		  WHERE ISNULL(EmergencyIndicator,0) = 1
			AND DATEDIFF(day,StatementFromDate, GETDATE()) <= 365
			AND ISNULL(AdjustmentCode,'O') != 'A'
		  GROUP BY MVDID
		  HAVING COUNT(*) BETWEEN 2 AND 4
		  )
         INSERT INTO #ERVisits (MVDID, Category, Cnt)
		 SELECT MVDID, Category, Cnt
		   FROM ERVisits er
		  WHERE NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = er.MVDID);

		--SELECT * FROM #ERVisits

--create table to capture deleted MVDIDs during merge
DECLARE @History TABLE (MVDID varchar(50), Category varchar(25), CreateDate datetime)

Merge_LetterERVisitQueue:

			MERGE LetterERVisitQueue AS Target  
			USING (SELECT DISTINCT m.MVDID, 
			              Category,
						  GETDATE() AS CreateDate
					 FROM #ERVisits m
				   ) AS Source (MVDID, Category, CreateDate)  
				ON (Target.MVDID = Source.MVDID)   
              WHEN NOT MATCHED BY Source THEN DELETE  --If the MVDID is no longer in source then the member was mailed
              WHEN NOT MATCHED BY Target THEN		 --This is a new letter request.  Add it.
			       INSERT (MVDID, Category, CreateDate)
			       VALUES (Source.MVDID, 
					       Source.Category, 
					       Source.CreateDate)
		    OUTPUT Deleted.MVDID, Deleted.Category, Deleted.CreateDate INTO @History;

			--SELECT * FROM @History
			--SET @AddedMVDID = @@ROWCOUNT

SaveHistory:

	INSERT LetterERVisitHistory (MVDID, Category, CreateDate)
	SELECT MVDID, Category, CreateDate FROM @History WHERE MVDID IS NOT NULL
	
	--SET @RemovedMVDID = @@ROWCOUNT

ProcedureEnd:

	PRINT CAST(@AddedMVDID AS varchar) + ' records added to LetterERVisitQueue. ' +
	      CAST(@RemovedMVDID AS varchar) + ' records moved to LetterERVisitHistory. '

END

--SELECT * FROM LetterERVisitQueue
--TRUNCATE TABLE LetterERVisitQueue
--SELECT * FROM LetterERVisitHistory
--TRUNCATE TABLE LetterERVisitHistory