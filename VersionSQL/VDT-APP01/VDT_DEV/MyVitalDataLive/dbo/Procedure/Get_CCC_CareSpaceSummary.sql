/****** Object:  Procedure [dbo].[Get_CCC_CareSpaceSummary]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Get_CCC_CareSpaceSummary
AS 
BEGIN
select distinct CCC.Q20A as CaseManager, 
				HAG.ID as GroupID, 
				HAG.Name as GroupName, 
				A.TriggerID as Rule_ID,
				HWFR.Name  as Rule_Desc, 
				DocNote.DateCreated, DocNote.CreatedBy, CSNF.FormName  as Doc_Description, CSNF.DocFormType as FormType,
				CNote.ModifiedBy as CNote_ModifiedBy, CNote.DateModified as CNote_ModifiedDt,
				RNote.ModifiedBy as Admin_ModifiedBy, RNote.DateModified as Admin_ModifiedDt, ENote.ModifiedBy as ENote_ModifiedBy, ENote.DateModified as ENote_ModifiedDt, 
				LEFT(case when ENote.SendToPCP = 1 then 'PCP' else '' end +case when ENote.SendToPCP = 1 then ', ' else '' end
					+case when ENote.SendToNone = 1 then 'Save Only' else '' end +case when ENote.SendToNone = 1 then ', ' else '' end
					+case when ENote.SendToOHIT = 1 then 'OHIT' else '' end +case when ENote.SendToOHIT = 1 then ', ' else '' end
					+case when ENote.SendToState = 1 then 'State' else '' end +case when ENote.SendToState = 1 then ', ' else '' end
					+case when ENote.SendToDMVendor = 1 then 'DM Vendor' else '' end +case when ENote.SendToDMVendor = 1 then ', ' else '' end,

				Case When LEN(case when ENote.SendToPCP = 1 then 'PCP' else '' end +case when ENote.SendToPCP = 1 then ', ' else '' end
				+case when ENote.SendToNone = 1 then 'Save Only' else '' end +case when ENote.SendToNone = 1 then ', ' else '' end
				+case when ENote.SendToOHIT = 1 then 'OHIT' else '' end +case when ENote.SendToOHIT = 1 then ', ' else '' end
				+case when ENote.SendToState = 1 then 'State' else '' end +case when ENote.SendToState = 1 then ', ' else '' end
				+case when ENote.SendToDMVendor = 1 then 'DM Vendor' else '' end +case when ENote.SendToDMVendor = 1 then ', ' else '' end)-1 < 0 
						THEN 
						case when ENote.SendToPCP = 1 then 'PCP' else '' end +case when ENote.SendToPCP = 1 then ', ' else '' end
						+case when ENote.SendToNone = 1 then 'Save Only' else '' end +case when ENote.SendToNone = 1 then ', ' else '' end
						+case when ENote.SendToOHIT = 1 then 'OHIT' else '' end +case when ENote.SendToOHIT = 1 then ', ' else '' end
						+case when ENote.SendToState = 1 then 'State' else '' end +case when ENote.SendToState = 1 then ', ' else '' end
						+case when ENote.SendToDMVendor = 1 then 'DM Vendor' else '' end +case when ENote.SendToDMVendor = 1 then ', ' else '' end 

						ELSE 
						LEN(case when ENote.SendToPCP = 1 then 'PCP' else '' end +case when ENote.SendToPCP = 1 then ', ' else '' end
							+case when ENote.SendToNone = 1 then 'Save Only' else '' end +case when ENote.SendToNone = 1 then ', ' else '' end
							+case when ENote.SendToOHIT = 1 then 'OHIT' else '' end +case when ENote.SendToOHIT = 1 then ', ' else '' end
							+case when ENote.SendToState = 1 then 'State' else '' end +case when ENote.SendToState = 1 then ', ' else '' end
							+case when ENote.SendToDMVendor = 1 then 'DM Vendor' else '' end +case when ENote.SendToDMVendor = 1 then ', ' else '' end)-1 END 
					) AS SendTo

from HPAlert A JOIN [dbo].[Link_HPRuleAlertGroup] HRAG ON A.TriggerID = HRAG.Rule_ID
JOIN HPAlertGroup HAG ON HAG.ID = HRAG.AlertGroup_ID
JOIN Link_MemberID_MVD_Ins L ON L.InsMemberID = A.MemberID
JOIN CCC_Memberinfo_form CCC on L.MVDID = CCC.MVDID
JOIN [dbo].[HPWorkflowRule] HWFR ON HWFR.Rule_ID = HRAG.Rule_ID
LEFT JOIN [dbo].[HPAlertNote] DocNote ON DocNote.MVDID = A.MVDID and DocNote.NoteTypeID = 10
LEFT JOIN [dbo].[HPAlertNote] CNote ON CNote.MVDID = A.MVDID and CNote.NoteTypeID = 7
LEFT JOIN [dbo].[HPAlertNote] RNote ON RNote.MVDID = A.MVDID and RNote.NoteTypeID = 8
LEFT JOIN [dbo].[HPAlertNote] ENote ON ENote.MVDID = A.MVDID and ENote.NoteTypeID = 9
LEFT JOIN [dbo].[LookupCS_MemberNoteForms] CSNF ON CSNF.ProcedureName = DocNote.LinkedFormType
WHERE A.TriggerType = 'WORKFLOW' and ISNULL(CCC.q20a, '')  <> ''
ORDER BY CCC.Q20A , HAG.ID, A.TriggerID, ENote.DateModified desc, RNote.DateModified desc, CNote.DateModified Desc, DocNote.DateCreated desc
END