/****** Object:  Procedure [dbo].[Get_AlertNotesByMvdId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/26/2016
-- Description:	Get all HpAlertNote data based on mvdId.
--------------------------------------------------------
--	Date		User		Update
--------------------------------------------------------
--	03/14/17	dpatel		Updated SP to retrieve label from Lookup_Generic_Code table for all types of Lookup values.
-- 07/27/2017	ppetluri	Added comma seperated Groupnames
-- =============================================
CREATE PROCEDURE [dbo].[Get_AlertNotesByMvdId]
	@MvdId varchar(50),
	@NoteTypeId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @GroupNames varchar(2000)
	Select @GroupNames = SUBSTRING((SELECT DISTINCT ',' + CAST(LTRIM(RTRIM(ISNULL(A.Name,''))) as varchar(20))
	 from 
	 (Select Distinct G.Name From
	 [dbo].[HPAlertNote] han
	JOIN HPAlert A ON A.MVDID = han.MVDID and TriggerID = han.ID JOIN [HPAlertGroup] G ON A.AgentID = G.ID and A.RecipientCustID = G.Cust_ID
	where han.MVDID = @MvdId
	and (han.NoteTypeID = @NoteTypeId)	
	And TriggerType = 'Note') A
	FOR XML PATH ('')), 2, 1000) 

    SELECT han.[ID]
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
	  ,(select lgc.Label from Lookup_Generic_Code lgc where lgc.CodeID = han.NoteTypeID) as 'NoteType'
      ,han.[ActionTypeID]
	  ,(select lgc.Label from Lookup_Generic_Code lgc where lgc.CodeID = han.ActionTypeID) as 'ActionTypeLabel'
	  ,(select lgc.Label_Desc from Lookup_Generic_Code lgc where lgc.CodeID = han.ActionTypeID) as 'ActionTypeDescription'
      ,han.[DueDate]
      ,han.[CompletedDate]
      ,han.[NoteTimestampId]
	  ,(select lgc.Label from Lookup_Generic_Code lgc where lgc.CodeID = han.NoteTimestampId) as 'NoteTimestamp'
      ,han.[NoteSourceId]
	  ,(select lgc.Label from Lookup_Generic_Code lgc where lgc.CodeID = han.NoteSourceId) as 'NoteSource'
	  ,(select COUNT(ID) from HPAlert where TriggerType = 'Note' and TriggerID = han.ID) as 'ReferralCount'
	  ,CASE WHEN (select COUNT(ID) from HPAlert where TriggerType = 'Note' and TriggerID = han.ID) >0 THEN @GroupNames ELSE NULL END as 'ReferralGroups'
	  ,han.SendToMyVitalDataMobile
	  ,han.SendToOHIT
	  ,han.SendToState
	  ,han.SendToDMVendor
  FROM [dbo].[HPAlertNote] han
  where han.MVDID = @MvdId
	and (han.NoteTypeID = @NoteTypeId)	-- or @NoteTypeId is null)
  order by han.DateCreated desc
END