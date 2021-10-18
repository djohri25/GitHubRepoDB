/****** Object:  Procedure [dbo].[Get_MDGroupByID_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bruce
-- Create date: 6/25/2016
-- Description:	For testing with Parkland providers
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroupByID_Test]
	@ID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @NPIList varchar(max)
	
	set @NPIList = ''
	
	select @NPIList = @NPIList + ma.NPI + ':' + dbo.FullName(n.[Provider Last Name (Legal Name)],n.[Provider First Name],'') + ';'
	from Link_MDGroupNPI_Test ma
		inner join dbo.LookupNPI n on ma.NPI = n.NPI
	where MDGroupID = @ID
	
	if(ISNULL(@NPIList,'') <> '')
	begin
		set @NPIList = SUBSTRING(@NPIList, 0, len(@NPIList))
	end
	
	SELECT ID
      ,GroupName
      ,Active
      ,IsNoteAlertGroup
      ,CreationDate
      ,ModifyDate
      ,@NPIList as 'NPIList'
  FROM MDGroup_Test
  where ID = @ID
END