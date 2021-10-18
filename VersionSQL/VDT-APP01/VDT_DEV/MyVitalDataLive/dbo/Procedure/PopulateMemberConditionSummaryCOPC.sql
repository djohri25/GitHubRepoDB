/****** Object:  Procedure [dbo].[PopulateMemberConditionSummaryCOPC]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/4/2012
-- Description:	<Description,,>
-- Modified Date:	Modified By:	Description:
-- 02/09/2017		Marc De Luca	Added an intermediary temp table for performance purposes
-- =============================================
CREATE PROCEDURE [dbo].[PopulateMemberConditionSummaryCOPC]
AS
BEGIN
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
		@LastERVisit datetime,
		@W15LookupID int
		
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
	
	select @dateLimit = DATEADD(MM,-6,GETDATE())

	select @W15LookupID = ID from dbo.LookupHedis where Abbreviation = 'W15'

	IF (OBJECT_ID('tempdb..#T') IS NOT NULL) DROP TABLE #T
	SELECT li.InsMemberId,li.Cust_ID,li.MVDId,p.FirstName,p.LastName,m.LastContactDate, p.ICENUMBER
	INTO #T
	FROM dbo.MainPersonalDetails p
	JOIN dbo.Link_MemberId_MVD_Ins li ON p.ICENUMBER = li.MVDId
	LEFT JOIN dbo.MemberDiagnosisSummaryCOPC m ON p.icenumber = m.mvdid
	WHERE IsPrimary = 1
	AND li.Active = 1
	AND p.ICENUMBER IN
	(
		SELECT s.icenumber FROM MainSpecialist s 
		where s.RoleID = 1 
		and s.NPI IN (SELECT a.npi FROM dbo.COPC_NPI a WHERE a.cust_id = li.Cust_ID)
	)

	INSERT @temp (InsMemberID,CustID,MVDID,FirstName,LastName,LastContactDate)
	SELECT InsMemberId,Cust_ID,MVDId,FirstName,LastName,LastContactDate
	FROM #T T
	WHERE 
	( 
		(ICENUMBER IN (SELECT ICENUMBER FROM dbo.MainCondition WHERE CodeFirst3 = '493'))
		OR (InsMemberId IN (SELECT memberid FROM dbo.Final_HEDIS_Member WHERE TestID = 1))
	)

--select * from @temp

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
			AND FacilityNPI in (select NPI from MainSpecialist where ICENUMBER = @mvdid and RoleID = 1)

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

		if exists(select mvdid from MemberDiagnosisSummaryCOPC where MVDID = @mvdid)
		begin
			update MemberDiagnosisSummaryCOPC 
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
			insert MemberDiagnosisSummaryCOPC(
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


	--select * from MemberDiagnosisSummaryCOPC

	delete from MemberDiagnosisSummaryCOPC
	where MVDID not in
	(
		select MVDID from @temp
	)

		
END