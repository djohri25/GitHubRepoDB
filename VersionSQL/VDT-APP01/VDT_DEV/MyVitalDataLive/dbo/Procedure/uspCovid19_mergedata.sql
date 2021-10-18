/****** Object:  Procedure [dbo].[uspCovid19_mergedata]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure uspCovid19_mergedata ( @p_start_date datetime = null )
AS
/*
Createdby : Sunil Nokku
Date      :	6/2/2020
About	  : Incremental Covid data for Power BI

--exec uspCovid19_mergedata '20191001'
*/
BEGIN

SET NOCOUNT ON;
--DECLARE @p_start_date datetime='20191001'
DECLARE @v_start_date datetime
DECLARE @v_PBI_Loaddate datetime

IF(@p_start_date is not null)
	BEGIN
	SET @v_start_date = @p_start_date
	END
ELSE
	BEGIN
	SELECT @v_start_date = MAX(Loaddate) FROM FinalCovidMember
	END

	-- We're interested in any MVDID with following Covid-19 specific information:
	-- HCPCS Level II: 'U0001', 'U0002' -- High Speed machine testing , 'U0003', 'U0004'
	-- CPT: 87635
	-- ICD10 U071
	-- 86328 — Immunoassay for infectious agent antibody(ies), qualitative or semiquantitative, single-step method (e.g., reagent strip); severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) (Coronavirus disease [COVID-19]).
	-- 86769 — Antibody; severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) (Coronavirus disease [COVID-19]).
	
	drop table if exists #CovidHeaderCode
	drop table if exists #CovidFinalClaimsDetailCode
	drop table if exists #CovidFInalClaimsDetail
	drop table if exists #mbr_diag
	drop table if exists #mbr_family
	drop table if exists #mbr_contact
	drop table if exists #MbrComorbGrp
	drop table if exists #mbr_crosstab
	drop table if exists #mbr_positive
	
	-- collect relevant claims from header and detail
	select * 
	into #CovidHeaderCode 
	from FinalClaimsHeaderCode 
	where 
    CodeType='DIAG' 
	and CodeValue='U071' 
	and LoadDate > @v_start_date
	
	select * 
	into #CovidFinalClaimsDetailCode 
	from FinalClaimsDetailCode 
	where CodeType='DIAG' 
	and CodeValue='U071' 
	and LoadDate > @v_start_date

	select * 
    into #CovidFInalClaimsDetail 
	from FInalClaimsDetail 
	where procedureCode IN ('87635','86328','86769', 'U0001', 'U0002', 'U0003', 'U0004' ) 
	and LoadDate > @v_start_date

	create nonclustered index idx_CovidHeaderCode_MVDID on #CovidHeaderCode (MVDID)
	create nonclustered index idx_CovidFinalClaimsDetailCode_MVDID on #CovidFinalClaimsDetailCode (MVDID)
	create nonclustered index idx_CovidFInalClaimsDetail_MVDID on #CovidFInalClaimsDetail (MVDID)

	select @v_PBI_Loaddate = max(Loaddate) from FinalClaimsHeaderCode
	
	-- join to other tables to enrich the claims data and place results in member detail table
	select distinct A.*,
	CASE
	WHEN code IN ('U0001', 'U0002', 'U0003', 'U0004') THEN 'HCPCS'
	WHEN code IN ('87635','86328','86769') THEN 'CPT'
	WHEN code = 'U071' THEN 'ICD10'
	ELSE 'NA'
	END
	as TypeOfDiag
	, D.RiskGroupID, B.MemberFirstName, B.MemberLastName
	, DATEDIFF(YY, PatientDob, GETDATE()) as Age
	, PatientGender as sex, M.LOB, M.CmOrgRegion, StatementFromDate
	, M.Zipcode, M.SubscriberID, M.Relationship, M.State, M.City, M.countyname
	, EmergencyIndicator
	, NetworkIndicator
	, AdmissionDate
	, DischargeDate
	, DischargeStatusCode
	, BilledAmount
	, ClaimStatus
	, FacilityTIN
	, B.PartyKey
	into #mbr_diag
	from
	(select MVDID, ClaimNumber, CodeValue as code from #CovidHeaderCode 
	UNION
	select MVDID, ClaimNumber, CodeValue as code from #CovidFinalClaimsDetailCode  
	UNION
	select MVDID, ClaimNumber, ProcedureCode as code from #CovidFInalClaimsDetail ) as A
	left join
	FinalClaimsHeader as b
	ON A.MVDID = B.MVDID and A.ClaimNumber = B.ClaimNumber
	left join
	(select distinct MVDID, RiskGroupID from myvitaldatalive.dbo.ComputedCareQueue ) as D
	ON A.MVDID = D.MVDID 
	join 
	FinalMember M 
	on M.MVDID = A.MVDID
	where B.ClaimStatus != '2'

	-- Matrix of Elixhauser scores for all members diagnosed or tested
	select A.Mvdid, B.GroupID, L.GroupName
	into #MbrComorbGrp
	from
	#mbr_diag as A
	left join
	(select distinct MVDID, GroupID from myvitaldatalive.dbo.ElixMemberRisk) as B
	ON A.MVDID = B.MVDID 
	left join
	myvitaldatalive.dbo.LookupElixGroup as L
	on B.GroupID = L.GroupID

	create nonclustered index idx_MbrComorbGrp_MVDID on #MbrComorbGrp (MVDID)

	-- full crosstab of conditions
	select * 
	into #mbr_crosstab
	from ( select MVDID, GroupName, GroupID from #MbrComorbGrp) S -- where GroupID IN (4, 10, 2, 6, 7)
	pivot (max(S.Groupname) for GroupID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],
	[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]) ) as GrpName
	order by MVDID

	create nonclustered index idx_mbr_crosstab_MVDID on #mbr_crosstab (MVDID)

	-- collect contact information for those members that have been diagnosed positive
	Select FM.MVDID, FM.MemberID,FM.MemberLastName, FM.MemberFirstName, FM.CmOrgRegion, FormDate, 
	FormAuthor, q2program as Program, q3ContactType as EngagementType, q4ContactType WhoContacted, q7ContactSuccess as Disposition
	into #mbr_contact
	from myvitaldatalive.dbo.ARBCBS_Contact_Form CF
	join (
	select MVDID, min(statementfromdate) as minDate, max(statementfromDate) as maxdate
	from #mbr_diag
	where TypeOfDiag='ICD10'
	group by MVDID) M on M.MVDID = CF.MVDID and CF.FormDate > = M.minDate
	left join FinalMember FM on FM.MVDID = CF.MVDID
	order by CF.MVDID, FormDate Desc

	create nonclustered index idx_mbr_contact_MVDID on #mbr_contact (MVDID)
	
	-- Final output for member tab, including case and contact details.
	INSERT INTO FinalCovidMember (
		MemberID,State,City,countyname,Zipcode,SubscriberID,CmOrgRegion,LOB,Relationship,MVDID,ClaimNumber,StatementFromDate,Code,TypeOfDiag, 
		RiskGroupID,MemberFirstName,MemberLastName,Age,Sex,EmergencyIndicator,NetworkIndicator,AdmissionDate,DischargeDate,DischargeStatusCode, 
		BilledAmount,ClaimStatus,FacilityTIN,PartyKey,CaseId,CaseOwner,CaseProgram,FormDate,FormAuthor,EngagementType,WhoContacted,Disposition,
		Cond1,Cond2,Cond3,Cond4,Cond5,Cond6,Cond7,Cond8,Cond9,Cond10,Cond11,Cond12,Cond13,Cond14,Cond15,Cond16,Cond17,Cond18,Cond19,Cond20,
		Cond21,Cond22,Cond23,Cond24,Cond25,Cond26,Cond27,Cond28,Cond29,Cond30,Cond31, Loaddate)
	select
		M.MemberID,D.State,D.City,D.countyname,D.Zipcode, M.SubscriberID , M.CmOrgRegion, M.LOB,M.Relationship, M.MVDID, D.ClaimNumber,D.StatementFromDate, 
		Code,TypeOfDiag, D.RiskGroupID,D.MemberFirstName,D.MemberLastName,D.Age,D.Sex,D.EmergencyIndicator,D.NetworkIndicator,D.AdmissionDate,
		D.DischargeDate,D.DischargeStatusCode, D.BilledAmount,D.ClaimStatus,D.FacilityTIN,D.PartyKey,CCQ.CaseId,CCQ.CaseOwner,CCQ.CaseProgram, C.FormDate,
		C.FormAuthor,C.EngagementType,C.WhoContacted, C.Disposition,
		CASE WHEN IsNUll(CT.[1],'') = ''  THEN '' ELSE 'Y' END as 'Cond1',
		CASE WHEN IsNUll(CT.[2],'') = ''  THEN '' ELSE 'Y' END as 'Cond2',
		CASE WHEN IsNUll(CT.[3],'') = ''  THEN '' ELSE 'Y' END as 'Cond3',
		CASE WHEN IsNUll(CT.[4],'') = ''  THEN '' ELSE 'Y' END as 'Cond4',
		CASE WHEN IsNUll(CT.[5],'') = ''  THEN '' ELSE 'Y' END as 'Cond5',
		CASE WHEN IsNUll(CT.[6],'') = ''  THEN '' ELSE 'Y' END as 'Cond6',
		CASE WHEN IsNUll(CT.[7],'') = ''  THEN '' ELSE 'Y' END as 'Cond7',
		CASE WHEN IsNUll(CT.[8],'') = ''  THEN '' ELSE 'Y' END as 'Cond8',
		CASE WHEN IsNUll(CT.[9],'') = ''  THEN '' ELSE 'Y' END as 'Cond9',
		CASE WHEN IsNUll(CT.[10],'') = ''  THEN '' ELSE 'Y' END as 'Cond10',
		CASE WHEN IsNUll(CT.[11],'') = ''  THEN '' ELSE 'Y' END as 'Cond11',
		CASE WHEN IsNUll(CT.[12],'') = ''  THEN '' ELSE 'Y' END as 'Cond12',
		CASE WHEN IsNUll(CT.[13],'') = ''  THEN '' ELSE 'Y' END as 'Cond13',
		CASE WHEN IsNUll(CT.[14],'') = ''  THEN '' ELSE 'Y' END as 'Cond14',
		CASE WHEN IsNUll(CT.[15],'') = ''  THEN '' ELSE 'Y' END as 'Cond15',
		CASE WHEN IsNUll(CT.[16],'') = ''  THEN '' ELSE 'Y' END as 'Cond16',
		CASE WHEN IsNUll(CT.[17],'') = ''  THEN '' ELSE 'Y' END as 'Cond17',
		CASE WHEN IsNUll(CT.[18],'') = ''  THEN '' ELSE 'Y' END as 'Cond18',
		CASE WHEN IsNUll(CT.[19],'') = ''  THEN '' ELSE 'Y' END as 'Cond19',
		CASE WHEN IsNUll(CT.[20],'') = ''  THEN '' ELSE 'Y' END as 'Cond20',
		CASE WHEN IsNUll(CT.[21],'') = ''  THEN '' ELSE 'Y' END as 'Cond21',
		CASE WHEN IsNUll(CT.[22],'') = ''  THEN '' ELSE 'Y' END as 'Cond22',
		CASE WHEN IsNUll(CT.[23],'') = ''  THEN '' ELSE 'Y' END as 'Cond23',
		CASE WHEN IsNUll(CT.[24],'') = ''  THEN '' ELSE 'Y' END as 'Cond24',
		CASE WHEN IsNUll(CT.[25],'') = ''  THEN '' ELSE 'Y' END as 'Cond25',
		CASE WHEN IsNUll(CT.[26],'') = ''  THEN '' ELSE 'Y' END as 'Cond26',
		CASE WHEN IsNUll(CT.[27],'') = ''  THEN '' ELSE 'Y' END as 'Cond27',
		CASE WHEN IsNUll(CT.[28],'') = ''  THEN '' ELSE 'Y' END as 'Cond28',
		CASE WHEN IsNUll(CT.[29],'') = ''  THEN '' ELSE 'Y' END as 'Cond29',
		CASE WHEN IsNUll(CT.[30],'') = ''  THEN '' ELSE 'Y' END as 'Cond30',
		CASE WHEN IsNUll(CT.[31],'') = ''  THEN '' ELSE 'Y' END as 'Cond31',
		@v_PBI_Loaddate
	from #mbr_diag D
	join myvitaldatalive.dbo.FinalMember M on M.MVDID = D.MVDID
	join myvitaldatalive.dbo.ComputedCareQueue CCQ on CCQ.MVDID = M.MVDID
	left join #mbr_contact C on C.MVDID = D.MVDID
	left join #mbr_crosstab CT on CT.MVDID = D.MVDID

	-- Build out data where Family of members diagnosed positive are discovered
	INSERT INTO FinalCovidMemberFamily ( MemberID, MemberFirstName, MemberLastName, Sex,Age, Relationship, 
		City, State, Zipcode,CmOrgRegion, LOB, countyname,RiskScore, EBIRisk, CaseId, FormDate, CaseOwner, CaseProgram, Loaddate )
	select MM.MemberID, MM.MemberFirstName, MM.MemberLastName, Gender, DATEDIFF(YY, DateOfBirth, GETDATE()), MM.Relationship, 
		MM.City, MM.State, MM.Zipcode,MM.CmOrgRegion, MM.LOB, MM.countyname,CCQ.RiskGroupID, MM.RiskGroupID, CCQ.CaseId, 
		cf.FormDate, CCQ.CaseOwner, CCQ.CaseProgram, @v_PBI_Loaddate 
	from FinalMember MM
	join ComputedCareQueue CCQ on CCQ.MVDID = MM.MVDID
	left join ARBCBS_Contact_Form CF on CF.MVDID = MM.MVDID
	--inner join #mbr_diag D on D.SubscriberID = MM.SubscriberID
	----and D.MVDID != MM.MVDID
	--and D.TypeOfDiag = 'ICD10'

	where SubscriberID in (
		select M.SubscriberID from #mbr_diag D
		join FinalMember M on M.MVDID = D.MVDID
		where D.TypeOfDiag = 'ICD10'
		)

	order by MemberID

	-- member positive but without contact or open case
	select M.MemberID, D.MVDID, D.MemberLastName, D.MemberFirstName, D.cmOrgRegion, max(StatementFromDate) as LatestDxDate, max(StatementFromDate) as FirstDxDate
	into #mbr_positive
	from #mbr_diag D
	left join FinalMember M on M.MVDID = D.MVDID
	where D.MVDID not in (select MVDID from #mbr_contact)
	and D.MVDID not in (select MVDID from ComputedCareQueue where IsNull(Caseid,-1) != -1)
	and D.TypeOfDiag='ICD10'
	group by M.MemberID,D.MVDID, D.MemberLastName, D.MemberFirstName, D.cmOrgRegion

	INSERT INTO FinalCovidMemberPWC( MemberID, MVDID, MemberLastName, MemberFirstName, cmOrgRegion, LOB, State, City, countyname, Sex, Age,
	LatestDxDate, FirstDxDate, Loaddate)
	select P.MemberID, P.MVDID, P.MemberLastName, P.MemberFirstName, P.cmOrgRegion, M.LOB, M.State, M.City, M.countyname, M.Gender, DATEDIFF(YY, M.DateOfBirth, GETDATE()),
	P.LatestDxDate, P.FirstDxDate,@v_PBI_Loaddate
	from #mbr_positive P
	inner join FinalMember M on M.MVDID = P.MVDID
	
	-- member negative but without contact or open case and Risk Group >= 5
	INSERT INTO FinalCovidMemberNWC(
		MemberID,State, City, countyname, Zipcode, SubscriberID ,LOB, CmOrgRegion, Relationship, MVDID, ClaimNumber,StatementFromDate, Code, 
		TypeOfDiag, RiskGroupID,MemberFirstName,MemberLastName,Age,Sex,EmergencyIndicator,NetworkIndicator,AdmissionDate,DischargeDate,
		DischargeStatusCode, BilledAmount,ClaimStatus,FacilityTIN,PartyKey,Cond1,Cond2,Cond3,Cond4,Cond5,Cond6,Cond7,Cond8,Cond9, 
	    Cond10,Cond11,Cond12,Cond13,Cond14,Cond15,Cond16,Cond17,Cond18,Cond19,Cond20,Cond21,Cond22,Cond23,Cond24,Cond25,Cond26,Cond27,
	    Cond28,Cond29,Cond30,Cond31,Loaddate)
	select distinct M.MemberID,D.State, D.City, D.countyname, D.Zipcode, M.SubscriberID ,M.LOB, M.CmOrgRegion, M.Relationship, M.MVDID, D.ClaimNumber,D.StatementFromDate, Code, 
	TypeOfDiag, D.RiskGroupID,D.MemberFirstName,D.MemberLastName,
	D.Age,D.Sex,D.EmergencyIndicator,D.NetworkIndicator,D.AdmissionDate,D.DischargeDate,D.DischargeStatusCode, D.BilledAmount,D.ClaimStatus,D.FacilityTIN,D.PartyKey,
	CASE WHEN IsNUll(CT.[1],'') = ''  THEN '' ELSE 'Y' END as '1',
	CASE WHEN IsNUll(CT.[2],'') = ''  THEN '' ELSE 'Y' END as '2',
	CASE WHEN IsNUll(CT.[3],'') = ''  THEN '' ELSE 'Y' END as '3',
	CASE WHEN IsNUll(CT.[4],'') = ''  THEN '' ELSE 'Y' END as '4',
	CASE WHEN IsNUll(CT.[5],'') = ''  THEN '' ELSE 'Y' END as '5',
	CASE WHEN IsNUll(CT.[6],'') = ''  THEN '' ELSE 'Y' END as '6',
	CASE WHEN IsNUll(CT.[7],'') = ''  THEN '' ELSE 'Y' END as '7',
	CASE WHEN IsNUll(CT.[8],'') = ''  THEN '' ELSE 'Y' END as '8',
	CASE WHEN IsNUll(CT.[9],'') = ''  THEN '' ELSE 'Y' END as '9',
	CASE WHEN IsNUll(CT.[10],'') = ''  THEN '' ELSE 'Y' END as '10',
	CASE WHEN IsNUll(CT.[11],'') = ''  THEN '' ELSE 'Y' END as '11',
	CASE WHEN IsNUll(CT.[12],'') = ''  THEN '' ELSE 'Y' END as '12',
	CASE WHEN IsNUll(CT.[13],'') = ''  THEN '' ELSE 'Y' END as '13',
	CASE WHEN IsNUll(CT.[14],'') = ''  THEN '' ELSE 'Y' END as '14',
	CASE WHEN IsNUll(CT.[15],'') = ''  THEN '' ELSE 'Y' END as '15',
	CASE WHEN IsNUll(CT.[16],'') = ''  THEN '' ELSE 'Y' END as '16',
	CASE WHEN IsNUll(CT.[17],'') = ''  THEN '' ELSE 'Y' END as '17',
	CASE WHEN IsNUll(CT.[18],'') = ''  THEN '' ELSE 'Y' END as '18',
	CASE WHEN IsNUll(CT.[19],'') = ''  THEN '' ELSE 'Y' END as '19',
	CASE WHEN IsNUll(CT.[20],'') = ''  THEN '' ELSE 'Y' END as '20',
	CASE WHEN IsNUll(CT.[21],'') = ''  THEN '' ELSE 'Y' END as '21',
	CASE WHEN IsNUll(CT.[22],'') = ''  THEN '' ELSE 'Y' END as '22',
	CASE WHEN IsNUll(CT.[23],'') = ''  THEN '' ELSE 'Y' END as '23',
	CASE WHEN IsNUll(CT.[24],'') = ''  THEN '' ELSE 'Y' END as '24',
	CASE WHEN IsNUll(CT.[25],'') = ''  THEN '' ELSE 'Y' END as '25',
	CASE WHEN IsNUll(CT.[26],'') = ''  THEN '' ELSE 'Y' END as '26',
	CASE WHEN IsNUll(CT.[27],'') = ''  THEN '' ELSE 'Y' END as '27',
	CASE WHEN IsNUll(CT.[28],'') = ''  THEN '' ELSE 'Y' END as '28',
	CASE WHEN IsNUll(CT.[29],'') = ''  THEN '' ELSE 'Y' END as '29',
	CASE WHEN IsNUll(CT.[30],'') = ''  THEN '' ELSE 'Y' END as '30',
	CASE WHEN IsNUll(CT.[31],'') = ''  THEN '' ELSE 'Y' END as '31',
	@v_PBI_Loaddate
	from #mbr_diag D
	join FinalMember M on M.MVDID = D.MVDID
	join ComputedCareQueue CCQ on CCQ.MVDID = M.MVDID
	left join #mbr_contact C on C.MVDID = D.MVDID
	left join #mbr_crosstab CT on CT.MVDID = D.MVDID
	where D.MVDID not in (select MVDID from #mbr_contact)
	and D.MVDID not in (select MVDID from #mbr_positive )
	and D.MVDID not in (select MVDID from ComputedCareQueue where IsNull(Caseid,-1) != -1)
	and D.RiskGroupID >= 5

END