/****** Object:  Procedure [dbo].[uspCFR_A03_MA_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_A03_MA_MVDID] 
AS
/*

	CustID:			16
	RuleID:			283
	ProductID:		2
	OwnerGroup:		171

Modifications:
WHO			WHEN		WHAT
Mike		2021-03-03	New rule, looking at HIE messages on .135.
Mike		2021-03-04	Client requested changes (email) lookback from YTD to 3 days; allow Grand Rounds

exec uspCFR_A03_MA_MVDID

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_A03_MA_MVDID', @CustID=16, @RuleID = 283, @ProductID=2, @OwnerGroup = 171

*/
BEGIN

SET NOCOUNT ON;

--insert into CareFlowTask (  [MVDID]  ,[RuleId]  ,[CreatedDate]  ,[CreatedBy]  ,[ProductId]  ,[CustomerId]  ,[StatusId]  ,[OwnerGroup]  ,[ExpirationDate]  )  
select distinct MVDID   
		--,283  
		--,GetDate()  
		--,'WORKFLOW'  
		--,2  
		--,16  
		--,278  
		--,171  
		--,'99991231'  
from (
	-- member is active (a)
	-- has no case manager (b)
	-- no personal harm (i)
	-- high cost per group (AC2)
	select CCQ.MVDID
	from ComputedCareQueue CCQ
	join [VD-RPT02].[BatchImportABCBS].[dbo].FinalHL7 HL7 on HL7.MVDID = CCQ.MVDID
	join FinalEligibility FE on FE.MVDID = HL7.MVDID
	join FinalMember FM on FM.MVDID = CCQ.MVDID
	left join ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
	where CCQ.IsActive = 1 
	and HL7.MsgType like '%A03%'
	and FE.LOB = 'MA'
	and FE.MemberEffectiveDate <= GetDate() and IsNull(FE.MemberTerminationDate,'9999-12-31') >= GetDate()
	and FE.PlanIdentifier != 'H4213'
	and HL7.MsgSender in (
		'Arkansas Childrens Hospital',
		'Baptist Health Rehab North Little Rock',
		'Baptist Health Rehab-Conway',
		'Baptist Health Rehabilitation Institute',
		'Baxter Regional Medical Center',
		'CHI St Vincent Hot Springs Hospital',
		'CHI St Vincent Infirmary',
		'CHI St Vincent Medical Center North',
		'CHI St Vincent Morrilton',
		'CHSFayetteville',
		'CHSSiloamSprings',
		'Conway Regional Medical Center',
		'CRIT',
		'DeWitt Hospital',
		'Eureka Springs IP',
		'Eureka Springs OP',
		'Howard Memorial Hospital',
		'Jefferson Regional Medical Center',
		'Medical Center of South Arkansas El Dorado',
		'Mena Regional Health System',
		'Mercy Hospital Rogers',
		'Missouri Health Connection',
		'MYHEALTH MyHealth Access Oklahoma HIE',
		'National Park Medical Center',
		'North Arkansas Regional Medical Center',
		'Northwest Arkansas Neuroscience Institute',
		'Northwest Medical Center Bentonville',
		'Northwest Medical Center Springdale',
		'Ozark Health Medical Center',
		'Regency Health Springdale',
		'Saline Memorial Hospital',
		'St Bernards Medical Center',
		'St Marys Regional Medical Center',
		'Stone County Medical Center',
		'Unity Health Harris Medical Center',
		'Unity Health White County Medical Center',
		'University of Arkansas For Medical Sciences',
		'Washington Regional Medical Center',
		'White River Medical Center'
	)
	AND DATEDIFF(Day,HL7.MsgDate,GetDate()) < 10 -- HL7.MsgDate > '2020-12-31'
	and IsNull(FM.COBCD,'U') in ('S','N','U')
	and IsNull(FM.CompanyKey,'0000') != '1338'
	and IsNull(CCQ.CaseOwner,'--') = '--'
	and IsNull(CA.PersonalHarm,0) = 0
	-- and IsNull(FM.GrpInitvCd,'n/a') != 'GRD'
	and CCQ.LOB='MA'
	and not exists ( 
		select distinct MVDID from
		(
			-- active member management form (c)
	-- for specific program types
			select MVDID, 'Active' as Rsn 
			from ABCBS_MemberManagement_Form MMF
			where MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			and IsNull(MMF.SectionCompleted,9) < 3
			UNION
		
			-- denial in last 120 days (d)
	-- for specific program types
			select distinct MVDID, 'Refused' as Rsn 
			from ABCBS_MemberManagement_Form MMF
			where MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			and (
				MMF.qNonViableReason1 = 'member/family refused case management' 
				or MMF.q2ConsentNonViable = 'member/family refused case management' 
				or MMF.qNoReason = 'member/family refused case management'
				or MMF.q8 = 'member/family refused case management'
				or MMF.q2CloseReason = 'member/family refused case management'
				-- 
				or MMF.qNonViableReason1 = 'no CM needs' 
				or MMF.q2ConsentNonViable = 'no CM needs' 
				or MMF.qNoReason = 'no CM needs'
				or MMF.q8 = 'no CM needs'
			)
			and DateDiff(day,MMF.FormDate, GetDate()) < 121
			UNION
		
			-- UTR in last 120 days (e)
	-- for specific program types
			select distinct MVDID, 'UTR' as Rsn 
			from ABCBS_MemberManagement_Form MMF
			where MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			and (
				MMF.qNonViableReason1 = 'unable to reach member' 
				or MMF.q2ConsentNonViable = 'unable to reach member' 
				or MMF.qNoReason = 'unable to reach member'
				or MMF.q8 = 'unable to reach member'
			)
			and DateDiff(day,MMF.FormDate, GetDate()) < 121
			UNION
		
			-- member expired
			select distinct MVDID, 'Expired' as Rsn 
			from ABCBS_MemberManagement_Form MMF
			where (
				MMF.qNonViableReason1 = 'member expired' 
				or MMF.q2ConsentNonViable = 'member expired' 
				or MMF.qNoReason = 'member expired'
				or MMF.q8 = 'member expired'
				or MMF.q2CloseReason = 'member expired'
			)
			-- or valid date of death -- not captured on MMF
			UNION
		
			-- contact in last 120 days
			select distinct MVDID , 'Contact' as Rsn
			from ARBCBS_Contact_Form CF
			where DateDiff(day,CF.q1ContactDate, GetDate()) < 121
			and q4ContactType in ('Member','Caregiver')
			and q7ContactSuccess = 'Yes'
			and q2program in ('Case Management','Specialty Care','Maternity')
		) a where MVDID = CCQ.MVDID
	)) B

END