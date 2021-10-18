/****** Object:  Procedure [dbo].[Upd_TestDueCurrentStatuses]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/23/2014
-- Description:	Update test status based on status expiration date and current member info
-- =============================================
CREATE PROCEDURE [dbo].[Upd_TestDueCurrentStatuses]
AS
BEGIN
	SET NOCOUNT ON;


	declare @newStatusID int, @curDate datetime, @noPhoneStatusID int

	select @curDate = GETDATE()

	select @newStatusID = ID
	from LookupTestDueStatus
	where Name = 'New'

	update MainToDoHEDIS
	set StatusID = @newStatusID,
		StatusIDSaveDate = @curDate,
		StatusUpdatedBy = 'admin'
	from MainToDoHEDIS h	
		inner join Link_MemberId_MVD_Ins m on h.MVDID = m.MVDId
		inner join Link_TestDueStatus_Customer c on h.TestLookupID = c.StatusID and m.Cust_ID = c.CustID
	where h.StatusID is not null and h.StatusID <> @newStatusID
		and DATEADD(day,c.RemoveAfterDayCount, h.StatusIDSaveDate) < @curDate

	update MDUser_Member
	set TestStatusID = @newStatusID,
		StatusIDSaveDate = @curDate
	from MDUser_Member h	
		inner join Link_MemberId_MVD_Ins m on h.MVDID = m.MVDId
		inner join Link_TestDueStatus_Customer c on h.TestID = c.StatusID and m.Cust_ID = c.CustID
	where h.TestStatusID is not null and h.TestStatusID <> @newStatusID
		and DATEADD(day,c.RemoveAfterDayCount, h.StatusIDSaveDate) < @curDate


	--select @noPhoneStatusID = ID
	--from LookupTestDueStatus 
	--where Name = 'No Phone Number'

	-- 7/9/2014 per Driscoll request if no phone # on record then set status to 'Bad phone #'
	select @noPhoneStatusID = ID
	from LookupTestDueStatus 
	where Name = 'Bad Phone number'
	
	if( @noPhoneStatusID is not null)
	begin
		-- Set status 'No phone number' to members without phone number
		update MainToDoHEDIS
		set StatusID = @noPhoneStatusID,
			StatusIDSaveDate = @curDate,
			StatusUpdatedBy = 'admin'
		from MainToDoHEDIS h	
			inner join MainPersonalDetails p on h.MVDID = p.ICENUMBER
		where p.HomePhone is null or p.HomePhone = ''

		update MDUser_Member
		set testStatusID = @noPhoneStatusID,
			StatusIDSaveDate = @curDate
		from MDUser_Member h	
			inner join MainPersonalDetails p on h.MVDID = p.ICENUMBER
		where p.HomePhone is null or p.HomePhone = ''

		-- if phone number was provided recently set the status back to new

		update MainToDoHEDIS
		set StatusID = @newStatusID,
			StatusIDSaveDate = @curDate,
			StatusUpdatedBy = 'admin'
		from MainToDoHEDIS h	
			inner join MainPersonalDetails p on h.MVDID = p.ICENUMBER
		where p.HomePhone is not null and p.HomePhone <> ''
			and h.StatusID = @noPhoneStatusID

		update MDUser_Member
		set testStatusID = @newStatusID,
			StatusIDSaveDate = @curDate
		from MDUser_Member h	
			inner join MainPersonalDetails p on h.MVDID = p.ICENUMBER
		where p.HomePhone is not null and p.HomePhone <> ''
			and h.testStatusID = @noPhoneStatusID
	end

END