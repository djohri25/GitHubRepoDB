/****** Object:  Procedure [dbo].[Get_MDPatientsByDoctor]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/10/2009
-- Description:	Return the list of patients assigned
--	to a specific doctor or doctors from the groups the
--  current doctor belongs to
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientsByDoctor]
	@DoctorID varchar(20),
	@PCP_NPI varchar(20),
	@DiseaseID varchar(20),
	@HPName varchar(50),
	@IsStatusComplete bit
AS
BEGIN
	SET NOCOUNT ON;

--select @doctorid = 'sales', @DiseaseID = 'AST'
--	,
--	@HPName = 'General Health Plan'
--	,
--	@PCP_NPI = '1003000175'
--	,@IsStatusComplete = 0
	
	declare @sql varchar(max), @VisitCountDateRange datetime

	set @VisitCountDateRange = dateadd(mm,-6,getdate())

select @sql = 'SELECT m.ID,DoctorID,DoctorUsername,HPName,CustID,MemberID,
		MVDID,isnull(MemberLastName + ''' + ',' + ''',''' + ''') + isnull(MemberFirstName,''' + ''') as name,
		PCP_NPI, '  +
		case @DiseaseID 
		when 'AST' then '0'
		when 'DIA' then '0'
		else 'isnull(' + @DiseaseID + 'StatusID' + ',''' + '0' + ''')'
		end + ' as TestStatusID,
		(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = m.mvdid and v.VisitType = ''' + 'ER' + ''' and v.visitdate > ''' + convert(varchar, @VisitCountDateRange,101) + ''') as ERVisitCount,
		(SELECT COUNT(ID) FROM MD_Note n where n.MvdID = m.mvdid and n.ModifyDate > dateadd(dd,-14,GETDATE()))  as NoteCount      


FROM MDUser_Member m 
	left join LookupTestDueStatus s on m.' 
	+ case @DiseaseID
	  when 'AST' then 'ID'
	  when 'DIA' then 'ID'
	  else @DiseaseID + 'StatusID '
	  end
	+ ' = s.ID
where DoctorUsername = ''' + @DoctorID + '''
	AND ' +
	case @DiseaseID
	when 'AST' then 'Asthma'
	when 'DIA' then 'Diabetes'
	else @DiseaseID
	end + ' = ''' + 'Y' + '''
	AND HPName = ' +
	case isnull(@HPName,'ALL')
	when 'ALL' then 'HPName'
	else '''' + @HPName + ''''
	end + '
	AND PCP_NPI = ' +
	case isnull(@PCP_NPI,'0')
	when '0' then 'PCP_NPI'
	else '''' + @PCP_NPI + ''''
	end 
	+ ' 
	AND isnull(s.IsComplete,''' + '0' + ''') = ''' + convert(varchar,isnull(@IsStatusComplete,'0')) + ''''

	--AND isnull(s.IsComplete, ''' + ''') = ' +
	--case isnull(@IsStatusComplete,'0')
	--when '0' then ' isnull(s.IsComplete, ''' + ''') '
	--else '''' + convert(varchar,@IsStatusComplete) + ''''
	--end

--select @sql

EXEC (@sql)


/*
	-- USED BEFORE 6/13/2013
	
--select * from MDUser_Member

--select * from LookupTestDueStatus

    --select ID, Name, Abbreviation from LookupDRMyPatientsDisease
    --order by OrderInd
    
SELECT ID,DoctorID,DoctorUsername,HPName,CustID,MemberID,'' as StatusIDList,
      MVDID,isnull(MemberLastName + ',','') + isnull(MemberFirstName,'') as name,PCP_NPI,Asthma as 'AST',Diabetes as 'DIA'
      ,W15,W34,AWC,LSC,BCS,CCS,COL,CAP,
      isnull(W15StatusID,'0') as W15StatusID,isnull(W34StatusID,'0') as W34StatusID,isnull(AWCStatusID,'0') as AWCStatusID,
      isnull(LSCStatusID,'0') as LSCStatusID,isnull(BCSStatusID,'0') as BCSStatusID,isnull(CCSStatusID,'0') as CCSStatusID,
      isnull(COLStatusID,'0') as COLStatusID,isnull(CAPStatusID,'0') as CAPStatusID
FROM MDUser_Member
where DoctorUsername = @DoctorID   
*/

/*
	declare @PCPLookupId int, @tempMvdid varchar(15), @tempStatusIDList varchar(50), @sql varchar(max)

	--declare @W15ID int, @W34ID int, @AWCID int, @LSCID int, @BCSID int, @CCSID int, @COLID int

	--declare @temp table (name varchar(200), hpName varchar(100), memberid varchar(50), custid varchar(50), mvdid varchar(15), doctorID int,
	--	Asthma char(1) default('N'), Diabetes char(1) default('N'), W15 char(1) default('N'), W34 char(1) default('N'), AWC char(1) default('N'), LSC char(1) default('N'), BCS char(1) default('N'), CCS char(1) default('N'), COL char(1) default('N'), 
	--	PCP_NPI varchar(50), statusIDList varchar(50), isProcessed bit default(0))

	select @PCPLookupId = roleID  
	from LookupRoleID 
	where rolename = 'Primary Care Physician'
	
	select @W15ID = ID from LookupHedis where Abbreviation = 'W15'
	select @W34ID = ID from LookupHedis where Abbreviation = 'W34'
	select @AWCID = ID from LookupHedis where Abbreviation = 'AWC'
	select @LSCID = ID from LookupHedis where Abbreviation = 'LSC'
	select @BCSID = ID from LookupHedis where Abbreviation = 'BCS'
	select @CCSID = ID from LookupHedis where Abbreviation = 'CCS'
	select @COLID = ID from LookupHedis where Abbreviation = 'COL'

	select @userID = ID from MDUser where Username = @DoctorID

	select  isnull(p.lastname + ',','') + isnull(p.firstname,'') as name,
		c.name as HPName,
		mi.insMemberId as MemberID,
		mi.cust_id as CustID,
		p.icenumber as MVDID,
		'' as StatusIDList,
		u.id as DoctorId, s.NPI as PCP_NPI,		
			case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '493') 
			when 'Y' then 'Y'
			else 'N'
			end as 'AST',
			case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = mi.MVDId and con.CodeFirst3 = '250') 
			when 'Y' then 'Y'
			else 'N'
			end as 'DIA',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W15ID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'W15',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @W34ID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'W34',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @AWCID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'AWC',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @LSCID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'LSC',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @BCSID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'BCS',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @CCSID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'CCS',
			case (select TOP 1 'Y' from MainToDoHEDIS h where h.MemberID = mi.insMemberID and h.TestLookupID = @COLID) 
			when 'Y' then 'Y'
			else 'N'
			end as 'COL'			
	from MDUser u
		inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
		inner join MDGroup g on ag.MDGroupID = g.ID
		inner join Link_MDGroupNPI n on g.ID = n.MDGroupID
		inner join MainSpecialist s on n.NPI = s.NPI
		inner join mainpersonaldetails p on s.icenumber = p.icenumber	
		inner join Link_MVDID_CustID mi on p.icenumber = mi.mvdid
		inner join hpcustomer c on mi.cust_id = c.cust_id	
	where u.username = @DoctorID
		and s.RoleID = @PCPLookupId
		and s.RecordNumber in
		(
			select top 1 SS.recordNumber from MainSpecialist ss where ss.ICENUMBER = s.ICENUMBER and ss.RoleID = @PCPLookupId
			order by SS.ModifyDate desc
		)	
		AND
		c.Name = 
			Case ISNULL(@HPName,'')
				when '' then c.Name
				else @HPName
			end
		AND
		s.NPI = 
			Case ISNULL(@PCP_NPI,'')
				when '' then s.NPI
				else @PCP_NPI
			end
			
*/
			
	-- Get status for each patient
	--while exists (select name from @temp where isProcessed = 0)
	--begin
	--	select top 1 @tempMvdid = mvdid from @temp where isProcessed = 0
		
	--	Exec dbo.Get_MDPatientStatus
	--		@MvdID = @tempMvdid,
	--		@DoctorID = @DoctorID,
	--		@StatusIDList = @tempStatusIDList OUTPUT
	
	--	update @temp set StatusIDList = @tempStatusIDList, isprocessed = 1 
	--	where mvdid = @tempMvdid
	--end

	--select name, hpName, memberid, custid, mvdid, StatusIDList, doctorID, PCP_NPI, Asthma as Ast, Diabetes as Dia, W15,W34,AWC,LSC,BCS,CCS,COL
	--from @temp
	--order by SUBSTRING(StatusIDList,1,1) desc
END