/****** Object:  Procedure [dbo].[Get_HPNoteAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 08/21/2013
-- Description:	Return the list of note alert for the specified
--		agent, created during the period specified
--  Note: The list also contains group alerts the agent belongs to
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPNoteAlerts]
	@UserID varchar(50),
	@DateRange int,
	@Customer varchar(50),	-- Used only for filtering the full list of alerts (when @UserID is not set)
	@IsCompleted bit,
	@AfterHoursFilter bit = null,
	@RecipientID varchar(50) = null,
	@CopcFacilityID varchar(50) = null,
	@CopcPCP_NPI varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

--select @UserID = '0', @DateRange = 50, @Customer = '1', @IsCompleted = 0, @CopcFacilityID = '0', @CopcPCP_NPI = '0'

	declare @pcpNPIs table(NPI varchar(50))
	declare @query varchar(2000), @VisitCountDateRange datetime, @AfterHoursStatusID int, @topValue int

	set @VisitCountDateRange = dateadd(mm,-6,getdate())
	
	select @AfterHoursStatusID = ID from LookupHPAlertStatus where Name like '%after hours%'

	if(@AfterHoursFilter is null)
	begin
		set @AfterHoursFilter = 0
	end

	if(ISNULL(@CopcPCP_NPI,'0') <> '0')
	begin
		insert into @pcpNPIs(NPI) values (@CopcPCP_NPI)
	end
	else
	begin
		insert into @pcpNPIs(NPI)
		select NPI
		from Link_CopcFacilityNPI
		where CopcFacilityID = 
			case ISNULL(@CopcFacilityID,'0')
			when '0' then CopcFacilityID
			else @CopcFacilityID
			end
	end
	
--select * from @pcpNPIs	
	
	if(@DateRange = 50 OR @DateRange = -50)
	begin
		set @topValue = 50
	end
	else
	begin
		set @topValue = 1000000
	end
	
	if exists (select top 1 * from @pcpNPIs)
	begin
		if(@userid <> '0')
		begin
			-- Add user filter
			SELECT	top(@topValue) h.ID, AgentID, AlertDate, Customer, 
					(case SourceName
					when 'HPAlertNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as Note, SourceName,
					(case SourceName
					when 'HPAlertNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as CreatedBy,
					StatusID, lh.Name as StatusName,
					h.DateCreated, lm.MVDId, isnull(lh.IsCompleted,0) as IsCompleted,
					dbo.GetFullName(dbo.HPNoteAlert_RowLock_Status(h.ID)) AS RowOwner, RecipientType, 
					dbo.GetFullName(ModifiedBy) AS ModifiedBy, 
					mpd.LastName + ', ' + mpd.FirstName AS MemberName, CONVERT(varchar,mpd.DOB,101) as MemberDOB,
					case triggerType
						when 'Individual' then 'Individual assignment' 
						when 'Rule' then 
							(select  Name from hpAlertRule where rule_id = triggerId)
						else ''
					end as TriggerName, h.HPMemberID,
					h.dateModified as DateModified,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and isnull(v.facilityname,'') = '' and v.visitdate > @VisitCountDateRange) as PhysicianVisitCount
			FROM	HPNoteAlert h INNER JOIN
					Link_MVDID_CustID lm ON h.HPMemberID = lm.InsMemberId INNER JOIN
					LookupHPAlertStatus lh ON h.StatusID = lh.ID LEFT JOIN
					MainPersonalDetails mpd ON lm.MVDId = mpd.ICENUMBER
			WHERE	lh.IsCompleted= convert(varchar(5),@IsCompleted)
				 AND (convert(varchar(40),AgentID) = @UserID 
					OR
					(
						RecipientType = 'Group'
						AND convert(varchar(40),AgentID) IN 
						(
							SELECT convert(varchar(40),group_ID) 
							FROM dbo.Link_HPAlertGroupAgent 
							WHERE Agent_ID = @UserID
						) 
					) )
				AND (ISNULL(@recipientID,'0') = 0 OR AgentID = @RecipientID )
				AND alertDate >
					case  
						when @dateRange <= 0 then convert(datetime,'1/1/1980') -- get all, don't filter alerts by date
						else DATEADD(DD, -@DateRange , GETUTCDATE())
					end
				AND StatusID = 
					(
						case @AfterHoursFilter
							when 1 then @AfterHoursStatusID
							else StatusID
						end
					)
				AND mpd.ICENUMBER IN
				(
					select s.ICENUMBER from MainSpecialist s
					where NPI in
						(
							select pn.NPI from @pcpNPIs pn
						)
						and RoleID = 1
				)
				and h.ID in(select top 1 hh.id from hpNoteAlert hh where hh.mvdid = h.mvdid order by alertDate desc)							
			order by case when @DateRange >= 0 then h.AlertDate end desc
					,case @DateRange when -50 then AlertDate end										
		end
		else
		begin		

			-- Add customer filter
			SELECT	top(@topValue) h.ID, AgentID, AlertDate, Customer, 
					(case SourceName
					when 'HPAlertNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as Note, SourceName,
					(case SourceName
					when 'HPAlertNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as CreatedBy,
					StatusID, lh.Name as StatusName,
					h.DateCreated, lm.MVDId, isnull(lh.IsCompleted,0) as IsCompleted,
					dbo.GetFullName(dbo.HPNoteAlert_RowLock_Status(h.ID)) AS RowOwner, RecipientType, 
					dbo.GetFullName(ModifiedBy) AS ModifiedBy, 
					mpd.LastName + ', ' + mpd.FirstName AS MemberName, CONVERT(varchar,mpd.DOB,101) as MemberDOB,
					case triggerType
						when 'Individual' then 'Individual assignment' 
						when 'Rule' then 
							(select  Name from hpAlertRule where rule_id = triggerId)
						else ''
					end as TriggerName,h.HPMemberID,
					h.dateModified as DateModified,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and isnull(v.facilityname,'') = '' and v.visitdate > @VisitCountDateRange) as PhysicianVisitCount
			FROM	HPNoteAlert h INNER JOIN
					Link_MVDID_CustID lm ON h.HPMemberID = lm.InsMemberId INNER JOIN
					LookupHPAlertStatus lh ON h.StatusID = lh.ID LEFT JOIN
					MainPersonalDetails mpd ON lm.MVDId = mpd.ICENUMBER
			WHERE	lh.IsCompleted= convert(varchar(5),@IsCompleted) 
				AND h.recipientCustID = @customer
				AND (ISNULL(@recipientID,'0') = 0 OR AgentID = @RecipientID )
				AND alertDate >
					case  
						when @dateRange <= 0 then convert(datetime,'1/1/1980') -- get all, don't filter alerts by date
						else DATEADD(DD, -@DateRange , GETUTCDATE())
					end
				AND StatusID = 
					(
						case @AfterHoursFilter
							when 1 then @AfterHoursStatusID
							else StatusID
						end
					)
				AND mpd.ICENUMBER IN
				(
					select s.ICENUMBER from MainSpecialist s
					where NPI in
					(
						select pn.NPI from @pcpNPIs pn
					)
						and RoleID = 1
				)	
				and h.ID in(select top 1 hh.id from hpNoteAlert hh where hh.mvdid = h.mvdid order by alertDate desc)			
			order by case when @DateRange >= 0 then AlertDate end desc
					,case @DateRange when -50 then AlertDate end													
		end
	end
	else
	begin
		if(@userid <> '0')
		begin
			-- Add user filter
			SELECT	top(@topValue) h.ID, AgentID, AlertDate, Customer, 
					(case SourceName
					when 'HPAlertNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as Note, SourceName,
					(case SourceName
					when 'HPAlertNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as CreatedBy,
					StatusID, lh.Name as StatusName,
					h.DateCreated, lm.MVDId, isnull(lh.IsCompleted,0) as IsCompleted,
					dbo.GetFullName(dbo.HPNoteAlert_RowLock_Status(h.ID)) AS RowOwner, RecipientType, 
					dbo.GetFullName(ModifiedBy) AS ModifiedBy, 
					mpd.LastName + ', ' + mpd.FirstName AS MemberName, CONVERT(varchar,mpd.DOB,101) as MemberDOB,
					case triggerType
						when 'Individual' then 'Individual assignment' 
						when 'Rule' then 
							(select  Name from hpAlertRule where rule_id = triggerId)
						else ''
					end as TriggerName, h.HPMemberID,
					h.dateModified as DateModified,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and isnull(v.facilityname,'') = '' and v.visitdate > @VisitCountDateRange) as PhysicianVisitCount
			FROM	HPNoteAlert h INNER JOIN
					Link_MVDID_CustID lm ON h.HPMemberID = lm.InsMemberId INNER JOIN
					LookupHPAlertStatus lh ON h.StatusID = lh.ID LEFT JOIN
					MainPersonalDetails mpd ON lm.MVDId = mpd.ICENUMBER
			WHERE	lh.IsCompleted= convert(varchar(5),@IsCompleted)
				 AND (convert(varchar(40),AgentID) = @UserID 
					OR
					(
						RecipientType = 'Group'
						AND convert(varchar(40),AgentID) IN 
						(
							SELECT convert(varchar(40),group_ID) 
							FROM dbo.Link_HPAlertGroupAgent 
							WHERE Agent_ID = @UserID
						) 
					) )
				AND (ISNULL(@recipientID,'0') = 0 OR AgentID = @RecipientID )
				AND alertDate >
					case  
						when @dateRange <= 0 then convert(datetime,'1/1/1980') -- get all, don't filter alerts by date
						else DATEADD(DD, -@DateRange , GETUTCDATE())
					end
				AND StatusID = 
					(
						case @AfterHoursFilter
							when 1 then @AfterHoursStatusID
							else StatusID
						end
					)
				and h.ID in(select top 1 hh.id from hpNoteAlert hh where hh.mvdid = h.mvdid order by alertDate desc)								
			order by case when @DateRange >= 0 then h.AlertDate end desc
					,case @DateRange when -50 then AlertDate end										
		end
		else
		begin
			-- Add customer filter
			SELECT	top(@topValue) h.ID, AgentID, AlertDate, Customer, 
					(case SourceName
					when 'HPAlertNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 Note from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as Note, SourceName,
					(case SourceName
					when 'HPAlertNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpAlertNoteMD' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)
					when 'hpMemberNote' then (select top 1 ModifiedBy from HPAlertNote n where n.ID = h.SourceRecordID)					
					end) as CreatedBy,
					StatusID, lh.Name as StatusName,
					h.DateCreated, lm.MVDId, isnull(lh.IsCompleted,0) as IsCompleted,
					dbo.GetFullName(dbo.HPNoteAlert_RowLock_Status(h.ID)) AS RowOwner, RecipientType, 
					dbo.GetFullName(ModifiedBy) AS ModifiedBy, 
					mpd.LastName + ', ' + mpd.FirstName AS MemberName, CONVERT(varchar,mpd.DOB,101) as MemberDOB,
					case triggerType
						when 'Individual' then 'Individual assignment' 
						when 'Rule' then 
							(select  Name from hpAlertRule where rule_id = triggerId)
						else ''
					end as TriggerName,h.HPMemberID,
					h.dateModified as DateModified,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount,
					(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and isnull(v.facilityname,'') = '' and v.visitdate > @VisitCountDateRange) as PhysicianVisitCount
			FROM	HPNoteAlert h INNER JOIN
					Link_MVDID_CustID lm ON h.HPMemberID = lm.InsMemberId INNER JOIN
					LookupHPAlertStatus lh ON h.StatusID = lh.ID LEFT JOIN
					MainPersonalDetails mpd ON lm.MVDId = mpd.ICENUMBER
			WHERE	lh.IsCompleted= convert(varchar(5),@IsCompleted) 
				AND h.recipientCustID = @customer
				AND (ISNULL(@recipientID,'0') = 0 OR AgentID = @RecipientID )
				AND alertDate >
					case  
						when @dateRange <= 0 then convert(datetime,'1/1/1980') -- get all, don't filter alerts by date
						else DATEADD(DD, -@DateRange , GETUTCDATE())
					end
				AND StatusID = 
					(
						case @AfterHoursFilter
							when 1 then @AfterHoursStatusID
							else StatusID
						end
					)
				and h.ID in(select top 1 hh.id from hpNoteAlert hh where hh.mvdid = h.mvdid order by alertDate desc)										
			order by case when @DateRange >= 0 then h.AlertDate end desc
					,case @DateRange when -50 then AlertDate end										
		end	
	end
END