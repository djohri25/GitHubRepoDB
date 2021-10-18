/****** Object:  Procedure [dbo].[uspUpdateUserCareQGroupMapping_20200617]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateUserCareQGroupMapping_20200617]
	@userId nvarchar(50),
	@groupName nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	delete from Link_HPAlertGroupAgent where Agent_ID = @userId
    
	Insert into Link_HPAlertGroupAgent(Group_ID,Agent_ID)
	select hag.ID, @userId
	from HPAlertGroup hag
	where hag.[Name] in (select * from string_split(@groupName,','))
END