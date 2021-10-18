/****** Object:  Procedure [dbo].[Get_ConditionsMemberCount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_ConditionsMemberCount]
	@SelectedCodes varchar(max),
	@ActiveFilter varchar(50),
	@SelectedHealthPlan varchar(100),		-- ID
	@SelectedHospital varchar(100)			-- ID
AS
BEGIN
	SET NOCOUNT ON;

--select @SelectedCodes = '4019',
--	@ActiveFilter = 'INACTIVE',
--	@SelectedHealthPlan = '4',		-- ID
--	@SelectedHospital = '25'

--declare @SelectedCodes varchar(max)
--
--set @SelectedCodes = '007|001|001.1'
	declare @tempSelected table (data varchar(50))
	declare @tempResultMembers table (mvdid varchar(20))
	declare @tempVisitedMembers table(mvdid varchar(20))

	declare @curDate datetime,
		@selectedParentHPID int,
		@facilityNPI varchar(20),
		@totalActiveMembers int,
		@totalVisitedHospital int
	
	select @curDate = getdate()

	select @SelectedCodes = replace(@SelectedCodes,'.','')

	select @selectedParentHPID = dbo.Get_HPParentCustomerID(@SelectedHealthPlan)

	insert into @tempSelected (data)
	select data from dbo.Split(@SelectedCodes,'|')

	insert into @tempResultMembers (mvdid)
	select distinct icenumber 
	from maincondition
	where code is not null AND code in (select data from @tempSelected)


	if(@ActiveFilter = 'ACTIVE')
	begin
		delete from @tempResultMembers where mvdid in
			(
				select icenumber from maininsurance where terminationdate is not null AND terminationDate < @curDate
			)
	end
	else if(@ActiveFilter = 'INACTIVE')
	begin
		delete from @tempResultMembers where mvdid in
			(select icenumber from maininsurance where terminationdate is null OR terminationDate >= @curDate)
	end

	select @totalActiveMembers = count(distinct i.icenumber) 
	from  Link_MVDID_CustID l 
		inner join maininsurance i on l.mvdid = i.icenumber
	where cust_id = @selectedParentHPID 
		AND (i.terminationdate is null or i.terminationdate > @curDate)


	if( @SelectedHospital <> '' AND @SelectedHospital <> '0')
	begin
		select @facilityNPI = NPI from mainEMSHospital where ID = @SelectedHospital

		insert into @tempVisitedMembers(mvdid)
		select distinct icenumber 
		from edvisithistory h
			inner join Link_MVDID_CustID li on h.icenumber = li.mvdid
		where facilityNPI = @facilityNPI and cust_id = @selectedParentHPID

		select @totalVisitedHospital = count(mvdid)
		from @tempVisitedMembers

		select @totalActiveMembers as 'totalActive', 
			convert(varchar(10),count(t.mvdid)) as 'totalMemberCond',
			@totalVisitedHospital as 'totalVisitedHospital'
		from @tempResultMembers t			
			inner join @tempVisitedMembers tv on t.mvdid = tv.mvdid		
	end
	else
	begin
		-- Filter Health Plan users
		select @totalActiveMembers as 'totalActive', 
			convert(varchar(10),count(t.mvdid)) as 'totalMemberCond',
			'' as 'totalVisitedHospital'
		from @tempResultMembers t
			inner join Link_MVDID_CustID li on t.mvdid = li.mvdid
		where cust_id = @selectedParentHPID
	end

END