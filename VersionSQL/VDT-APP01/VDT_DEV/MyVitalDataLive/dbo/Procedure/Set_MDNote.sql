/****** Object:  Procedure [dbo].[Set_MDNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 7/7/2009
-- Description:	Create new MD note
-- =============================================
CREATE PROCEDURE [dbo].[Set_MDNote]
	@MvdID varchar(15),
	@Text varchar(2000),
	@UserID varchar(50),
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	declare @newNoteID int,
		@curDate datetime
		
	if not exists(select id from hpalertNote where mvdid = @MvdID and note = @Text and modifiedBy = @UserID and Active = 1)
	begin
		select @curDate = getutcdate()
			
		insert into hpAlertNote (alertID,Note,alertStatusID,datecreated,createdby,createdByType,datemodified,modifiedby,modifiedByType, MVDID)
		values(null,@Text,null,@curDate,@UserID,'MD',@curDate,@UserID,'MD',@mvdid)
		
		select @newNoteID = @@IDENTITY
			
		EXEC Set_HPAgentNoteAlert
			@SourceRecordId = @newNoteID,
			@MVDId = @MVDID,
			@DateTime = @curDate,
			@SourceName = 'hpAlertNoteMD',
			@CreatedBy = @UserID	
					
		set @Result = 0
	end
	else
	begin
		set @Result = -1
	end
		
	--insert into MD_Note (MvdID,Text,CreatedByUserID,Created,ModifyByUserID,ModifyDate)
	--values (@MvdID, @Text, @UserID, getutcdate(),@UserID,getutcdate())
	
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = LEFT('@MvdID=' + ISNULL(@MvdID, 'null') + ';' +
					   '@UserID=' + ISNULL(@UserID, 'null') + ';' +
					   '@Text=' + ISNULL(@Text, 'null') + ';', 1000);
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Set_MDNote]', @EMS, @UserID_SSO, @params

END