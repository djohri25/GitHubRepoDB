/****** Object:  Procedure [dbo].[Get_PCPListByHP]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 07/23/2010
-- Description:	 Returns the list of doctors set as Primary Care Physicians
-- NOTE: reference to dbo.lookupNPI  
-- 07/17/2017	Marc De Luca	Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_PCPListByHP]
	@Customer varchar(50),
	@Filter varchar(50)				-- Incomplete (the info, hours etc, was never updated by the user), Complete, or ALL
AS
BEGIN

	SET NOCOUNT ON;

--select @customer = '4'

	declare @RESULTLIMIT int,
		@pcpRoleID int,
		@parentHPCustomerID int

	declare @tempResult table(
		npi varchar(20),
		firstname varchar(50),
		lastname varchar(50),
		city varchar(100),
		state varchar(2),
		patientCount int
		)

	set @RESULTLIMIT = 25 

	select @pcpRoleID = RoleID 
	from lookuproleid
	where roleName = 'Primary Care Physician'

	set @parentHPCustomerID = dbo.Get_HPParentCustomerID(@Customer)


	if(@filter = 'incomplete')
	begin
		select top 20 with ties  n.npi, 
			dbo.InitCap(LEFT([Provider First Name],50)) AS FirstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) AS State,
			patientCount
		from 
			(select  NPI, count(icenumber) as patientCount
				from mainspecialist s
					inner join dbo.Link_MVDID_CustID li on s.icenumber = li.mvdid
				where roleID = @pcpRoleID and NPI is not NULL and li.cust_id = @parentHPCustomerID
					and npi not in
						(
							select npi from dbo.LookupNPI_Custom
						)
				group by NPI
			) t inner join dbo.lookupNPI n on t.npi = n.npi
		order by patientCount desc
	end
	else if (@filter = 'complete')
	begin
		select top 20 with ties  n.npi, 
			dbo.InitCap(LEFT([Provider First Name],50)) AS FirstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) AS State,
			patientCount
		from 
			(select  NPI, count(icenumber) as patientCount
				from mainspecialist s
					inner join dbo.Link_MVDID_CustID li on s.icenumber = li.mvdid
				where roleID = @pcpRoleID and NPI is not NULL and li.cust_id = @parentHPCustomerID
					and npi in
						(
							select npi from dbo.LookupNPI_Custom
						)
				group by NPI
			) t inner join dbo.lookupNPI n on t.npi = n.npi
		order by patientCount desc
	end
	else
	begin
		select top 20 with ties  n.npi, 
			dbo.InitCap(LEFT([Provider First Name],50)) AS FirstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) AS State,
			patientCount
		from 
			(select  NPI, count(icenumber) as patientCount
				from mainspecialist s
					inner join dbo.Link_MVDID_CustID li on s.icenumber = li.mvdid
				where roleID = @pcpRoleID and NPI is not NULL and li.cust_id = @parentHPCustomerID
				group by NPI
			) t inner join dbo.lookupNPI n on t.npi = n.npi
		order by patientCount desc
	end
	
	/*
	-- Option without temp table
select top 20 with ties  s.npi, 
			dbo.InitCap(LEFT([Provider First Name],50)) AS FirstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) AS State,
			count(icenumber) as patientCount
from mainspecialist s
	inner join dbo.Link_MVDID_CustID li on s.icenumber = li.mvdid
	inner join dbo.lookupNPI n on s.npi = n.npi
where roleID = 1 and s.NPI is not NULL and li.cust_id = 10
group by s.NPI,[Provider First Name],[Provider Last Name (Legal Name)],[Provider Business Practice Location Address City Name],[Provider Business Practice Location Address State Name]
order by patientCount desc
			
	*/
END