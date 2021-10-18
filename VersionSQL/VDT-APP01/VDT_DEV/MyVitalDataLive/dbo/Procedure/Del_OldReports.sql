/****** Object:  Procedure [dbo].[Del_OldReports]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/3/2010
-- Description:	Delete subscription reports older than X days
--	from users account
-- =============================================
create PROCEDURE [dbo].[Del_OldReports]
	@userid uniqueidentifier 
AS
BEGIN
	SET NOCOUNT ON;

	declare @dateRange int

	set @dateRange = 14		-- Keep the reports for 14 days

	declare @delReportID table(id int)

	insert into @delReportID(id)
	select id
	from SubscriptionReport s
		inner join Link_ReportUser r on s.id = r.reportID
	where r.userID = @userID
		and s.reportDate < DATEADD(dd,-@dateRange,getdate())

	-- Delete the link user-report
	delete from Link_ReportUser
	where userID = @userID
		and ReportID in
		(
			select id from @delReportID
		)

	-- Delete the main report if there is no other existing links
	delete from SubscriptionReport
	where ID not in
		(
			select s.id
			from SubscriptionReport s
				inner join Link_ReportUser r on s.id = r.reportID
		)
END