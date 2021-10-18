/****** Object:  Procedure [dbo].[Get_CareSpaceDocsNotesByCriteria]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CareSpaceDocsNotesByCriteria]
(
	@NoteID	INT
)
AS 
BEGIN

select N1.MVDID, N1.ID as NoteID,C.CaseID as CaseID, C.q4c CaseStatus, Note as NoteDesc,N1.CreatedBy,DateCreated as CreatedDate,CASE WHEN N1.LinkedFormID is not null Then 15 Else N1.NoteTypeID  END NoteTypeId, LC.Label NoteType, N1.LinkedFormID, N1.LinkedFormType, 
		CASE WHEN N1.LinkedFormID is not null Then 1 Else 0  END as IsEditable,
		CASE LTRIM(RTRIM(SUBSTRING(N1.CaseID,24,150))) WHEN 'Case Manager' then 'CM' WHEN 'Social Worker' then 'SW' WHEN 'Community Health Worker' then 'CHW' WHEN 'Health Management Coordinator' then 'HMC' END as SHGroup,
		N1.SessionID, N1.DocType, CONVERT(bit, ISNULL(N1.IsDelete, 0)) as IsDeleted, N1.CreatedByCompany as Tag
		from HPAlertNote N1 LEFT JOIN [dbo].[CCC_CAS_Form] C ON C.MVDID = N1.MVDID and ISNULL(C.CaseID,'') = ISNULL(N1.CaseID,'')
		JOIN Link_MemberId_MVD_Ins L ON L.MVDID = N1.MVDID 
		LEFT JOIN Lookup_Generic_Code LC ON CASE WHEN N1.LinkedFormID is not null Then 15 Else N1.NoteTypeID  END =  LC.CodeID 
		JOIN Lookup_Generic_Code_Type LCT ON LCT.CodeTypeID = LC.CodeTypeID
		WHere LCT.CodeType = 'NoteType' and N1.ID = @NoteID
END