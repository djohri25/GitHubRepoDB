/****** Object:  Procedure [dbo].[Set_HPAlertNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Procedure [dbo].[Set_HPAlertNote]
	@AlertID int,
	@Owner varchar(50),
	@Note varchar(2000),
	@StatusID int,
	@SendToHP bit = 0,
	@SendToPCP bit = 0,
	@SendToNurtur bit = 0,
	@OnlySave bit = 0,
	@ActionTypeID	INT = null,
	@NoteTypeID	INT = null,
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

--select @AlertID = 329,
--@Owner = 'mvdadmin',
--@Note = 'some test note',
--@StatusID = 0

	--declare @alertStatusID int
	declare @MVDID varchar(30),
		@newNoteID int,
		@curDate datetime

	if not exists(select id from hpalertNote where alertID = @AlertID and note = @note and modifiedBy = @Owner)
	begin
		--select @alertStatusID = StatusID
		--from hpAlert
		--where ID = @AlertID

		select @curDate = getutcdate()

		select @mvdid = li.MVDId
		from HPAlert a
			inner join Link_MemberId_MVD_Ins li on a.MemberID = li.InsMemberId
		where a.ID = @AlertID

		insert into hpAlertNote (alertID,Note,alertStatusID,datecreated,createdby,createdByType,datemodified,modifiedby,modifiedByType, MVDID,
			SendToHP,SendToPCP,SendToNurture,SendToNone,NoteTypeID,ActionTypeID )
		values(@AlertID,@Note,@StatusID,@curDate,@Owner,'HP',@curDate,@Owner,'HP', @mvdid,
			@SendToHP,@SendToPCP,@SendToNurtur,@OnlySave, @NoteTypeID, @ActionTypeID)
		
		select @newNoteID = @@IDENTITY
		
		update HPAlert 
		set StatusID = @StatusID, DateModified = @curDate, ModifiedBy = @Owner		
		where ID = @AlertID
		
		EXEC Set_HPAgentNoteAlert
			@SourceRecordId = @newNoteID,
			@MVDId = @mvdid,
			@DateTime = @curDate,
			@SourceName = 'HPAlertNote',
			@CreatedBy = @Owner
			
		set @Result = 0
	end
	else
	begin
		set @Result = -1
	end
	
END