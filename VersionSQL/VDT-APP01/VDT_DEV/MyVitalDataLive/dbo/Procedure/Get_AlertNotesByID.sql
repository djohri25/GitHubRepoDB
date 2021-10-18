/****** Object:  Procedure [dbo].[Get_AlertNotesByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: MDeLuca
-- Create date: 03/01/2018
-- Description:	Copied proc FROM Get_AlertNotesByMvdId
-- Example: EXEC dbo.Get_AlertNotesByID @ID = 106666
-- =============================================
CREATE PROCEDURE [dbo].[Get_AlertNotesByID]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GroupNames VARCHAR(2000)

	SELECT @GroupNames = SUBSTRING((SELECT DISTINCT ',' + CAST(LTRIM(RTRIM(ISNULL(A.Name,''))) AS VARCHAR(20))
	FROM 
	(SELECT DISTINCT G.Name 
		FROM dbo.HPAlertNote han
		JOIN HPAlert A ON A.MVDID = han.MVDID AND TriggerID = han.ID 
		JOIN [HPAlertGroup] G ON A.AgentID = G.ID AND A.RecipientCustID = G.Cust_ID
	WHERE han.ID = @ID
	AND TriggerType = 'Note') A
	FOR XML PATH ('')), 2, 1000) 

	SELECT 
	 han.[ID]
	,han.[AlertID]
	,han.[Note]
	,han.[AlertStatusID]
	,han.[DateCreated]
	,han.[CreatedBy]
	,han.[DateModified]
	,han.[ModifiedBy]
	,han.[CreatedByCompany]
	,han.[ModifiedByCompany]
	,han.[MVDID]
	,han.[CreatedByType]
	,han.[ModifiedByType]
	,han.[Active]
	,han.[SendToHP]
	,han.[SendToPCP]
	,han.[SendToNurture]
	,han.[SendToNone]
	,han.[LinkedFormType]
	,han.[LinkedFormID]
	,han.[NoteTypeID]
	,(SELECT lgc.Label FROM dbo.Lookup_Generic_Code lgc WHERE lgc.CodeID = han.NoteTypeID) as 'NoteType'
	,han.[ActionTypeID]
	,(SELECT lgc.Label FROM dbo.Lookup_Generic_Code lgc WHERE lgc.CodeID = han.ActionTypeID) as 'ActionTypeLabel'
	,(SELECT lgc.Label_Desc FROM dbo.Lookup_Generic_Code lgc WHERE lgc.CodeID = han.ActionTypeID) as 'ActionTypeDescription'
	,han.[DueDate]
	,han.[CompletedDate]
	,han.[NoteTimestampId]
	,(SELECT lgc.Label FROM dbo.Lookup_Generic_Code lgc WHERE lgc.CodeID = han.NoteTimestampId) as 'NoteTimestamp'
	,han.[NoteSourceId]
	,(SELECT lgc.Label FROM dbo.Lookup_Generic_Code lgc WHERE lgc.CodeID = han.NoteSourceId) as 'NoteSource'
	,(SELECT COUNT(ID) FROM dbo.HPAlert WHERE TriggerType = 'Note' AND TriggerID = han.ID) as 'ReferralCount'
	,CASE WHEN (SELECT COUNT(ID) FROM dbo.HPAlert WHERE TriggerType = 'Note' AND TriggerID = han.ID) > 0 THEN @GroupNames ELSE NULL END as 'ReferralGroups'
	,han.SendToMyVitalDataMobile
	,han.SendToOHIT
	,han.SendToState
	,han.SendToDMVendor
	FROM dbo.HPAlertNote han
	WHERE han.ID = @ID
	ORDER BY han.DateCreated DESC
END