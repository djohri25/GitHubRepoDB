/****** Object:  Procedure [dbo].[Get_COPCAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 2/20/2013
-- Description:	Retrieves the list of COPC alerts from HP members with PCP NPIs associated with 
--		the current facility and created N-days in the past
-- =============================================
CREATE PROCEDURE [dbo].[Get_COPCAlerts]
	@Username varchar(50),
	@FacilityID varchar(50),
	@DateRange int
AS
BEGIN
	SET NOCOUNT ON;

--select @Username = 'wr_copc', @FacilityID = 1, @DateRange = 360

	declare @temp table(data varchar(50))
	declare @query varchar(2000), @VisitCountDateRange datetime, @topValue int, @userID varchar(50), @sql varchar(1000)

	set @VisitCountDateRange = dateadd(mm,-6,getdate())	

	if(@DateRange = 50 OR @DateRange = -50)
	begin
		set @topValue = @DateRange
	end
	else
	begin
		set @topValue = 1000000
	end
	
	select @sql = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users where UserName = ''' + @Username + ''''
	
	insert into @temp(data)
	exec(@sql)
	
	select top 1 @userID = data from @temp			
						
	SELECT top(@topValue) h.ID, AgentID, AlertDate, Facility, Customer, 
			h.DateCreated, lm.MVDId, RecipientType, 
			dbo.GetFullName(ModifiedBy) AS ModifiedBy, 
			mpd.LastName + ', ' + mpd.FirstName AS MemberName,
			h.ChiefComplaint, h.EMSNote,
			case triggerType
				when 'Individual' then 'Individual assignment' 
				when 'Rule' then 
					(select  Name from hpAlertRule where rule_id = triggerId)
				else ''
			end as TriggerName,h.memberID,
			h.dateModified as DateModified,
			h.DischargeDisposition,
			(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount														
	FROM	HPAlert h INNER JOIN
			Link_MVDID_CustID lm ON h.MemberID = lm.InsMemberId INNER JOIN
			MainPersonalDetails mpd ON lm.MVDId = mpd.ICENUMBER INNER JOIN
			MainSpecialist s ON lm.MVDId = s.ICENUMBER
	WHERE	alertDate >
			case @dateRange 
				when 0 then convert(datetime,'1/1/1980') -- get all, don't filter alerts by date
				else DATEADD(DD, -@DateRange , GETUTCDATE())
			end
		AND s.RoleID = 1
		and s.NPI is not null
		and s.NPI in
		(
			select c.NPI from Link_CopcFacilityNPI c
			where c.CopcFacilityID = @FacilityID
		)
		AND (convert(varchar(40),AgentID) = @UserID 
				OR
				(
					RecipientType = 'Group'
					AND convert(varchar(40),AgentID) IN 
					(
						SELECT convert(varchar(40),group_ID) 
						FROM dbo.Link_HPAlertGroupAgent 
						WHERE Agent_ID = @userID
					) 
				) 
		)						
	order by case @DateRange when 50 then h.AlertDate end desc
			,case @DateRange when -50 then AlertDate end																			
END