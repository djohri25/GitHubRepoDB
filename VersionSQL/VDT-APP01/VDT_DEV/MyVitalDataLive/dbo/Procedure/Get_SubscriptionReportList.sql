/****** Object:  Procedure [dbo].[Get_SubscriptionReportList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/21/2010
-- Description:	Returns the list of reports generated
--	as a result of subscription
-- =============================================
CREATE PROCEDURE [dbo].[Get_SubscriptionReportList]
	@User varchar(50),
	@Type varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @query varchar(1000), @userid varchar(50)
	declare @temp table(data varchar(50))

	-- Get userId
	set @query = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @User + ''''

	insert into @temp(data)
		exec (@query)

	select @userId = data from @temp
	delete from @temp

	EXEC Del_OldReports @userID = @userid

	select s.ID,lo.reportName as ReportName, ReportDate, Viewed 
	from dbo.SubscriptionReport s
		inner join link_reportUser ru	on ru.reportID = s.ID
		inner join LookupCS_Report lo on lo.reportpath like ('%/' + s.name)
	where ru.userid = @userID
		and type = @type
	order by reportDate desc
	

END