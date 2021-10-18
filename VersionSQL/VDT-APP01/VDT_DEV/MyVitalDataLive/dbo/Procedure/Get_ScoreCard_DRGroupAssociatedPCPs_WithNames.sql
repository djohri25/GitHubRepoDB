/****** Object:  Procedure [dbo].[Get_ScoreCard_DRGroupAssociatedPCPs_WithNames]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- Example:	EXEC dbo.Get_ScoreCard_DRGroupAssociatedPCPs_WithNames @DrGroupID=908,@MonthID=201611
-- Change History
-- Date         Developer           Issue# - Description
--------------- ------------------- --------------------
-- 11/18/2016	Marc De Luca		Added some intermediary temp tables for performance purposes
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[Get_ScoreCard_DRGroupAssociatedPCPs_WithNames]
	 @DrGroupID int
	,@TIN varchar(20) = null
	,@MonthID int
AS
BEGIN
	SET NOCOUNT ON;

	declare @TempSelect table (NPI varchar(200), pcpFullname varchar(200)) 

	if exists(select top (1) * from MDGroup g join HPCustomer c on g.CustID_Import = c.Cust_ID where id = @DrGroupID and c.Name like 'Driscoll%')
	begin

		IF OBJECT_ID('tempdb..#Temp1') IS NOT NULL DROP TABLE #Temp1;
		SELECT DISTINCT 
		 n.PCP_NPI
		 ,g.CustID_Import
		,ln.[Entity Type Code]
		,ln.[Provider Last Name (Legal Name)]
		,ln.[Provider First Name]
		,ln.[Provider Middle Name]
		,ln.[Provider Organization Name (Legal Business Name)]
		INTO #Temp1
		from MDGroup g
		inner join [Final_HEDIS_Member_FULL] n on n.PCP_TIN = g.GroupName and g.[CustID_Import] = n.CustID
		inner join dbo.LookupNPI ln on n.PCP_NPI = ln.NPI	
		inner join Lookup_DRLink_NPI_to_CustID ld on n.PCP_NPI = ld.NPI and ld.Cust_ID = n.CustID
		where (g.ID = @DrGroupID OR @DrGroupID = 0)
		and n.MonthID = @MonthID
	
		Insert @TempSelect(NPI,pcpFullname)
		select distinct x.PCP_NPI as DoctorID, 
			case x.[Entity Type Code]
			when 1 then dbo.FullName(LEFT(x.[Provider Last Name (Legal Name)],50),	x.[Provider First Name],x.[Provider Middle Name]) 
				
				+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and x.PCP_NPI = ms.NPI 
							and ins.Cust_ID = x.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end						
					)) + ' )'
				
			else LEFT(x.[Provider Organization Name (Legal Business Name)],50)
					+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and x.PCP_NPI = ms.NPI 		
							and ins.Cust_ID = x.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end 
					)) + ' )'
				
			end as AccountName
		from #Temp1 x
		order by AccountName 		
	end
	else
	begin	

		IF OBJECT_ID('tempdb..#Temp2') IS NOT NULL DROP TABLE #Temp2;
		SELECT DISTINCT 
		ln.[Entity Type Code]
		,ln.[Provider Last Name (Legal Name)]
		,ln.[Provider First Name]
		,ln.[Provider Middle Name]
		,ln.[Provider Organization Name (Legal Business Name)]
		,ln.NPI
		,g.PCP_NPI
		INTO #Temp2
		from [Final_HEDIS_Member_FULL] g 
			inner join MDGroup m  on g.PCP_TIN = m.GroupName and m.[CustID_Import] = g.CustID
			inner join dbo.LookupNPI ln on g.PCP_NPI = ln.NPI 
		where m.ID = 
			case isnull(@DrGroupID,0)
			when 0 then m.ID		-- ignore the filter
			else @DrGroupID
			end		
		and g.MonthID = @MonthID

		Insert @TempSelect(pcpFullname,NPI)
		select distinct 
			case x.[Entity Type Code]
			when 1 then dbo.FullName(LEFT(x.[Provider Last Name (Legal Name)],50),
				x.[Provider First Name],
				x.[Provider Middle Name]) 
				
				+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and x.NPI = ms.NPI 
							--and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end						
					)) + ' )'
				
			else LEFT(x.[Provider Organization Name (Legal Business Name)],50)
					+ '   ( ' + convert(varchar(5),
					(
						select COUNT(*) 
						from dbo.MainSpecialist ms 
							join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and x.NPI = ms.NPI 		
							--and ins.Cust_ID = g.CustID_Import
							and ms.RoleID = 1
							AND isnull(TIN,'') = 
								case isnull(@TIN,'0')
								when '0' then isnull(TIN,'')
								else @TIN
								end 
					)) + ' )'
				
			end as AccountName,			
			x.PCP_NPI
		from #Temp2 x 
		order by AccountName 
	end


	delete @TempSelect 
	where pcpFullname like '%( 0 )'

	Select distinct RTRIM(npi) AS npi, pcpFullname +' '+'('+RTRIM(npi)+')' AS pcpFullname 
	from @TempSelect
	order by pcpFullname

END