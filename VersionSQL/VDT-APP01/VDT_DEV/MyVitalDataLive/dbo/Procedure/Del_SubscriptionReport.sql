/****** Object:  Procedure [dbo].[Del_SubscriptionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/22/2010
-- Description:	Deletes the report created as a result 
--	of user subscription
-- =============================================
CREATE PROCEDURE [dbo].[Del_SubscriptionReport]
	@User varchar(50),
	@ReportID int
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

	delete from link_reportUser
	where userid = @userid and reportid = @reportid

	-- Delete the main report record if it's not associated with any other user
	if not exists(select reportid from dbo.Link_ReportUser where reportID = @reportID)
	begin
		delete from SubscriptionReport where id = @reportID
	end

END