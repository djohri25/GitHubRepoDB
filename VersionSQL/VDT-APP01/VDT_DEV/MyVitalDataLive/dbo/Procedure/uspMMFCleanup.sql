/****** Object:  Procedure [dbo].[uspMMFCleanup]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC [dbo].[uspMMFCleanup] (@Execute int = 0)
AS
/*
	Correct the Linkage between the MemberManagement_Form, the MMFHistory_Form, and the MainCarePlanMemberIndex.
	This linkage issue is very specific and always requires the same three updates per MMF.

	Build dynamic SQL for the three tables and insert into the #SQLBatch table.
	Examine the commmands.
	Execute them all at once.

	@Execute needs to be set to 1 to make the corrections.  Use mode 0 to review the commands.

Modifications:
WHO		WHEN		WHAT
Scott	2021-07-27	Created

EXEC uspMMFCleanup @Execute = 0

examine:

DECLARE @MVDID varchar(30) = '160A27757472397FC898'

SELECT ID, MVDID, ReferralID, CaseID, FormDate, FormAuthor, SectionCompleted, CaseProgram, CarePlanID, AuditableCase, LastModifiedDate, q1CaseOwner, q1CaseCreateDate, q1CaseCloseDate
FROM ABCBS_MemberManagement_Form WHERE MVDID = @MVDID ORDER BY ID DESC

SELECT ID, MVDID, ReferralID, CaseID, OriginalFormID, FormDate, FormAuthor, SectionCompleted, CaseProgram, CarePlanID, AuditableCase, LastModifiedDate, q1CaseOwner, q1CaseCreateDate, q1CaseCloseDate
FROM ABCBS_MMFHistory_Form WHERE MVDID = @MVDID ORDER BY ID DESC

SELECT CarePlanID, MVDID, CaseID, CarePlanType, Activated, UpdatedDate, UpdatedBy 
FROM MainCareplanMemberIndex WHERE MVDID = @MVDID ORDER BY CarePlanID DESC

SELECT ID, Note, MVDID, LinkedFormType, LinkedFormID, NoteTypeID, datemodified
  FROM hpalertnote WHERE mvdid = @MVDID AND linkedformtype = 'ABCBS_MMFHistory' ORDER BY ID DESC

*/
BEGIN
SET NOCOUNT ON

DROP TABLE IF EXISTS #SQLBatch 
CREATE TABLE #SQLBatch (QueryType int, MVDID varchar(30), MMFID int, MMHID int, CPID int, SQLCmd varchar(MAX), MMHRank int) 

--Updates for sets missing CaseID IN MainCarePlanMemberIndex
INSERT INTO #SQLBatch (QueryType, MVDID, MMFID, MMHID, CPID, SQLCmd, MMHRank)
SELECT 1 AS QueryType, MMF.MVDID, MMF.ID AS MMFID, MMH.ID AS MMHID, CP.CarePlanID AS CPID,
       --create update command for MemberManagement_Form
       'UPDATE ABCBS_MemberManagement_FORM SET CarePlanID = ' + CAST(CP.CarePlanID AS varchar) + ', AuditableCase = 1, ' +
	   'LastModifiedDate = ''' + FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss') + ''' WHERE ID = ' + CAST(MMF.ID AS varchar) + '; ' + CHAR(10) +
	   --create update command for MMFHistory_Form
	   'UPDATE ABCBS_MMFHistory_Form SET CarePlanID = '  + CAST(CP.CarePlanID AS varchar) + ', AuditableCase = 1, ' + 
	   'LastModifiedDate = ''' + FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss') + ''' WHERE ID = ' + CAST(MMH.ID AS varchar) + '; ' + CHAR(10) +
       --create update command for MainCarePlanMemberIndex
	   'UPDATE MainCarePlanMemberIndex SET CaseID = ' + CAST(MMF.ID AS varchar) + ', UpdatedDate = ''' + FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss') + 
	   ''' WHERE CarePlanID = ' + CAST(CP.CarePlanID AS varchar) + '; ' + CHAR(10) + CHAR(10) AS SQLCmd,
	   --Rank the MMF_History entries to update only the latest one.
	   ROW_NUMBER() OVER(PARTITION BY MMH.ReferralID ORDER BY MMH.ID DESC) MMHRank
  FROM ABCBS_MemberManagement_Form MMF
  JOIN MainCarePlanMemberIndex CP ON CP.MVDID=MMF.MVDID AND CP.CarePlanType = MMF.CaseProgram
  JOIN ABCBS_MMFHistory_Form MMH ON MMH.CaseID = MMF.ID
 WHERE IsNull(MMF.q2ConsentDate,'2000-01-01') > '2010-01-01'	--non null consent date
   AND IsNull(MMF.CarePlanID,0) < 1								--has careplan ID
   AND IsNull(cpInactiveDate,'2000-01-01') = '2000-01-01'		--no cpInactiveDate
   AND IsNull(CP.CaseID,0) = 0									--no caseID
   AND CP.Activated = 1				--							--CarePlan activated
   AND MMH.FormDate >= CP.ActivatedDate							--Form Date > care plan activated date
 ORDER BY MMF.ID, MMHRank

--Updates for sets with CaseID IN MainCarePlanMemberIndex
INSERT INTO #SQLBatch (QueryType, MVDID, MMFID, MMHID, CPID, SQLCmd, MMHRank)
SELECT 2 AS QueryType, MMF.MVDID, MMF.ID AS MMFID, MMH.ID AS MMHID, CP.CarePlanID AS CPID,
       --create update command for MemberManagement_Form
       'UPDATE ABCBS_MemberManagement_FORM SET CarePlanID = ' + CAST(CP.CarePlanID AS varchar) + ', AuditableCase = 1, ' +
	   'LastModifiedDate = ''' + FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss') + ''' WHERE ID = ' + CAST(MMF.ID AS varchar) + '; ' + CHAR(10) +
	   --create update command for MMFHistory_Form
	   'UPDATE ABCBS_MMFHistory_Form SET CarePlanID = '  + CAST(CP.CarePlanID AS varchar) + ', AuditableCase = 1, ' + 
	   'LastModifiedDate = ''' + FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss') + ''' WHERE ID = ' + CAST(MMH.ID AS varchar) + '; ' + CHAR(10) + CHAR(10) AS SQLCmd,
	   --Rank the MMF_History entries to update only the latest one.
	   ROW_NUMBER() OVER(PARTITION BY MMH.ReferralID ORDER BY MMH.ID DESC) MMHRank
  FROM ABCBS_MemberManagement_Form MMF
  JOIN MainCarePlanMemberIndex CP ON CP.MVDID=MMF.MVDID AND CP.CarePlanType = MMF.CaseProgram
  JOIN ABCBS_MMFHistory_Form MMH ON MMH.CaseID = MMF.ID
 WHERE IsNull(MMF.q2ConsentDate,'2000-01-01') > '2010-01-01'	--non null consent date
   AND IsNull(MMF.CarePlanID,0) < 1								--has careplan ID
   AND IsNull(cpInactiveDate,'2000-01-01') = '2000-01-01'		--no cpInactiveDate
   AND IsNull(CP.CaseID,0) = MMF.ID								--with caseID
   AND CP.Activated = 1				--							--CarePlan activated
   AND MMH.FormDate >= CP.ActivatedDate							--Form Date > care plan activated date
 ORDER BY MMF.ID, MMHRank

	--show history 
	SELECT * FROM #SQLBatch WHERE MMHRank=1

--Build a single batch command from the table and execute them all.

	DECLARE @SQL varchar(MAX) = '';
	DECLARE @iCount int = (SELECT COUNT(*) FROM #SQLBatch WHERE MMHRank=1);
	SELECT @SQL += SQLCmd FROM #SQLBatch WHERE MMHRank=1

IF @Execute = 1
	BEGIN
		EXEC(@SQL)
	END
ELSE
	BEGIN
		
		DECLARE @ProcName varchar(100) = (SELECT OBJECT_NAME(@@PROCID))
		--The print statement only prints 5000 characters...
		PRINT @ProcName + ': ' + CAST(@iCount AS varchar) + ' MMF Forms to repair linkage.' + CHAR(10) 
		PRINT @SQL

	END
END