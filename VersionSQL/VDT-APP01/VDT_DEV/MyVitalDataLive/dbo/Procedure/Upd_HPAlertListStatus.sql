/****** Object:  Procedure [dbo].[Upd_HPAlertListStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/9/2011
-- Description:	As of 3/9/2011, set status of the alerts in the list to "Outreach not attempted"
-- =============================================
create PROCEDURE [dbo].[Upd_HPAlertListStatus]
	@SelectedItemList varchar(max),
	@Username nvarchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	declare @OutreachStatusID int
	declare @temp table (data varchar(50))
	
	insert into @temp (data)
	select DATA from dbo.Split(@SelectedItemList,',')
	
	select @OutreachStatusID = ID
	from LookupHPAlertStatus 
	where Name = 'Outreach not attempted'
	
	if(ISNULL(@OutreachStatusID,'') <> '')
	begin
		update HPAlert
		set StatusID = @OutreachStatusID,
			ModifiedBy = @Username, DateModified = GETUTCDATE()
		where ID in
		(
			select data from @temp
		)
	end
END