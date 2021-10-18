/****** Object:  Procedure [dbo].[Get_AllNotes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<dpatel>
-- Create date: <11/20/2017>
-- Description:	<Get all notes except document from HPAlertNote table.>
-- =============================================
CREATE PROCEDURE [dbo].[Get_AllNotes]
	@MvdId varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @codeTypeId int, @codeId int

	select @codeTypeId = CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'NoteType'
	select @codeId = CodeID  from Lookup_Generic_Code where CodeTypeID = @codeTypeId and Label = 'DocumentNote'
    
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
	  --,CASE WHEN (select COUNT(ID) from HPAlert where TriggerType = 'Note' and TriggerID = han.ID) >0 THEN @GroupNames ELSE NULL END as 'ReferralGroups'
	  ,han.SendToMyVitalDataMobile
	  ,han.SendToOHIT
	  ,han.SendToState
	  ,han.SendToDMVendor
  FROM [dbo].[HPAlertNote] han
  where han.MVDID = @MvdId
	and han.NoteTypeID not in (@codeId)
  order by han.DateCreated desc

END