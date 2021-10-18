/****** Object:  Procedure [dbo].[Upd_TestDueStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/24/2013
-- Description:	Updates the status of patient's test due
-- =============================================
CREATE PROCEDURE [dbo].[Upd_TestDueStatus]
	@MVDID varchar(50),
	@TestAbbreviation varchar(50),
	@TestDueStatusID int,
	@TestDueStatusSubID varchar(50) = null,
	@DoctorID varchar(50) = null,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

--select @MVDID = 'CW828752', @TestAbbreviation = 'W34', 
--	@TestDueStatusID = 18, @TestDueStatusSubID = '27', 
--	@DoctorID = 'sales'


	declare @testID int, @PreviousStatusID int, @DoctorFirstName varchar(50), @DoctorLastName varchar(50), 
		@DocName varchar(100), @NoteText varchar(max), @TestDueStatusName varchar(50), @curDate datetime,
		@BadPhoneNumberStatusID int
	
	select @curDate = GETUTCDATE()

	--Submeasure ID
	SELECT @testID = [ID]
	FROM [dbo].[HedisSubmeasures]
	WHERE [Abbreviation] = @TestAbbreviation

	select @BadPhoneNumberStatusID = ID
	from LookupTestDueStatus 
	where Name = 'Bad Phone number'

	select @PreviousStatusID = isnull(StatusID,0)
	from HedisTestStatus
	where MVDID = @MVDID
		and TestID = @testID

	if(@PreviousStatusID is null)
	begin
		set @PreviousStatusID = 0
	end
	
	if(@TestDueStatusID = 0)
	begin
		select @TestDueStatusID = null, @TestDueStatusName = '[Blank]'
	end
	else
	begin
	
		if exists(select top 1 * from LookupTestDueStatus where ID = @TestDueStatusID and Name like 'Notify%'
			and isnull(@TestDueStatusSubID,'') <> '' and @TestDueStatusSubID <> '0')
		begin
			-- Save sub-status ID because it could be tracked back to parent status
			select @TestDueStatusName = Name + ': ' + 
				isnull((select top 1 ds.Name from LookupTestDueStatus ds where ds.ID = @TestDueStatusSubID),'')
			from LookupTestDueStatus		
			where ID = @TestDueStatusID		
			
			select @TestDueStatusID = @TestDueStatusSubID 				
		end
		else if exists(select top 1 * from LookupTestDueStatus where ID = @TestDueStatusID and Name like 'Remind%')
		begin
			-- 'Remind in X Days' status requires the number of days to be saved in seperate table
			select @TestDueStatusName = Name + ': ' + 
				isnull(@TestDueStatusSubID + ' Days','')
			from LookupTestDueStatus		
			where ID = @TestDueStatusID			
		end
		else
		begin
			select @TestDueStatusName = Name
			from LookupTestDueStatus		
			where ID = @TestDueStatusID		
		end
	end
	
	select @DoctorFirstName = FirstName, @DoctorLastName = LastName
	from MDUser
	where Username = @DoctorID
	
	if(ISNULL(@DoctorFirstName,'') <> '' AND ISNULL(@DoctorLastName,'') <> '')
	begin
		set @DocName = @DoctorFirstName + ' ' + @DoctorLastName
	end
	else
	begin
		set @DocName = @DoctorID
	end	
		
	delete from HedisTestStatus
	where MVDID = @MVDID  and TestID = @testID

	insert HedisTestStatus (MVDID, memberid, TestID, StatusID, RemindInDaysCount, CreatedBy)
	Select @MVDID, insmemberid, @testID, @TestDueStatusID, 
		case
			when isnull(@TestDueStatusSubID,0) = 0 then null
			else @TestDueStatusSubID
		end, 
		@DoctorID 
	from [dbo].[Link_MemberId_MVD_Ins]
	where mvdid = @mvdid

	
	-- if previously the status for all tests was set to 'bad phone number' and 
	-- the status is changed to something else then also remove bad phone number status for other tests
	if (@TestDueStatusID <> @PreviousStatusID 
		and @PreviousStatusID = @BadPhoneNumberStatusID)
	begin
		delete from HedisTestStatus
		where MVDID = @MVDID and StatusID = @BadPhoneNumberStatusID
	end
		
	if (@TestDueStatusID = @BadPhoneNumberStatusID)
	begin
		-- if bad phone number then update statuses of all tests for that member
		delete from HedisTestStatus
		where MVDID = @MVDID

		insert HedisTestStatus (MVDID, memberid, TestID, StatusID, CreatedBy )
		Select distinct li.MVDID, insmemberid, h.testID, @TestDueStatusID, @DoctorID
		from [dbo].[Link_MemberId_MVD_Ins] li 
			inner join Final_HEDIS_Member h on li.MVDId = h.MVDID
		where li.MVDID = @MVDID
	end
	
	if(@DoctorID is not null 
		AND (
				(@PreviousStatusID is null AND @TestDueStatusID is not null) 
				OR isnull(@PreviousStatusID,0) <> isnull(@TestDueStatusID,0)
			)
		)
	begin	
		select @NoteText = @DocName + ' reviewed the Hedis measure ' + @TestAbbreviation + ' and changed the status to `'
			+ @TestDueStatusName + '`'
		
		insert into HPAlertNote(Note,DateCreated,CreatedBy,DateModified,ModifiedBy,MVDID,CreatedByType, ModifiedByType,Active)
		values(@NoteText,@curDate,@DoctorID,@curDate,@DoctorID,@MVDID,'MD','MD',1)		
	end
	
	set @Result = 0		
END



/* BK 9/6/2015 by Sly

	declare @testID int, @PreviousStatusID int, @DoctorFirstName varchar(50), @DoctorLastName varchar(50), 
		@DocName varchar(100), @NoteText varchar(max), @TestDueStatusName varchar(50), @curDate datetime
	
	select @curDate = GETUTCDATE()

	select @testID = ID
	from HEDIS_Results.dbo.LookupHedis
	where Abbreviation = @TestAbbreviation

	delete from MainToDoHEDIS_RemindIn_NEW where MVDID = @MVDID and TestID = @testID
	
	if(@TestDueStatusID = 0)
	begin
		select @TestDueStatusID = null, @TestDueStatusName = '[Blank]'
	end
	else
	begin
	
		if exists(select top 1 * from LookupTestDueStatus where ID = @TestDueStatusID and Name like 'Notify%'
			and isnull(@TestDueStatusSubID,'') <> '' and @TestDueStatusSubID <> '0')
		begin
			-- Save sub-status ID because it could be tracked back to parent status
			select @TestDueStatusName = Name + ': ' + 
				isnull((select top 1 ds.Name from LookupTestDueStatus ds where ds.ID = @TestDueStatusSubID),'')
			from LookupTestDueStatus		
			where ID = @TestDueStatusID		
			
			select @TestDueStatusID = @TestDueStatusSubID 				
		end
		else if exists(select top 1 * from LookupTestDueStatus where ID = @TestDueStatusID and Name like 'Remind%')
		begin
			-- 'Remind in X Days' status requires the number of days to be saved in seperate table
			select @TestDueStatusName = Name + ': ' + 
				isnull(@TestDueStatusSubID + ' Days','')
			from LookupTestDueStatus		
			where ID = @TestDueStatusID		
					
			if(isnull(@TestDueStatusSubID,'') <> '' and @TestDueStatusSubID <> '0')
			begin
				insert into MainToDoHEDIS_RemindIn_NEW(	DaysCount,MVDID,TestID,CreatedBy)
				values(@TestDueStatusSubID, @MVDID,@testID,@DoctorID)
			end		
		end
		else
		begin
			select @TestDueStatusName = Name
			from LookupTestDueStatus		
			where ID = @TestDueStatusID		
		end
	end
	
	select @DoctorFirstName = FirstName, @DoctorLastName = LastName
	from MDUser
	where Username = @DoctorID
	
	if(ISNULL(@DoctorFirstName,'') <> '' AND ISNULL(@DoctorLastName,'') <> '')
	begin
		set @DocName = @DoctorFirstName + ' ' + @DoctorLastName
	end
	else
	begin
		set @DocName = @DoctorID
	end
		
	select @PreviousStatusID = isnull(StatusID,0)
	from MainToDoHEDIS_NEW
	where MVDID = @MVDID
		and TestLookupID = @testID		
		
		
	if not exists (	select * from MainToDoHEDIS_NEW
					where 	 MVDID = @MVDID  and TestLookupID = @testID)
	Begin
		insert MainToDoHEDIS_NEW (MVDID, memberid, Major,Minor, TestLookupID, Source )
		Select @MVDID, insmemberid,@TestDueStatusName,'', @testID, 'HEDIS : Demo' from [dbo].[Link_MemberId_MVD_Ins]
		where mvdid = @mvdid

		Select @PreviousStatusID = 0
	END
	
	-- if previously the status for all tests was set to 'bad phone number' and 
	-- the status is changed to something else then also remove bad phone number status for other tests
	if (@TestDueStatusID <> @PreviousStatusID 
		and exists(select * from LookupTestDueStatus where ID = @PreviousStatusID and Name = 'Bad Phone number')
		)
	begin
		update MainToDoHEDIS_NEW
		set StatusID = null,
			StatusIDSaveDate = @curDate,
			StatusUpdatedBy = @DoctorID
		where MVDID = @MVDID 
	end
		
	if exists(select * from LookupTestDueStatus where ID = @TestDueStatusID and Name = 'Bad Phone number')
	begin
		-- if bad phone number then update statuses of all tests for that member
		update MainToDoHEDIS_NEW
		set StatusID = @TestDueStatusID,
			StatusIDSaveDate = @curDate,
			StatusUpdatedBy = @DoctorID
		where MVDID = @MVDID
		
		--update [VD-RPT01].[_All_2015_Predictive_HEDIS].dbo.[Final_HEDIS_Member] --MDUser_Member
		--set TestStatusID= @TestDueStatusID,
		--	StatusIDSaveDate = @curDate
		--where MVDID = @MVDID
	end
	else
	begin		
		update MainToDoHEDIS_NEW
		set StatusID = @TestDueStatusID,
			StatusIDSaveDate = @curDate,
			StatusUpdatedBy = @DoctorID
		where MVDID = @MVDID
			and TestLookupID = @testID
		
		--update [VD-RPT01].[_All_2015_Predictive_HEDIS].dbo.[Final_HEDIS_Member]--MDUser_Member
		--set TestStatusID= @TestDueStatusID,
		--	StatusIDSaveDate = @curDate
		--where MVDID = @MVDID
		--	and TestID = @testID
	end
	
	if(@DoctorID is not null 
		AND (
				(@PreviousStatusID is null AND @TestDueStatusID is not null) 
				OR isnull(@PreviousStatusID,0) <> isnull(@TestDueStatusID,0)
			)
		)
	begin	
		select @NoteText = @DocName + ' reviewed the Hedis measure ' + @TestAbbreviation + ' and changed the status to `'
			+ @TestDueStatusName + '`'
		
		insert into HPAlertNote(Note,DateCreated,CreatedBy,DateModified,ModifiedBy,MVDID,CreatedByType, ModifiedByType,Active)
		values(@NoteText,@curDate,@DoctorID,@curDate,@DoctorID,@MVDID,'MD','MD',1)		
	end
	
	set @Result = 0	
	
	
*/	