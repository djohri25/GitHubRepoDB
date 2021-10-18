/****** Object:  Procedure [dbo].[Get_MDAssociatedDoctors]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	Misha	
-- Create date: 02/28/2017
-- Description:	Retrieves the list of doctors from the groups the current doctor belongs to
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDAssociatedDoctors]
	@DoctorID varchar(20) = null,
	@DrGroupID int = 0,
	@TIN varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustID int, @DoctorID_Temp varchar(20)
	DECLARE @TIN_Array Table (TIN varchar(50))

	IF OBJECT_ID('tempdb..#TempSelect') IS NOT NULL DROP TABLE #TempSelect;
	CREATE TABLE #TempSelect (DoctorID varchar(200), AccountName varchar(200))

	--@DoctorID
	IF (@DrGroupID != 0)
	BEGIN
		SELECT @DoctorID_Temp = GroupName
		FROM MDGroup
		WHERE ID = @DrGroupID
	END
	ELSE
	BEGIN
		SELECT @DoctorID_Temp = @DoctorID
	END

	--CustID
	SELECT DISTINCT @CustID = CustID_Import
	FROM [dbo].[MDUser] a
	JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
	JOIN MDGroup c ON b.mdGroupID = c.ID
	WHERE username = @DoctorID_Temp

	--TIN
	SELECT @TIN = (CASE WHEN @TIN = '' THEN 'ALL' ELSE @TIN END)
	INSERT INTO @TIN_Array
	SELECT *
	FROM [dbo].[Get_TinArray](@DoctorID_Temp, @TIN)
	IF (@TIN = 'ALL' AND @DoctorID_Temp IS NOT NULL)
	BEGIN
		SELECT @TIN = '' -- TIN list is specified by the logged in user
	END

	IF OBJECT_ID('tempdb..#TempFAM') IS NOT NULL DROP TABLE #TempFAM;
	SELECT DISTINCT MemberID, CAST(NPI AS VARCHAR(50)) AS NPI
	INTO #TempFAM
	FROM [dbo].[Final_ALLMember]
	WHERE CustID = @CustID
	AND (@TIN = 'ALL' OR ([TIN] IN (SELECT TIN FROM @TIN_Array)))

	CREATE INDEX IX_NPI ON #TempFAM (NPI) INCLUDE (MemberID)

	INSERT #TempSelect
	SELECT 
		m.NPI as DoctorID,
		CASE ISNULL(m.[NPI], '')
			WHEN '' THEN ' No Assigned NPI'
				+ '   ( ' + CONVERT(varchar(5),
					(
						SELECT COUNT(DISTINCT MemberID)
						FROM #TempFAM
						WHERE NPI = m.NPI
					)) + ' )'
			ELSE
				CASE ln.[Entity Type Code]
					WHEN 1 THEN dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50), ln.[Provider First Name], ln.[Provider Middle Name]) 
						+ '   ( ' + CONVERT(varchar(5),
							(
								SELECT COUNT(DISTINCT MemberID)
								FROM #TempFAM
								WHERE NPI = m.NPI
							)) + ' )'
					ELSE LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
							+ '   ( ' + CONVERT(varchar(5),
							(
								SELECT COUNT(DISTINCT MemberID)
								FROM #TempFAM
								WHERE NPI = m.NPI
							)) + ' )'
				END
		END AS AccountName
	FROM
	( 
		SELECT DISTINCT NPI
		FROM #TempFAM
		--WHERE ISNULL(NPI, '') != ''
	) m
	LEFT JOIN [dbo].[LookupNPI] ln ON m.NPI = ln.NPI

	DELETE #TempSelect 
	WHERE AccountName LIKE '%( 0 )'

	SELECT * 
	FROM #TempSelect
	ORDER BY AccountName

END



--OLD CODE:
--SET NOCOUNT ON;

----select @doctorid = 'dchpbeta1', @TIN = '741662481'
		
--declare @Organization varchar(100), @CustID int

--select @Organization = Organization from mduser where Username = @doctorid

--Create Table #TempSelect (DoctorID varchar(200), AccountName varchar(200)) 

--if (@Organization like 'Driscol%') 
--Begin
--	Select @CustID = 11
	


--	Insert #TempSelect
--	select n.NPI as DoctorID, 
--		case ln.[Entity Type Code]
--		when 1 then dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50),
--			ln.[Provider First Name],
--			ln.[Provider Middle Name]) 
			
--			+ '   ( ' + convert(varchar(5),
--				(
--					select COUNT(*) 
--					from dbo.MainSpecialist ms 
--						join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
--					where ins.Active = 1
--						and n.NPI = ms.NPI 
--						and ins.Cust_ID = @CustID
--						and ms.RoleID = 1
--						AND isnull(TIN,'') = 
--							case isnull(@TIN,'0')
--							when '0' then isnull(TIN,'')
--							else @TIN
--							end						
--				)) + ' )'
			
--		else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
--				+ '   ( ' + convert(varchar(5),
--				(
--					select COUNT(*) 
--					from dbo.MainSpecialist ms 
--						join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
--					where ins.Active = 1
--						and n.NPI = ms.NPI 		
--						and ins.Cust_ID = @CustID
--						and ms.RoleID = 1
--						AND isnull(TIN,'') = 
--							case isnull(@TIN,'0')
--							when '0' then isnull(TIN,'')
--							else @TIN
--							end 
--				)) + ' )'
			
--		end as AccountName
		
--	from MDUser u
--		inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
--		inner join MDGroup g on ag.MDGroupID = g.ID
--		inner join Link_MDGroupNPI n on g.ID = n.MDGroupID	
--		inner join dbo.LookupNPI ln on n.NPI = ln.NPI	
--		inner join Lookup_DRLink_NPI_to_CustID ld on n.NPI = ld.NPI 
--	where u.username = @doctorId
--	and ld.Cust_ID = @CustID
	
--	order by AccountName 				
	
	
--END
--ELSE
--BEGIN

--Insert #TempSelect
--	select distinct (n.NPI) as DoctorID, 
--		case ln.[Entity Type Code]
--		when 1 then dbo.FullName(LEFT(ln.[Provider Last Name (Legal Name)],50),
--			ln.[Provider First Name],
--			ln.[Provider Middle Name]) 
			
--			+ '   ( ' + convert(varchar(5),(select COUNT(*) from dbo.MainSpecialist ms 
--		join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
--		where ins.Active = 1
--		and n.NPI = ms.NPI 

--		and ms.RoleID = 1
--		)) + ' )'
			
--		else LEFT(ln.[Provider Organization Name (Legal Business Name)],50)
--				+ '   ( ' + convert(varchar(5),(select COUNT(*) from dbo.MainSpecialist ms 
--		join dbo.Link_MemberId_MVD_Ins ins on ms.ICENUMBER = ins.MVDId
--		where ins.Active = 1
--		and n.NPI = ms.NPI 		

--		and ms.RoleID = 1
--		)) + ' )'
			
--		end as AccountName
		
--	from MDUser u
--		inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
--		inner join MDGroup g on ag.MDGroupID = g.ID
--		inner join Link_MDGroupNPI n on g.ID = n.MDGroupID	
--		inner join dbo.LookupNPI ln on n.NPI = ln.NPI	
--		inner join Lookup_DRLink_NPI_to_CustID ld on n.NPI = ld.NPI 
--	where u.username = @doctorId
--	order by AccountName 				

--END

--delete #TempSelect 
--where AccountName like '%( 0 )'

--Select * from #TempSelect

--Drop table #TempSelect