/****** Object:  Procedure [dbo].[Get_MDAccountByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDAccountByID]
	@ID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @GroupList varchar(max)
	
	set @GroupList = ''
	
	select @GroupList = @GroupList + CONVERT(varchar(10),MDGroupID) + ';'
	from dbo.Link_MDAccountGroup 
	where MDAccountID = @ID
	
	if(ISNULL(@GroupList,'') <> '')
	begin
		set @GroupList = SUBSTRING(@GroupList, 0, len(@GroupList))
	end
	
	SELECT ID
      ,Username
      ,Email
      ,Password
      ,Active
      ,FirstName
      ,LastName
      ,CreationDate
      ,ModifyDate
      ,LastLogin
      ,LastLoginIP
      ,SecurityQ1
      ,SecurityA1
      ,SecurityQ2
      ,SecurityA2
      ,SecurityQ3
      ,SecurityA3
      ,Company
      ,AccountName
      ,@GroupList as 'GroupList'
      ,FirstName
      ,LastName
      ,Organization
      ,Phone
  FROM MDUser
  where ID = @ID
END