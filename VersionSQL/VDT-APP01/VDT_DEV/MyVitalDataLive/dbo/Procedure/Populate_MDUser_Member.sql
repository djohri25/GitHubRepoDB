/****** Object:  Procedure [dbo].[Populate_MDUser_Member]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 10/15/2012
-- Description: Populates list of patients assigned
--	to a MD users (doctor) and to the groups the
--  doctor belongs to
-- =============================================
CREATE PROCEDURE [dbo].[Populate_MDUser_Member] @CUstID int
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempMDUser table (userID int, username varchar(50), IsProcessed bit default(0))
	declare @tempTest table(ID int, Abbreviation varchar(10))
	
	declare @PCPLookupId int, @tempMvdid varchar(15), @username varchar(50), @currentDate date, @userID int

	insert into @tempTest(ID,Abbreviation)
    select ID, Abbreviation 
    from HEDIS_Results.dbo.LookupHedis
	where testtype is null OR testtype <> 'PDI'
		and id in
		(
			 select distinct TestDueID from dbo.HPTestDueGoal where DRLink_Active = 1
		)

	select @PCPLookupId = null,
		@currentDate = GETDATE()

	select @PCPLookupId = roleID  
	from LookupRoleID 
	where rolename = 'Primary Care Physician'


	--select * from mduser

	if (@Custid = 11)
	BEGIN
		insert into @tempMDUser(userID, username)
		select ID,username
		from MDUser
		where --Active = 1 and 
		Organization like '%Driscoll%'
		order by LastLogin desc
	end
	ELSE
	BEGIN
		insert into @tempMDUser(userID, username)
		select ID,username
		from MDUser
		where Active = 1
		and 
		organization not like '%Driscoll%'
		order by LastLogin desc
	
	END	


	begin try
		truncate table Sly_Logger
	end try
	begin catch
	
	end catch


	Create Table #MDUser_Member 
	([DoctorID] [varchar](50) NULL,
	[DoctorUsername] [varchar](50) NULL,
	[HPName] [varchar](50) NULL,
	[CustID] [int] NULL,
	[MemberID] [varchar](50) NULL,
	[MVDID] [varchar](20) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[PCP_NPI] [varchar](50) NULL,
	[PCP_TIN] [varchar](20) NULL,
	[TestID] [int] NULL,
	[IsTestDue] [char](1) NULL,
	[TestStatusID] [int] NULL
	 )

		
--select * from  Sly_Logger
	
	while exists (select top 1 * from @tempMDUser where IsProcessed = 0)
	begin
		select  top 1 @userID = userID, @username = username from @tempMDUser where IsProcessed = 0

		--Moved to end of loop
		--delete from MDUser_Member where DoctorUsername = @username

		begin try
			insert into Sly_Logger(Message) values('Populate_MDUser_Member, processing: ' + @username)
		end try
		begin catch
		
		end catch

		--Added 
		truncate table #MDUser_Member
		
		-- NOTE: Asthma and Diabetes flags indicate patients with those diagnosis, they don't mean test is due
		insert into #MDUser_Member (doctorID, DoctorUsername, hpName, custid, memberid, mvdid,
			MemberFirstName,MemberLastName,PCP_NPI,PCP_TIN,
			TestID,IsTestDue, TestStatusID)
		select  
			u.id, u.Username,c.name,mi.cust_id,mi.insMemberId,p.icenumber,
			isnull(p.firstname,''), isnull(p.lastname,''),s.NPI,s.TIN,
			tt.ID as 'testID',
			case tt.Abbreviation
			when 'AST' then 
				case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '493') 
				when 'Y' then 'Y'
				else 'N'
				end
			when 'DIA' then 
				case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '250') 
				when 'Y' then 'Y'
				else 'N'
				end						
			else
				case (select TOP 1 'Y' from MainToDoHEDIS h where h.MVDID = mi.MVDId and h.TestLookupID = tt.ID) 
				when 'Y' then 'Y'
				else 'N'
				end 
			end as 'IsTestDue',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MVDID = mi.MVDId and h.TestLookupID = tt.ID) as 'TestStatusID'
		from MDUser u
			inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
			inner join MDGroup g on ag.MDGroupID = g.ID
			inner join Link_MDGroupNPI n on g.ID = n.MDGroupID
			inner join MainSpecialist s on n.NPI = s.NPI
			inner join mainpersonaldetails p on s.icenumber = p.icenumber	
			inner join Link_MVDID_CustID mi on p.icenumber = mi.mvdid
			inner join hpcustomer c on mi.cust_id = c.cust_id	
			cross join @tempTest tt
		where u.ID = @userID
			and s.RoleID = @PCPLookupId
			--and mi.Active = 1
			and s.RecordNumber in
			(
				select top 1 SS.recordNumber from MainSpecialist ss where ss.ICENUMBER = s.ICENUMBER and ss.RoleID = @PCPLookupId
				order by SS.ModifyDate desc
			)	
			and p.ICENUMBER not in (select i.ICENUMBER from MainInsurance i where i.ICENUMBER = p.ICENUMBER and i.TerminationDate is not null and i.TerminationDate < DATEADD(day,-2, @currentDate))

	
		--NEW Code -2-12-2015
			delete from MDUser_Member where DoctorUsername = @username

			insert into MDUser_Member (doctorID, DoctorUsername, hpName, custid, memberid, mvdid,
			MemberFirstName,MemberLastName,PCP_NPI,PCP_TIN,
			TestID,IsTestDue, TestStatusID)
			Select doctorID, DoctorUsername, hpName, custid, memberid, mvdid,
			MemberFirstName,MemberLastName,PCP_NPI,PCP_TIN,
			TestID,IsTestDue, TestStatusID from #MDUser_Member


      -- END New
	  	update @tempMDUser set IsProcessed = 1 where userID = @userID


	end
	
	delete from MDUser_Member
	where DoctorUsername not in
	(
		select username from @tempMDUser
	)
	


END




/*
before 4/22/2014

	declare @tempMDUser table (userID int, username varchar(50), IsProcessed bit default(0))
	
	declare @PCPLookupId int, @tempMvdid varchar(15), @username varchar(50), @currentDate datetime

	declare @userID int

	declare @W15ID int, @W34ID int, @AWCID int, @LSCID int, @CAPID int, @BCSID int, @CCSID int, @COLID int,
		@ADD_InitID int, @ADD_CMID int

	select @PCPLookupId = null,
		@currentDate = GETDATE()

	select @PCPLookupId = roleID  
	from LookupRoleID 
	where rolename = 'Primary Care Physician'
	
	select @W15ID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'W15'
	select @W34ID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'W34'
	select @AWCID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'AWC'
	select @LSCID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'LSC'
	select @CAPID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'CAP'
	select @BCSID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'BCS'
	select @CCSID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'CCS'
	select @COLID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'COL'
	select @ADD_InitID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'ADD_Init'
	select @ADD_CMID = ID from HEDIS_Results.dbo.LookupHedis where Abbreviation = 'ADD_CM'
	
	insert into @tempMDUser(userID, username)
	select ID,username
	from MDUser
	where Active = 1
	
	begin try
		delete from Sly_Logger
	end try
	begin catch
	
	end catch
		
	delete from MDUser_Member
	where DoctorUsername not in
	(
		select username from @tempMDUser
	)
	
	while exists (select top 1 * from @tempMDUser where IsProcessed = 0)
	begin
		select @userID = userID, @username = username from @tempMDUser where IsProcessed = 0

		delete from MDUser_Member where DoctorUsername = @username

		begin try
			insert into Sly_Logger(Message) values('Populate_MDUser_Member, processing: ' + @username)
		end try
		begin catch
		
		end catch
		
		-- NOTE: Asthma and Diabetes flags indicate patients with those diagnosis, they don't mean test is due
		insert into MDUser_Member (doctorID, DoctorUsername, hpName, custid, memberid, mvdid,
			MemberFirstName,MemberLastName,PCP_NPI,PCP_TIN,Asthma,Diabetes, W15,W15StatusID, W34, W34StatusID,AWC, AWCStatusID,
			LSC, LSCStatusID,CAP, CAPStatusID,BCS, BCSStatusID,CCS, CCSStatusID,COL, COLStatusID, 
			ADD_Init, ADD_InitStatusID, ADD_CM, ADD_CMStatusID)
		select  
			u.id, u.Username,c.name,mi.cust_id,mi.insMemberId,p.icenumber,
			isnull(p.firstname,''), isnull(p.lastname,''),s.NPI,s.TIN,
			case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '493') 
			when 'Y' then 'Y'
			else 'N'
			end as 'AST',
			case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '250') 
			when 'Y' then 'Y'
			else 'N'
			end as 'DIA',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W15ID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'W15',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W15ID) as 'W15StatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W34ID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'W34',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W34ID) as 'W34StatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @AWCID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'AWC',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @AWCID) as 'AWCStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @LSCID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'LSC',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @LSCID) as 'LSCStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @CAPID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'CAP',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @CAPID) as 'CAPStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @BCSID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'BCS',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @BCSID) as 'BCSStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @CCSID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'CCS',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @CCSID) as 'CCSStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @COLID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'COL',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @COLID) as 'COLStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @ADD_InitID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'COL',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @ADD_InitID) as 'ADD_InitStatusID',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @ADD_CMID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'COL',
			(select TOP 1 StatusID from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @ADD_CMID) as 'ADD_CMStatusID'												
		from MDUser u
			inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
			inner join MDGroup g on ag.MDGroupID = g.ID
			inner join Link_MDGroupNPI n on g.ID = n.MDGroupID
			inner join MainSpecialist s on n.NPI = s.NPI
			inner join mainpersonaldetails p on s.icenumber = p.icenumber	
			inner join Link_MVDID_CustID mi on p.icenumber = mi.mvdid
			inner join hpcustomer c on mi.cust_id = c.cust_id	
		where u.ID = @userID
			and s.RoleID = @PCPLookupId
			and mi.Active = 1
			and s.RecordNumber in
			(
				select top 1 SS.recordNumber from MainSpecialist ss where ss.ICENUMBER = s.ICENUMBER and ss.RoleID = @PCPLookupId
				order by SS.ModifyDate desc
			)	
			and p.ICENUMBER not in (select i.ICENUMBER from MainInsurance i where i.ICENUMBER = p.ICENUMBER and i.TerminationDate is not null and i.TerminationDate < @currentDate)

		update @tempMDUser set IsProcessed = 1 where userID = @userID
	end

*/