/****** Object:  Procedure [dbo].[Set_CareSpaceAlertNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/27/2016
-- Description:	saves the alter note data from Care space and returns identity value.
-- =============================================
CREATE PROCEDURE [dbo].[Set_CareSpaceAlertNote]
	@AlertID int= null,
	@Note varchar(MAX)= null,
	@AlertStatusID int= null,
	@DateCreated datetime= null,
	@CreatedBy varchar(50)= null,
	@DateModified datetime= null,
	@ModifiedBy varchar(50)= null,
	@CreatedByCompany varchar(50)= null,
	@ModifiedByCompany varchar(50)= null,
	@MVDID varchar(30)= null,
	@CreatedByType varchar(50)= null,
	@ModifiedByType varchar(50)= null,
	@Active bit= null,
	@SendToHP bit= null,
	@SendToPCP bit= null,
	@SendToNurture bit= null,
	@SendToNone bit= null,
	@LinkedFormType varchar(50)= null,
	@LinkedFormID int= null,
	@NoteTypeID int= null,
	@ActionTypeID int= null,
	@DueDate datetime= null,
	@CompletedDate datetime= null,
	@NoteTimestampId int= null,
	@NoteSourceId int=null,
	@SendToMyVitalDataMobile bit = null,
	@SendToOHIT bit = null,
	@SendToState bit = null,
	@SendToDMVendor bit = null,
	@CaseID	varchar(100) = null,
	@ReturnId int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	IF (ISNULL(@NoteTypeID,'')= '')
	BEGIN
		IF (ISNULL(@LinkedFormType,'') <> '' and ISNULL(@LinkedFormID,'') <> '')
		BEGIN
			Select @NoteTypeID = CodeID from Lookup_Generic_Code GC JOIN Lookup_Generic_Code_Type  GCT ON GCT.CodeTypeID = GC.CodeTypeID Where GCT.CodeType = 'NoteType' and GC.[Label] = 'DocumentNote'
		END
	END

	INSERT INTO [dbo].[HPAlertNote]
           ([AlertID]
           ,[Note]
           ,[AlertStatusID]
           ,[DateCreated]
           ,[CreatedBy]
           ,[DateModified]
           ,[ModifiedBy]
           ,[CreatedByCompany]
           ,[ModifiedByCompany]
           ,[MVDID]
           ,[CreatedByType]
           ,[ModifiedByType]
           ,[Active]
           ,[SendToHP]
           ,[SendToPCP]
           ,[SendToNurture]
           ,[SendToNone]
           ,[LinkedFormType]
           ,[LinkedFormID]
           ,[NoteTypeID]
           ,[ActionTypeID]
           ,[DueDate]
           ,[CompletedDate]
           ,[NoteTimestampId]
           ,[NoteSourceId]
		   ,SendToMyVitalDataMobile
		   ,SendToOHIT
		   ,SendToState
		   ,SendToDMVendor
		   ,CaseID)
     VALUES
           (@AlertID
			,@Note
			,@AlertStatusID
			,@DateCreated
			,@CreatedBy
			,@DateModified
			,@ModifiedBy
			,@CreatedByCompany
			,@ModifiedByCompany
			,@MVDID
			,@CreatedByType
			,@ModifiedByType
			,@Active
			,@SendToHP
			,@SendToPCP
			,@SendToNurture
			,@SendToNone
			,@LinkedFormType
			,@LinkedFormID
			,@NoteTypeID
			,@ActionTypeID
			,@DueDate
			,@CompletedDate
			,@NoteTimestampId
			,@NoteSourceId
			,@SendToMyVitalDataMobile
		    ,@SendToOHIT
		    ,@SendToState
		    ,@SendToDMVendor
			,@CaseID)

		set @ReturnId = @@IDENTITY
END