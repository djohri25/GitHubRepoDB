/****** Object:  Procedure [dbo].[Get_MDGroups_by_Customer]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MDGroups_by_Customer] @Cust_ID int
AS
BEGIN
	SET NOCOUNT ON;
	
	Create table #TempGroup (GroupName varchar(200))
	
	Insert #TempGroup
	Select distinct( a.GroupName ) from  MDGroup a join dbo.Link_MDGroupNPI b
	on a.ID = b.MDGroupID
	where CustID_Import = @Cust_ID
	and a.Active = 0
	and IsNoteAlertGroup = 0
	order by GroupName

	SELECT ID
      ,GroupName
      ,Active
      ,IsNoteAlertGroup
      ,CreationDate
      ,ModifyDate
	FROM MDGroup
	where GroupName in ( select GroupName from #TempGroup)
	and	CustID_Import = @Cust_ID
	and Active = 0
	order by GroupName
END