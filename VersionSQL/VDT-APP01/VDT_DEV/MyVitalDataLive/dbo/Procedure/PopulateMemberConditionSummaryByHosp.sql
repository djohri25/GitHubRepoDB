/****** Object:  Procedure [dbo].[PopulateMemberConditionSummaryByHosp]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/3/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PopulateMemberConditionSummaryByHosp]
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
		@LastContactBy varchar(100),
		@LastContactByName varchar(100), 
		@tempHospID int,
		@tempHospName varchar(50),
		@tempHospNPI varchar(50)

	declare @temp table(
		InsMemberID varchar(50),
		HospitalID int,
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
		LastContactBy varchar(100),
		LastContactByName varchar(100),
		isProcessed bit default(0)
	)

	select @dateLimit = DATEADD(MM,-6,GETDATE())

--select * from MainEMSHospital

--select * from dbo.MainEMSHospital

	declare @tempHosp table (hospID int, hospName varchar(50), npi varchar(50), isProcessed bit default(0))
	
	declare @tempMembers table (mvdid varchar(50), lastContactDate datetime, lastContactBy varchar(100), lastContactByName varchar(100))
		
	insert into @tempHosp(hospID,hospName,npi)
	select ID,Name,NPI
	from MainEMSHospital
	where State = 'TX'

	insert into @tempMembers(mvdid, lastContactDate, lastContactBy, lastContactByName)
	select distinct mvdid, lastContactDate, lastContactBy, lastContactByName
	from MemberDiagnosisSummaryByHosp

	while exists(select hospid from @tempHosp where isProcessed = 0)
	begin
		select top 1 @tempHospID = hospID,
			@tempHospName = hospName,
			@tempHospNPI = npi
		from @tempHosp
		where isProcessed = 0
				
		insert @temp (InsMemberID,CustID,hospitalID,MVDID,FirstName,LastName,LastContactDate,LastContactBy,LastContactByName)
		select li.InsMemberId,li.Cust_ID,@tempHospID,li.MVDId,p.FirstName,p.LastName,m.LastContactDate,m.lastContactBy,m.lastContactByName 
		from MainPersonalDetails p
			inner join MainInsurance i on p.ICENUMBER = i.ICENUMBER
			inner join Link_MemberId_MVD_Ins li on p.ICENUMBER = li.MVDId
			left join @tempMembers m on p.icenumber = m.mvdid
		where p.ICENUMBER in
			(
				select ICENUMBER from MainCondition where Code in
				(
					select code from dbo.Link_ConditionLookupCode
				)
			)
			and p.ICENUMBER in
			(
				select e.ICENUMBER from EDVisitHistory e
				where e.FacilityNPI = @tempHospNPI
			)
			AND IsPrimary = 1
			AND (i.TerminationDate is null OR i.TerminationDate > DATEADD(MM,-2,getdate()))	

		update @tempHosp set isProcessed = 1 where hospID = @tempHospID
	end
	
	delete from MemberDiagnosisSummaryByHosp
	
	while exists (select mvdid from @temp where isProcessed = 0)
	begin
		select @mvdid = mvdid,
			@InsMemberID = InsMemberID,
			@CustID = custid,
			@FirstName = firstName,
			@LastName = lastName,
			@LastContactDate = LastContactDate,
			@LastContactBy = LastContactBy,
			@LastContactByName = LastContactByName,
			@tempHospID = HospitalID
		from @temp 
		where isProcessed = 0

		select @PhysVisitCount = 0,
			@PCPVisitCount = 0,
			@ERVisitCount = 0,
			@PhysVisitCountSinceContact = 0,
			@PCPVisitCountSinceContact = 0,
			@ERVisitCountSinceContact = 0

		if exists(select mvdid from MemberDiagnosisSummaryByHosp where MVDID = @mvdid )
		begin
	
			insert MemberDiagnosisSummaryByHosp(
				InsMemberID,CustID,HospitalID,MVDID,FirstName,LastName,PhysVisitCount,PCPVisitCount,ERVisitCount,
				PhysVisitCountSinceContact,PCPVisitCountSinceContact,ERVisitCountSinceContact,
				LastContactDate, LastContactBy, LastContactByName)
			select top 1
				InsMemberID,CustID, @tempHospID,MVDID,FirstName,LastName,
				PhysVisitCount,PCPVisitCount,ERVisitCount,
				PhysVisitCountSinceContact,PCPVisitCountSinceContact,ERVisitCountSinceContact,
				LastContactDate, LastContactBy, LastContactByName
			from MemberDiagnosisSummaryByHosp 
			where MVDID = @mvdid
		end
		else
		begin
			select @ERVisitCount = COUNT(ID)
			from EDVisitHistory
			where ICENUMBER = @mvdid
				and VisitType = 'ER'
				and VisitDate > @dateLimit

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
			
			insert MemberDiagnosisSummaryByHosp(
				InsMemberID,CustID,HospitalID,MVDID,FirstName,LastName,PhysVisitCount,PCPVisitCount,ERVisitCount,
				PhysVisitCountSinceContact,PCPVisitCountSinceContact,ERVisitCountSinceContact,
				LastContactDate, LastContactBy,LastContactByName)
			values(
				@InsMemberID,@CustID,@tempHospID,@mvdid,@FirstName,@LastName,@PhysVisitCount,@PCPVisitCount,@ERVisitCount,
				@PhysVisitCountSinceContact,@PCPVisitCountSinceContact,@ERVisitCountSinceContact,
				@LastContactDate, @LastContactBy, @LastContactByName)					
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
		where MVDID = @mvdid and HospitalID = @tempHospID
	end


	--select * from MemberDiagnosisSummary

	delete from MemberDiagnosisSummaryByHosp
	where MVDID not in
	(
		select MVDID from @temp
	)

	--select * from @temp	


	--select * from MemberDiagnosisSummary

END