/****** Object:  Procedure [dbo].[Rpt_MemberHealthPlan]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberHealthPlan] 
	@IceNumber varchar(15)
As

	declare @disMgmtPrograms varchar(max),
		@NarcoticLockdown varchar(10),
		@InCaseManagement varchar(10),
		@ProvidesDMPrograms bit,
		@ProvidesNarcoticLockdown bit,
		@ProvidesInCaseManagement bit,
		@HealthPlanUserNote varchar(2000)

	set @disMgmtPrograms = ''

	select @ProvidesDMPrograms = ProvidesDMPrograms,
		@ProvidesNarcoticLockdown = ProvidesNarcoticLockdown,
		@ProvidesInCaseManagement = ProvidesInCaseManagement
	from dbo.Link_MVDID_CustID mi
		inner join hpCustomer c on mi.cust_id = c.cust_id
	where mvdid = @icenumber

	select @ProvidesDMPrograms = isnull(@ProvidesDMPrograms,0),
		@ProvidesNarcoticLockdown = isnull(@ProvidesNarcoticLockdown,0),
		@ProvidesInCaseManagement = isnull(@ProvidesInCaseManagement,0)	
	
	select @disMgmtPrograms = @disMgmtPrograms + h.Name + ', '
	from dbo.MainDiseaseManagement  m
		inner join dbo.HPDiseaseManagement h on m.DM_ID = h.DM_ID
	where icenumber = @icenumber

	if(len(isnull(@disMgmtPrograms,'')) > 0)
	begin	
		set @disMgmtPrograms = substring(@disMgmtPrograms,1, len(@disMgmtPrograms) -1)
	end
	else if(@ProvidesDMPrograms = 0)
	begin
		set @disMgmtPrograms = 'Unknown'
	end
	else
	begin
		set @disMgmtPrograms = 'None'
	end

	SELECT 
		@HealthPlanUserNote = HealthPlanUserNote,
		@inCaseManagement = ISNULL(CASE p.inCaseManagement
			when '1' then 'Yes'
			else 'No'
			END, ''),
		@NarcoticLockdown = ISNULL(CASE p.NarcoticLockdown
			when '1' then 'Yes'
			else 'No'
			END, '')
	FROM MainPersonalDetails p
		left join dbo.UserAdditionalInfo u on p.icenumber = u.mvdid
	WHERE p.icenumber = @IceNumber


	select @HealthPlanUserNote as HealthPlanUserNote,
		@disMgmtPrograms as DiseaseManagementPrograms,
		case @ProvidesInCaseManagement
			when 0 then 'Unknown'
			else @inCaseManagement
		end as InCaseManagement,
		case @ProvidesNarcoticLockdown
			when 0 then 'Unknown'
			else @NarcoticLockdown
		end as NarcoticLockdown