/****** Object:  Procedure [dbo].[Get_DuplicateRecordList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/17/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_DuplicateRecordList]
	@CustomerID int
AS
BEGIN
	SET NOCOUNT ON;

--select @CustomerID = 10

	-- group ID is unique id for each group of records with same values for matching fields
	declare @curGroupID int

	declare @temp table(personRecordID int, mvdid varchar(20), groupID int, firstname varchar(50), lastname varchar(50), dob datetime,
		address1 varchar(50), city varchar(50),state varchar(50), phone varchar(50),ssn varchar(20), hpName varchar(50),insurance varchar(max), 
		isprocessed bit default(0))
		
	declare	@personRecordID int, @mvdid varchar(20), @firstname varchar(50), @lastname varchar(50),
		@address1 varchar(50), @city varchar(50),@state varchar(50), @phone varchar(50),@ssn varchar(20), @hpName varchar(50)	

	set @curGroupID = 1
	
	-- As of 12/20/2010, the only  linking field is SSN
	insert into @temp (personRecordID, mvdid,firstname, lastname,dob,
		address1, city,state, phone,ssn, hpName, insurance)
	select p.RecordNumber as 'PersonalRecordID', p.ICENUMBER, FirstName,LastName,dob, p.Address1, 
		p.City,p.State, p.HomePhone, SSN,c.Name as 'hpName',
		dbo.Get_InsuranceList(p.ICENUMBER)
	from MainPersonalDetails p
		inner join Link_MVDID_CustID li on p.ICENUMBER = li.MVDId
		inner join HPCustomer c on li.Cust_ID = c.Cust_ID	
	where li.Cust_ID = @CustomerID 
		AND SSN in
		(
			select top 10 pp.SSN
			from MainPersonalDetails pp
				inner join Link_MVDID_CustID lim on pp.ICENUMBER = lim.MVDId
			where lim.Cust_ID = @CustomerID AND isnull(pp.SSN,'') <> '' 
				AND pp.SSN <> '000000000'
				AND lim.IsArchived = 0
				and lim.Active = 1
			group by pp.SSN
			having COUNT(RecordNumber) > 1
		)

	-- Assign group ID for matching records
	while exists(select personRecordID from @temp where groupID is null)
	begin
		select top 1 
			@personRecordID = personRecordID,
			@mvdid = mvdid,
			@firstname = firstname,
			@lastname = lastname,
			@address1 = address1,
			@city = city,
			@state = state,
			@phone = phone,
			@ssn = ssn,
			@hpName = hpName
		from @temp
		where groupID is null
		 
		-- Add new criteria to where clause
		update @temp set groupID = @curGroupID
		where ssn = @ssn	
			
		set @curGroupID = @curGroupID + 1
	end
	
	-------------------------------------------------------------------------------
	-- Remove all members of the group from the list only if ALL members MVDIDs combinations were marked as IGNORE
	declare @iterX int, @iterY int, @mvdid1 varchar(20), @mvdid2 varchar(20), 
		@isGroupModified bit -- set to true if any of the groups were eliminated as result of IGNORE flag
	declare @groups table(id int, isprocessed bit default(0))
	declare @groupMVDIDs table(mvdid varchar(20), isprocessed bit default(0))
	
	set @isGroupModified = 0
	insert into @groups(id)
	select distinct groupid from @temp
	
	while exists(select top 1 id from @groups where isprocessed = 0)
	begin
		select @curGroupID = ID from @groups where isprocessed = 0

		insert into @groupMVDIDs(mvdid)
		select mvdid from @temp where groupID = @curGroupID		
		
		declare @numOfIter int, @numOfIgnored int
		
		select @numOfIter = 0, 
			@numOfIgnored = 0
		
		while exists(select top 1 mvdid from @groupMVDIDs)
		begin
			select top 1 @mvdid1 = mvdid from @groupMVDIDs
		
			update @groupMVDIDs set isprocessed = 1 where mvdid = @mvdid1
			
			while exists(select top 1 mvdid from @groupMVDIDs where isprocessed = 0)
			begin
				select top 1 @mvdid2 = mvdid from @groupMVDIDs where isprocessed = 0
				set @numOfIter = @numOfIter + 1	
				
				if exists(select MVDID_1 from Link_DuplicateRecords where MVDID_1 = @mvdid1 and MVDID_2 = @mvdid2 and Status = 'IGNORE')
					OR exists(select MVDID_1 from Link_DuplicateRecords where MVDID_2 = @mvdid1 and MVDID_1 = @mvdid2 and Status = 'IGNORE')
				begin
					set @numOfIgnored = @numOfIgnored + 1
				end
				
				update @groupMVDIDs set isprocessed = 1 where mvdid = @mvdid2
			end
						
			delete from @groupMVDIDs where mvdid = @mvdid1
			
			update @groupMVDIDs set isProcessed = 0
		end
		
		if(@numOfIter = @numOfIgnored)
		begin
			-- All combinations of MVD ID were marked as IGNORE
			delete from @temp where groupID = @curGroupID
			set @isGroupModified = 1
		end
		
		update @groups set isprocessed = 1 where id = @curGroupID
	end	
	
	if(@isGroupModified = 1)
	begin
		-- redo group numbering
		delete from @groups	
		
		insert into @groups(id)		
		select distinct groupID from @temp
		
		set @iterX = 1
		
		while exists(select top 1 id from @groups where isprocessed = 0)
		begin
			select @curGroupID = ID from @groups where isprocessed = 0
			
			update @temp set groupID = @iterX, isprocessed = 1 where isprocessed = 0 and groupID = @curGroupID
					
			set @iterX = @iterX + 1
			update @groups set isprocessed = 1 where id = @curGroupID
		end
	end	
	
	select groupID, personRecordID, mvdid, FirstName, lastname,convert(varchar,dob,1) as dob,
		address1, city,state, phone,ssn, hpName, insurance
	from @temp
	
END