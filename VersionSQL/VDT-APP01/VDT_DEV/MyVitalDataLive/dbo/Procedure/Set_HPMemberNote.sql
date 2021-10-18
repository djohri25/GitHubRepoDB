/****** Object:  Procedure [dbo].[Set_HPMemberNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
------------------------------------------------
--	User		Date		Update
------------------------------------------------
--	dpatel		07/25/2017	Updated store proc to insert Clinical Note's noteTypeId to HpAlertNote table. It will link legacy note to clinical note(s) of carespace.
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPMemberNote]
	@MVDID varchar(50),
	@Owner varchar(50),
	@UserType varchar(20) = 'HP',
	@Note varchar(2000),
	@StatusID int,	
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @newNoteID int,
		@curDate datetime,
		@noteTypeId int

--select * from MainPersonalDetails p
--	inner join link_memberid_mvd_ins li on p.icenumber = li.mvdid

--select @MVDID = 'ZT014859',
--@Owner = 'mvdadmin',
--@Note = 'some test note 4',
--@StatusID = 0

	Declare @CaseID varchar(100), @GroupName	varchar(100)

	SELECT @GroupName = StakeholderGroup  FROM Link_CCC_UserSHGroup SHG JOIN [dbo].[CCC_StakeholderGroup] SG ON SG.ID = SHG.SHGroupID
	Where SHG.UserName = @Owner

	Select top 1 @CaseID = C.CaseID from CCC_CAS_Form C 
	where MVDID = @MVDID 
	and CaseID like '%'+ @GroupName +'%' 
	and ISNULL(q4c, '') in ('Open', 'Pended') 
	and FormDate = (Select MAX(FormDate) from CCC_CAS_Form C1 Where C1.MVDID = C.MVDID and CaseID like '%' + @GroupName + '%')


	select @noteTypeId = lgc.CodeID
	from Lookup_Generic_Code lgc
	join Lookup_Generic_Code_Type lgct on lgc.CodeTypeID = lgct.CodeTypeID
	where lgct.CodeType = 'NoteType' and lgc.Label = 'ClinicalNote'

	if not exists(select id from HPAlertNote where MVDID = @MVDID and note = @note and modifiedBy = @Owner)
	begin
		select @curDate = getutcdate()
		
		insert into HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,datemodified,modifiedby,ModifiedByType,NoteTypeID, CaseID)
		values(@MVDID,@Note,@StatusID,@curDate,@Owner,@UserType,@curDate,@Owner,@UserType,@noteTypeId, @CaseID)
		
		select @newNoteID = @@IDENTITY
				
		EXEC Upd_HPMemberUpdater
			@MVDID = @MVDID,
			@UpdaterUsername = @Owner,
			@StatusID = @StatusID
			
		EXEC Set_HPAgentNoteAlert
			@SourceRecordId = @newNoteID,
			@MVDId = @MVDID,
			@DateTime = @curDate,
			@SourceName = 'hpMemberNote',
			@CreatedBy = @Owner			

		set @Result = 0
	end
	else
	begin
		set @Result = -1
	end
	
END