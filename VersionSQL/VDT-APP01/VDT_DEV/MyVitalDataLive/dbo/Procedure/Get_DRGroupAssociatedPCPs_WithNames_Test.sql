/****** Object:  Procedure [dbo].[Get_DRGroupAssociatedPCPs_WithNames_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bruce
-- Create date: 6/25/2016
-- Description:	If @DrGroupID = 0 select PCPs associated to all groups 
--				For testing with Parkland providers
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_DRGroupAssociatedPCPs_WithNames_Test]
	@DrGroupID int,
	@TIN varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;

--Active Group IDs
--59685
--60079
--60182
--60496
--60529
--60616

--select @DrGroupID = 19 --908

	declare @TempSelect table (NPI varchar(200), pcpFullname varchar(200)) 

	if exists(select top 1 * 
		from MDGroup_Test g
			inner join HPCustomer c on g.CustID_Import = c.Cust_ID
		where id = @DrGroupID and c.Name like 'Driscoll%')    --custid?
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
						--select top 10 * from dbo.MainSpecialist_Test where TIN IS NOT NULL
						from dbo.MainSpecialist_Test ms 
							join dbo.Link_MemberId_MVD_Ins_Test ins on ms.ICENUMBER = ins.MVDId		
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
						from dbo.MainSpecialist_Test ms 
							join dbo.Link_MemberId_MVD_Ins_Test ins on ms.ICENUMBER = ins.MVDId
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
		--select * 
		from [MDGroup_Test] g
			inner join Link_MDGroupNPI_Test n on g.ID = n.MDGroupID	
			inner join LookupNPI ln on n.NPI = ln.NPI	
			inner join Lookup_DRLink_NPI_to_CustID_Test ld on n.NPI = ld.NPI 
			--select * from LookupNPI where NPI IN
			--(
			--'1477549749',
			--'1992761274',
			--'1710975560',
			--'1205801347'
			--)
		where MDGroupID = --60182
					--IN (59685,
					--	60079,
					--	60182,
					--	60496)
			case isnull(@DrGroupID,0)
			when 0 then MDGroupID		-- ignore the filter
			else @DrGroupID
			end
			--and ld.Cust_ID = @CustID		
		order by AccountName 		
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
						from dbo.MainSpecialist_Test ms 
							join dbo.Link_MemberId_MVD_Ins_Test ins on ms.ICENUMBER = ins.MVDId
						where ins.Active = 1
							and ln.NPI = ms.NPI 
						/*
							select *
							from dbo.MainSpecialist_Test ms 
								join dbo.Link_MemberId_MVD_Ins_Test ins on ms.ICENUMBER = ins.MVDId
							where ins.Active = 1
							and ins.MVDId IN
							(
							'AJ763785',
							'KK970035',
							'CS627472',
							'AN889672',
							'ER342923',
							'TG260404',
							'TL715398'
							)

							select * from MainSpecialist_Test where
							NPI IN
							(
							'1477549749',
							'1992761274',
							'1710975560',
							'1205801347'
							)

							and ms.NPI IN
							(
							'1477549749',
							'1992761274',
							'1710975560',
							'1205801347'
							)
						*/
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
						from dbo.MainSpecialist_Test ms 
							join dbo.Link_MemberId_MVD_Ins_Test ins on ms.ICENUMBER = ins.MVDId
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
		--select * 
		from Link_MDGroupNPI_Test g
			inner join dbo.LookupNPI ln on g.NPI = ln.NPI
			--where MDGroupID IN (59685,
			--			60079,
			--			60182,
			--			60496)
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

/*
		exec
		[dbo].Get_DRGroupAssociatedPCPs_WithNames_Test
		@DrGroupID = 60496,
		@TIN = '522390705'
*/

--GroupID	GroupName/TIN	Active	Created		Cust_ID		SecondaryName						NPI
--59685		261475093		1		2016-06-25  10			QUESTCARE OBSTETRICS PLLC       	1477549749	
--60079		261475093		1		2016-06-25  10			QUESTCARE 							1992761274	
--60182		650816256		1		2016-06-25  10			OBSTETRIX MEDICAL GROUP             1710975560	
--60496		522390705		1		2016-06-25  10			PERINATAL MEDICINE ASSOCIATES       1205801347	