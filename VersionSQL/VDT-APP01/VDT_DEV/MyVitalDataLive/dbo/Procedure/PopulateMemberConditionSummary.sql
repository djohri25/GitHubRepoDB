/****** Object:  Procedure [dbo].[PopulateMemberConditionSummary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/3/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PopulateMemberConditionSummary]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @mvdid varchar(50),
		@dateLimit datetime,
		@InsMemberID varchar(50),
		@CustID int,
		@FirstName varchar(50),
		@LastName varchar(50),
		@PhysVisitCount int,
		@PCPVisitCount int,
		@ERVisitCount int,
		@PhysVisitCountSinceContact int,
		@PCPVisitCountSinceContact int,
		@ERVisitCountSinceContact int,
		@LastContactDate datetime,
		@LastERVisit datetime
		
	declare @temp table(
		InsMemberID varchar(50),
		CustID int,
		MVDID varchar(50),
		FirstName varchar(50),
		LastName varchar(50),
		PhysVisitCount int,
		PCPVisitCount int,		-- visits within last 6 months
		ERVisitCount int,		-- visits within last 6 months
		PhysVisitCountSinceContact int,
		PCPVisitCountSinceContact int,
		ERVisitCountSinceContact int,
		LastContactDate datetime,
		LastERVisit datetime,
		isProcessed bit default(0)
	)

	--CREATE INDEX IDX_temp_mvdid ON @temp(MVDID)
	
	select @dateLimit = DATEADD(MM,-6,GETDATE())

	insert @temp (InsMemberID,CustID,MVDID,FirstName,LastName,LastContactDate)
	select li.InsMemberId,li.Cust_ID,li.MVDId,p.FirstName,p.LastName,m.LastContactDate 
	from MainPersonalDetails p
		--inner join MainInsurance i on p.ICENUMBER = i.ICENUMBER
		inner join Link_MemberId_MVD_Ins li on p.ICENUMBER = li.MVDId
		left join dbo.MemberDiagnosisSummary m on p.icenumber = m.mvdid
	where p.ICENUMBER in
		(
			select ICENUMBER from MainCondition where Code in
			(
				select code from dbo.Link_ConditionLookupCode
			)
		)
		AND IsPrimary = 1
		--AND (i.TerminationDate is null OR i.TerminationDate > DATEADD(MM,-2,getdate()))	
		and li.Active = 1
		and p.ICENUMBER in
		(
			select s.icenumber from MainSpecialist s where s.RoleID = 1 and s.NPI in
			(
				select a.npi from AsthmaReport_NPI a
			)
		)

	while exists (select mvdid from @temp where isProcessed = 0)
	begin
		select top 1 @mvdid = mvdid,
			@InsMemberID = InsMemberID,
			@CustID = custid,
			@FirstName = firstName,
			@LastName = lastName,
			@LastContactDate = LastContactDate
		from @temp 
		where isProcessed = 0

		select @PhysVisitCount = 0,
			@PCPVisitCount = 0,
			@ERVisitCount = 0,
			@PhysVisitCountSinceContact = 0,
			@PCPVisitCountSinceContact = 0,
			@ERVisitCountSinceContact = 0,
			@LastERVisit = null
		
		select @ERVisitCount = COUNT(ID)
		from EDVisitHistory
		where ICENUMBER = @mvdid
			and VisitType = 'ER'
			and VisitDate > @dateLimit

		if(@ERVisitCount > 0)
		begin
			select top 1 @LastERVisit = VisitDate
			from EDVisitHistory
			where ICENUMBER = @mvdid
				and VisitType = 'ER'
				and VisitDate > @dateLimit
			order by VisitDate desc				
		end

		select @PhysVisitCount = COUNT(ID)
		from EDVisitHistory
		where ICENUMBER = @mvdid
			and VisitType = 'PHYSICIAN'
			and VisitDate > @dateLimit

		select @PCPVisitCount = COUNT(ID)
		from EDVisitHistory
		where ICENUMBER = @mvdid
			and VisitDate > @dateLimit
			AND FacilityNPI in
			(
				select NPI from MainSpecialist where ICENUMBER = @mvdid and RoleID = 1
			)

		if(@LastContactDate is not null)
		begin
			select @ERVisitCountSinceContact = COUNT(ID)
			from EDVisitHistory
			where ICENUMBER = @mvdid
				and VisitType = 'ER'
				and VisitDate > @LastContactDate

			select @PhysVisitCountSinceContact = COUNT(ID)
			from EDVisitHistory
			where ICENUMBER = @mvdid
				and VisitType = 'PHYSICIAN'
				and VisitDate > @LastContactDate

			select @PCPVisitCountSinceContact = COUNT(ID)
			from EDVisitHistory
			where ICENUMBER = @mvdid
				and VisitDate > @LastContactDate
				AND FacilityNPI in
				(
					select NPI from MainSpecialist where ICENUMBER = @mvdid and RoleID = 1
				)	
				
		end

		if exists(select mvdid from MemberDiagnosisSummary where MVDID = @mvdid)
		begin
			update MemberDiagnosisSummary 
			set 			
				PhysVisitCount = @PhysVisitCount,
				PCPVisitCount = @PCPVisitCount,
				ERVisitCount = @ERVisitCount,
				PhysVisitCountSinceContact = @PhysVisitCountSinceContact,
				PCPVisitCountSinceContact = @PCPVisitCountSinceContact,
				ERVisitCountSinceContact = @ERVisitCountSinceContact,
				LastERVisit = @LastERVisit
			where MVDID = @mvdid
		end		
		else
		begin
			insert MemberDiagnosisSummary(
				InsMemberID,CustID,MVDID,FirstName,LastName,PhysVisitCount,PCPVisitCount,ERVisitCount,LastERVisit)
			values(
				@InsMemberID,@CustID,@mvdid,@FirstName,@LastName,@PhysVisitCount,@PCPVisitCount,@ERVisitCount,@LastERVisit)
		end	

		
		update @temp 
		set isProcessed = 1
			--, 
			--ERVisitCount = @ERVisitCount,
			--PhysVisitCount = @PhysVisitCount,
			--PCPVisitCount = @PCPVisitCount,
			--PhysVisitCountSinceContact = @PhysVisitCountSinceContact,
			--PCPVisitCountSinceContact = @PCPVisitCountSinceContact,
			--ERVisitCountSinceContact = @ERVisitCountSinceContact
		where MVDID = @mvdid
	end


	--select * from MemberDiagnosisSummary

	delete from MemberDiagnosisSummary
	where MVDID not in
	(
		select MVDID from @temp
	)

	-- LINK MEMBER TO PCP
	delete from Link_Member_PCP

	insert into dbo.Link_Member_PCP(mvdid, pcp_npi)
	select m.MVDID,s.NPI 
	from MemberDiagnosisSummary m
		inner join MainSpecialist s on m.MVDID = s.ICENUMBER
	where  RoleID=1 and NPI is not null

	-- LINK MEMBER TO CONDITION

	delete from dbo.Link_Member_LookupCondition

	declare @tempCondition table(condLookupID int)
	declare @tempCondID int
	
	insert into @tempCondition
	select ID from LookupMemberConditionSummary
	
	while exists (select top 1 condLookupID from @tempCondition)
	begin
		select top 1 @tempCondID = condLookupID from @tempCondition
		
		insert into dbo.Link_Member_LookupCondition(mvdid,LookupConditionID)
		select distinct icenumber, @tempCondID
		from MainCondition c
			inner join MemberDiagnosisSummary s on c.ICENUMBER = s.MVDID
			inner join 	Link_ConditionLookupCode li on c.Code = li.Code	
			
		delete from @tempCondition where condLookupID = @tempCondID
	end
END