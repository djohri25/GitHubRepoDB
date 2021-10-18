/****** Object:  Procedure [dbo].[Get_AdminPageHelpContent]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/29/2008
-- Description:	 Returns the content of the help section
--		for the specified page and page mode
-- Possible values for @PageMode:
--	- MAIN
--  - ADD
--	- EDIT
-- =============================================
create Procedure [dbo].[Get_AdminPageHelpContent] 
	@PageName varchar(50),
	@PageMode varchar(50)
As

SET NOCOUNT ON

select text from WebPageAdminContent where PageName = @PageName and PageMode = @PageMode