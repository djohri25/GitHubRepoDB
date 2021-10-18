/****** Object:  Procedure [dbo].[Get_CareSpaceSummary]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CareSpaceSummary]
AS
BEGIN

IF OBJECT_ID('TempDB.dbo.#Temp_CNote','U') is not null
Drop table #Temp_CNote
CREATE TABLE #Temp_CNote
(
	CaseManager	VARCHAR(100),
	MemberID	VARCHAR(60),
	Type		VARCHAR(20),
	NoteSourceID	INT,
	Label		VARCHAR(40),
	CNote_Count	INT
)


IF OBJECT_ID('TempDB.dbo.#Temp_RNote','U') is not null
Drop table #Temp_RNote
CREATE TABLE #Temp_RNote
(
	CaseManager	VARCHAR(100),
	MemberID	VARCHAR(60),
	ReferralCount	INT
)

IF OBJECT_ID('TempDB.dbo.#Temp_ENote','U') is not null
Drop table #Temp_ENote
CREATE TABLE #Temp_ENote
(
	CaseManager	VARCHAR(100),
	MemberID	VARCHAR(60),
	SendToSaveOnly	INT,
	SendToAllOther	INT
)
IF OBJECT_ID('TempDB.dbo.#Temp_DNote','U') is not null
Drop table #Temp_DNote
CREATE TABLE #Temp_DNote
(
	CaseManager	VARCHAR(100),
	MemberID	VARCHAR(60),
	DocFormType	VARCHAR(100),
	DNote_Count	INT
)



-- Clinical
INSERT INTO #Temp_CNote 
select distinct CCC.Q20A as CaseManager, 
				A.MemberID,
				'Referral' as Type,
				CNote.NoteSourceId, G.Label, COUNT(Distinct CNote.ID) as CNote_Count
from HPAlert A LEFT JOIN [dbo].[Link_HPRuleAlertGroup] HRAG ON A.TriggerID = HRAG.Rule_ID and CASE WHEN ISNumeric(A.AgentID) = 0 then 0 ELSE A.AgentID END = HRAG.AlertGroup_ID
LEFT JOIN HPAlertGroup HAG ON HAG.ID = HRAG.AlertGroup_ID
--JOIN Link_MemberID_MVD_Ins L ON L.InsMemberID = A.MemberID
JOIN CCC_Memberinfo_form CCC on A.MVDID = CCC.MVDID
LEFT JOIN [dbo].[HPWorkflowRule] HWFR ON HWFR.Rule_ID = HRAG.Rule_ID
LEFT JOIN [dbo].[HPAlertNote] CNote ON CNote.MVDID = A.MVDID and CNote.NoteTypeID = 7 
LEFT JOIN Lookup_Generic_Code G ON G.CodeID = CNote.NoteSourceId
WHERE A.TriggerType in ('WORKFLOW') and ISNULL(CCC.q20a, '')  <> '' and CNote.DateCreated > '20160806'  
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY CCC.Q20A, A.MemberID,CNote.NoteSourceId, G.Label

UNION
select distinct CNote.CreatedBy as CaseManager, 
				A.MemberID,
				'Non Referral' as Type,
				CNote.NoteSourceId, G.Label, COUNT(Distinct CNote.ID)  as CNote_Count
from HPAlert A 
--JOIN Link_MemberID_MVD_Ins L ON L.InsMemberID = A.MemberID
LEFT JOIN [dbo].[HPAlertNote] CNote ON CNote.MVDID = A.MVDID and CNote.NoteTypeID = 7 AND A.TriggerID = CNote.ID
LEFT JOIN Lookup_Generic_Code G ON G.CodeID = CNote.NoteSourceId
WHERE A.TriggerType in ('Note') and ISNULL(CNote.CreatedBy, '')  <> '' and CNote.DateCreated > '20160806' 
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY CNote.CreatedBy, A.MemberID,CNote.NoteSourceId,G.Label

-- Refereal
INSERT INTO #Temp_RNote
select distinct CCC.Q20A as CaseManager, 
				A.MemberID,
				COUNT(distinct RNote.ID) as ReferralCount

from HPAlert A LEFT JOIN [dbo].[Link_HPRuleAlertGroup] HRAG ON A.TriggerID = HRAG.Rule_ID and CASE WHEN ISNumeric(A.AgentID) = 0 then 0 ELSE A.AgentID END = HRAG.AlertGroup_ID
LEFT JOIN HPAlertGroup HAG ON HAG.ID = HRAG.AlertGroup_ID
--JOIN Link_MemberID_MVD_Ins L ON L.InsMemberID = A.MemberID
JOIN CCC_Memberinfo_form CCC on A.MVDID = CCC.MVDID
LEFT JOIN [dbo].[HPWorkflowRule] HWFR ON HWFR.Rule_ID = HRAG.Rule_ID
LEFT JOIN [dbo].[HPAlertNote] RNote ON RNote.MVDID = A.MVDID and RNote.NoteTypeID = 8
WHERE A.TriggerType in ('WORKFLOW') and ISNULL(CCC.q20a, '')  <> ''  and RNote.DateCreated > '20160806'  
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY CCC.Q20A, A.MemberID
UNION

select distinct RNote.CreatedBy as CaseManager, 
				A.MemberID,
				COUNT(distinct RNote.ID) as ReferralCount
from HPAlert A 
--JOIN Link_MemberID_MVD_Ins L ON L.InsMemberID = A.MemberID
LEFT JOIN CCC_Memberinfo_form CCC on A.MVDID = CCC.MVDID
LEFT JOIN [dbo].[HPAlertNote] RNote ON RNote.MVDID = A.MVDID and RNote.NoteTypeID = 8	 AND A.TriggerID = RNote.ID
WHERE A.TriggerType in ('Note') and ISNULL(RNote.CreatedBy, '')  <> ''  and RNote.DateCreated > '20160806' 
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY RNote.CreatedBy, A.MemberID

-- Engauge
INSERT INTO #Temp_ENote
select distinct CCC.Q20A as CaseManager, 
				L.InsMemberID as MemberID,
				SUM(CAST(ENote.SendToNone as INT)) as SendToSaveOnly,
				SUM(CASE WHEN ENote.SendToNone = 0 and Coalesce(ENote.SendToPCP, ENote.SendToOHIT, ENote.SendToState, ENote.SendToDMVendor) = 1 THEN 1 
				ELSE 0 END) as SendToAllOther
from Link_MemberID_MVD_Ins L 
JOIN CCC_Memberinfo_form CCC on L.MVDID = CCC.MVDID
LEFT JOIN [dbo].[HPAlertNote] ENote ON ENote.MVDID = L.MVDID and ENote.NoteTypeID = 9
WHERE ISNULL(CCC.q20a, '')  <> '' and ENote.DateCreated > '20160806'  
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY CCC.Q20A, L.InsMemberID

UNION

select distinct ENote.CreatedBy as CaseManager, 
				L.InsMemberID as MemberID,
				SUM(CAST(ENote.SendToNone as INT)) as SendToSaveOnly,
				SUM(CASE WHEN ENote.SendToNone = 0 and Coalesce(ENote.SendToPCP, ENote.SendToOHIT, ENote.SendToState, ENote.SendToDMVendor) = 1 THEN 1 
				ELSE 0 END) as SendToAllOther

from Link_MemberID_MVD_Ins L 
LEFT JOIN [dbo].[HPAlertNote] ENote ON ENote.MVDID = L.MVDID and ENote.NoteTypeID = 9 
WHERE ISNULL(ENote.CreatedBy, '')  <> ''   and ENote.DateCreated > '20160806'
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY ENote.CreatedBy, L.InsMemberID

-- Document
INSERT INTO #Temp_DNote
select distinct CCC.Q20A as CaseManager, 
				L.InsMemberID as MemberID,
				CSNF.DocFormType, 
				COUNT(DNote.ID) as DNote_Count
from Link_MemberID_MVD_Ins L 
JOIN CCC_Memberinfo_form CCC on L.MVDID = CCC.MVDID
LEFT JOIN [dbo].[HPAlertNote] DNote ON DNote.MVDID = L.MVDID 
LEFT JOIN [dbo].[LookupCS_MemberNoteForms] CSNF ON CSNF.ProcedureName = DNote.LinkedFormType
WHERE ISNULL(CCC.q20a, '')  <> ''   and DNote.DateCreated > '20160806'
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY CCC.Q20A, L.InsMemberID, CSNF.DocFormType

UNION
select distinct DNote.CreatedBy as CaseManager, 
				L.InsMemberID as MemberID,
				CSNF.DocFormType, 
				COUNT(DNote.ID) as DNote_Count
from Link_MemberID_MVD_Ins L 
LEFT JOIN [dbo].[HPAlertNote] DNote ON DNote.MVDID = L.MVDID 
LEFT JOIN [dbo].[LookupCS_MemberNoteForms] CSNF ON CSNF.ProcedureName = DNote.LinkedFormType
WHERE ISNULL(DNote.CreatedBy, '')  <> ''  and DNote.DateCreated > '20160806'
and Note not like 'Record viewed%'
  and Note not like 'Detailed Report viewed%'  
  and Note not like 'Summary Report viewed%'
  and Note not like '% reviewed the Hedis measure%'
GROUP BY DNote.CreatedBy, L.InsMemberID, CSNF.DocFormType




-- Insert into #Temp_Final
select Coalesce(R.CaseManager,D.CaseManager) as CaseManager, 
	   Coalesce(R.MemberID,D.MemberID) as MemberID, 
	   R.ReferralCount , 
	   D.DocFormType, 
	   D.DNote_Count
INTO #Temp_Final_D_R
from #Temp_DNote D FULL JOIN #Temp_RNote R ON D.CaseManager = R.CaseManager and D.MemberID = R.MemberID


Select Coalesce(C.CaseManager,E.CaseManager) as CaseManager, 
	   Coalesce(C.MemberID,E.MemberID) as MemberID, 
	   C.Type, 
	   Label, 
	   CNote_Count, 
	   E.SendToSaveOnly, 
	   E.SendToAllOther
INTO #Temp_Final_C_E
FROM #Temp_CNote C FULL JOIN #Temp_ENote E ON E.CaseManager = C.CaseManager and E.MemberID = C.MemberID

SELECT Coalesce(A.CaseManager,B.CaseManager) as CaseManager, 
	   Coalesce(A.MemberID,B.MemberID) as MemberID, 
	   B.Type, 
	   B.Label, 
	   B.CNote_Count, 
	   B.SendToSaveOnly, 
	   B.SendToAllOther,
	   A.ReferralCount , 
	   A.DocFormType, 
	   A.DNote_Count
INTO #Temp_Final
FROM #Temp_Final_D_R A FULL JOIN #Temp_Final_C_E B ON A.CaseManager = B.CaseManager and A.MemberID = B.MemberID


--Clinical Notes Pivot into #Temp_Pivot_CNote
SELECT Casemanager, MemberID, Type, Phone, [In Person], [Clinic / Provider], [Virtual Visit], ReferralCount, SendToSaveOnly, SendToAllOther, DocFormType, DNote_Count
into #Temp_Pivot_CNote
FROM (
SELECT Casemanager, MemberID, Type, Label, CNote_Count, ReferralCount, SendToSaveOnly, SendToAllOther, DocFormType, DNote_Count FROM #Temp_Final) P 
pivot (max(p.CNote_Count) for Label in ([Phone],
[In Person],
[Clinic / Provider],
[Virtual Visit]
)) as pvt


-- Final Output
SELECT  Casemanager, 
		MemberID,  
		[Assessment] As Doc_Assessment, 
		[CarePlan] Doc_CarePlaan, 
		[Others] Doc_Others,
		Type Clinical_Type, 
		Phone, 
		[In Person], 
		[Clinic / Provider], 
		[Virtual Visit], 
		ReferralCount, 
		SendToSaveOnly as Engauge_SendToSaveOnly, 
		SendToAllOther as Engauge_SendToAllOther
FROM (
SELECT Casemanager, MemberID, Type, Phone, [In Person], [Clinic / Provider], [Virtual Visit], ReferralCount, SendToSaveOnly, SendToAllOther, ISNULL(DocFormType,'') as DocFormType, DNote_Count 
FROM #Temp_Pivot_CNote ) P 
Pivot (max(p.DNote_Count) for DocFormType in ([Assessment], [CarePlan], [Others]))as pvt
ORDER BY CaseManager, MemberID



Drop table #Temp_Pivot_CNote
Drop table #Temp_Final_D_R
Drop Table #Temp_Final_C_E
Drop table #Temp_Final
END