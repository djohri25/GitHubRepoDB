/****** Object:  Procedure [dbo].[Get_SubscriptionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/22/2010
-- Description:	Returns content of the report generated
--	as a result of subscription
-- =============================================
CREATE PROCEDURE [dbo].[Get_SubscriptionReport]	
	@ReportID int, 
	@User varchar(50),
	@Content varbinary(max) output 	
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

	select @content = Content
	from dbo.SubscriptionReport s
		inner join link_reportUser ru on ru.reportID = s.ID
	where s.id = @ReportID
		and  ru.userid = @userId

	update link_reportUser set viewed = 1
	where reportid = @ReportID
		and userid = @userId
END