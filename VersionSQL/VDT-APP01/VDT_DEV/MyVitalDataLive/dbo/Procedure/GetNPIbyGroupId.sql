/****** Object:  Procedure [dbo].[GetNPIbyGroupId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[GetNPIbyGroupId]

@DrGroupID int,@TIN varchar(50) = NULL 

AS 

BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #temp(NPI varchar(200), pcpFullname varchar(200)) 
	IF EXISTS 
	(
		SELECT * 
		FROM MDGroup g 
		INNER JOIN HPCustomer c ON g.CustID_Import = c.Cust_ID
		WHERE id = @DrGroupID AND c.Name LIKE 'Driscoll%') 
	BEGIN
		INSERT INTO #temp(NPI, pcpFullname)
		SELECT        n.NPI AS DoctorID, CASE ln.[Entity Type Code] WHEN 1 THEN dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)], 50), ln.[Provider First Name], ln.[Provider Middle Name]) 
								+ '   ( ' + CONVERT(varchar(5),
									(SELECT        COUNT(*)
										FROM            dbo.MainSpecialist ms JOIN
																dbo.Link_MemberId_MVD_Ins ins ON ms.ICENUMBER = ins.MVDId
										WHERE        ins.Active = 1 AND n.NPI = ms.NPI AND ins.Cust_ID = g.CustID_Import AND ms.RoleID = 1 AND isnull(TIN, '') = CASE isnull(@TIN, '0') WHEN '0' THEN isnull(TIN, '') ELSE @TIN END)) 
								+ ' )' ELSE LEFT(ln.[Provider Organization Name (Legal Business Name)], 50) + '   ( ' + CONVERT(varchar(5),
									(SELECT        COUNT(*)
										FROM            dbo.MainSpecialist ms JOIN
																dbo.Link_MemberId_MVD_Ins ins ON ms.ICENUMBER = ins.MVDId
										WHERE        ins.Active = 1 AND n.NPI = ms.NPI AND ins.Cust_ID = g.CustID_Import AND ms.RoleID = 1 AND isnull(TIN, '') = CASE isnull(@TIN, '0') WHEN '0' THEN isnull(TIN, '') ELSE @TIN END)) 
								+ ' )' END AS AccountName
		FROM            MDGroup g INNER JOIN
								Link_MDGroupNPI n ON g.ID = n.MDGroupID INNER JOIN
								dbo.LookupNPI ln ON n.NPI = ln.NPI INNER JOIN
								Lookup_DRLink_NPI_to_CustID ld ON n.NPI = ld.NPI
		WHERE        MDGroupID = CASE isnull(@DrGroupID, 0) WHEN 0 THEN MDGroupID /* ignore the filter*/ ELSE @DrGroupID END
		/*and ld.Cust_ID = @CustID*/ ORDER BY AccountName END
                                 

		else
		begin	
			Insert into #temp(pcpFullname,NPI)
			select distinct 
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
		end

	delete #temp 
	where pcpFullname like '%( 0 )'

	Select distinct npi, pcpFullname 
	from #temp
	UNION
	SELECT 0,'ALL' AS GroupName 
	order by pcpFullname
	 
END