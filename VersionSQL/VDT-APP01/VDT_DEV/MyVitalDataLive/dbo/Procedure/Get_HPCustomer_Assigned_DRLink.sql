/****** Object:  Procedure [dbo].[Get_HPCustomer_Assigned_DRLink]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HPCustomer_Assigned_DRLink] 
	@UserName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	--if exists (select top 1 * from MDUser where Username = @UserName and Organization = 'Driscoll SSO')
	--begin
	--	select a.cust_id as cust_id, a.name as name 
	--   from HPCustomer a
	--   where Name = 'Driscoll'
	--end
	--else
	begin

		Create table #TempNPI (NPI varchar(50))

		Insert #TempNPI
		select distinct(d.npi) from dbo.MDUser a
		join Link_MDAccountGroup b on a.ID = b.MDAccountID
		join dbo.MDGroup c on b.MDGroupID = c.ID
		join dbo.Link_MDGroupNPI d on c.ID = d.MDGroupID

		where Username = @UserName

		select distinct a.cust_id as cust_id, a.name as name from HPCustomer a
		join dbo.Lookup_DRLink_NPI_to_CustID b on 
		a.cust_id = b.cust_id where b.NPI in (Select NPI from #TempNPI) 
		AND b.Cust_ID != 7
		 
		drop table #TempNPI
	end
 
END

--EXEC [dbo].[Get_HPCustomer_Assigned_DRLink] 
--	@UserName ='gmarin'