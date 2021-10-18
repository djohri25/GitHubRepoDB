/****** Object:  Procedure [dbo].[GetNPIbyGroupIdWithALL]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[GetNPIbyGroupIdWithALL]
	@DrGroupID int ,@TIN varchar(50) = NULL 
AS 

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	CREATE TABLE #temp(NPI varchar(200), pcpFullname varchar(200)) 

	if(@DrGroupID != 0)
	BEGIN
	IF EXISTS (SELECT * FROM dbo.MDGroup g INNER JOIN
							 dbo.HPCustomer c ON g.CustID_Import = c.Cust_ID
							 WHERE        id = @DrGroupID ) -- AND c.Name LIKE 'Driscoll%'
	BEGIN
		INSERT INTO #temp(NPI, pcpFullname)
	SELECt n.NPI AS DoctorID, CASE ln.[Entity Type Code] WHEN 1 THEN dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)], 50), ln.[Provider First Name], ln.[Provider Middle Name]) 
	 + '   ( ' + CONVERT(varchar(5),
	(SELECT        COUNT(*) FROM            dbo.MainSpecialist ms JOIN
						   dbo.Link_MemberId_MVD_Ins ins ON ms.ICENUMBER = ins.MVDId
						   WHERE        ins.Active = 1 AND n.NPI = ms.NPI AND ins.Cust_ID = g.CustID_Import AND ms.RoleID = 1 AND isnull(TIN, '') = CASE isnull(@TIN, '0') WHEN '0' THEN isnull(TIN, '') ELSE @TIN END))
	+ ' )' ELSE LEFT(ln.[Provider Organization Name (Legal Business Name)], 50) + '   ( ' + CONVERT(varchar(5),
	(SELECT        COUNT(*)
	FROM            dbo.MainSpecialist ms JOIN
	dbo.Link_MemberId_MVD_Ins ins ON ms.ICENUMBER = ins.MVDId
	WHERE        ins.Active = 1 AND n.NPI = ms.NPI AND ins.Cust_ID = g.CustID_Import AND ms.RoleID = 1 AND isnull(TIN, '') = CASE isnull(@TIN, '0') WHEN '0' THEN isnull(TIN, '') ELSE @TIN END))
	+ ' )' END AS AccountName
	FROM            dbo.MDGroup g INNER JOIN
					dbo.Link_MDGroupNPI n ON g.ID = n.MDGroupID INNER JOIN
					dbo.LookupNPI ln ON n.NPI = ln.NPI INNER JOIN
					dbo.Lookup_DRLink_NPI_to_CustID ld ON n.NPI = ld.NPI
	WHERE        MDGroupID = CASE isnull(@DrGroupID, 0) WHEN 0 THEN MDGroupID /* ignore the filter*/ ELSE @DrGroupID END
	/*and ld.Cust_ID = @CustID*/ ORDER BY AccountName END
                                 

									 else
		begin	
			Insert into #temp(pcpFullname,NPI)
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
	from dbo.Link_MDGroupNPI g
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
	DECLARE @countNPI int
	SELECT @countNPI= count(distinct NPI) FROM #temp

	--SELECT @countNPI
	if(@countNPI > 0 )
	BEGIN
		Select distinct NPI, pcpFullname 
		from #temp
		UNIOn
		SELECT 0,'ALL' AS GroupName 
		order by NPI

	END
	ELSE
	BEGIN
		Select distinct NPI, pcpFullname 
		from #temp

	END
	END

	if(@DrGroupID = 0)
	BEGIN
	INSERT INTO #temp
	(
		NPI,
		pcpFullname
	)
	VALUES
	(
		0, -- NPI - varchar
		'ALL' -- pcpFullname - varchar
	)
	SELECT * FROM #temp t
	END
		DROP TABLE #temp

END