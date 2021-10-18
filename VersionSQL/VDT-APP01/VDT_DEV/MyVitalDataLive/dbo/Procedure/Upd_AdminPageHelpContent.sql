/****** Object:  Procedure [dbo].[Upd_AdminPageHelpContent]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/15/2009
-- Description:	Updates page content if specified page and mode exists or
--		creates new record based on provided data
-- =============================================
CREATE PROCEDURE [dbo].[Upd_AdminPageHelpContent]
	@PageName varchar(50),
	@PageMode varchar(50),
	@Text varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	-- If page mode not set assume 'MAIN'
--	if(len(isnull(@PageMode,'')) = 0)
--	begin
--		set @PageMode = 'MAIN'
--	end

	-- Check if record exists
	if exists (select pagename from WebPageAdminContent where pageName = @PageName and pageMode = @PageMode)
	begin
		update WebPageAdminContent set text = @Text, ModifyDate = getutcdate() 
		where pageName = @PageName and pageMode = @PageMode
	end
	else
	begin
		insert into WebPageAdminContent (pageName,pageMode,Text,ModifyDate)
		values(@PageName,@PageMode,@Text,getutcdate())
	end
END