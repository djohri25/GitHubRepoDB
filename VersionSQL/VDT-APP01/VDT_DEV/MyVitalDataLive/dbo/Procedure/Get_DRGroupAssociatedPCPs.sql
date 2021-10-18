/****** Object:  Procedure [dbo].[Get_DRGroupAssociatedPCPs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/11/2013
-- Description:	If @DrGroupID = 0 select PCPs associated to all groups
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_DRGroupAssociatedPCPs]
	@DrGroupID int,
	@TIN varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;

--select @DrGroupID = 19 --908

	declare @TempSelect table (NPI varchar(200), pcpFullname varchar(200)) 

	if exists(select * 
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
				
				+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and n.NPI = ms.NPI 
							and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end						
					)) + ' )'
				
			else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
					+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and n.NPI = ms.NPI 		
							and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end 
					)) + ' )'
				
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
			--and ld.Cust_ID = @CustID
		
		order by AccountName 		
option(recompile)
	end
	else
	begin	
		Insert @TempSelect(pcpFullname,NPI)
		select distinct 
			--case isnull(dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'') ,'')
			--when '' then [Provider Organization Name (Legal Business Name)]
			--else dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
			--end
			--+ ' (' + g.NPI + ')' as pcpFullname, 
			case ln.[Entity Type Code]
			when 1 then dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50),
				ln.[Provider First Name],
				ln.[Provider Middle Name]) 
				
				+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and ln.NPI = ms.NPI 
							--and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end						
					)) + ' )'
				
			else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
					+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and ln.NPI = ms.NPI 		
							--and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end 
					)) + ' )'
				
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
option(recompile)
	end

	delete @TempSelect 
	where pcpFullname like '%( 0 )'

	Select distinct npi, pcpFullname 
	from @TempSelect
	order by pcpFullname
END