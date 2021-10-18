/****** Object:  Procedure [dbo].[Get_DRGroupAssociatedPCPs_WithNames_Lite]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/11/2013
-- Description:	If @DrGroupID = 0 select PCPs associated to all groups
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_DRGroupAssociatedPCPs_WithNames_Lite]
	@DrGroupID int,
	@TIN varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;

--select @DrGroupID = 19 --908

	declare @TempSelect table (NPI varchar(200), pcpFullname varchar(200)) 

	if exists(select top 1 * 
		from MDGroup g
			inner join HPCustomer c on g.CustID_Import = c.Cust_ID
		where id = @DrGroupID and c.Name like 'Driscoll%')
	begin
		Insert @TempSelect(NPI,pcpFullname)
		select n.NPI as DoctorID, 
			case ln.[Entity Type Code]
			when 1 then dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50),
				ln.[Provider First Name],
				ln.[Provider Middle Name])
			else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
			end as AccountName
		from MDGroup g
			inner join Link_MDGroupNPI n on g.ID = n.MDGroupID	
			inner join dbo.LookupNPI ln on n.NPI = ln.NPI	
			inner join Lookup_DRLink_NPI_to_CustID ld on n.NPI = ld.NPI 
		where MDGroupID = 
			case isnull(@DrGroupID,0)
			when 0 then MDGroupID		-- ignore the filter
			else @DrGroupID
			end
		order by AccountName 		
	end
	else
	begin	
		Insert @TempSelect(pcpFullname,NPI)
		select distinct 
			case ln.[Entity Type Code]
			when 1 then dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50),
				ln.[Provider First Name],
				ln.[Provider Middle Name]) 
			else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
			end as AccountName,			
			g.NPI
		from Link_MDGroupNPI g
			inner join dbo.LookupNPI ln on g.NPI = ln.NPI
		where MDGroupID = 
			case isnull(@DrGroupID,0)
			when 0 then MDGroupID		-- ignore the filter
			else @DrGroupID
			end		
		order by AccountName 
	end

	delete @TempSelect 
	where pcpFullname like '%( 0 )'

	Select distinct npi, pcpFullname +' '+'('+npi+')' AS pcpFullname 
	from @TempSelect
	order by pcpFullname
END