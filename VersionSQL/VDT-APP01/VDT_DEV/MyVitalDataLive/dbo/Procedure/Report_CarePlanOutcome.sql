/****** Object:  Procedure [dbo].[Report_CarePlanOutcome]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-22
 Description:	Generate data for ABCBS report 
				called Care Plan Outcome Report
 Ticket:		4188

Modified		Modified By		Details
20201223		Jose Pons		Enable CompanyKey and CompanyName search using @CompanyKey
05/13/2021		Bhupinder Singh	Ticket 4188 - Added new columns as per requirements excel 4/1 in ticket
07/22/2021		Bhupinder Singh Ticket 5723 - Added new PlanType column

[dbo].[Report_CarePlanOutcome] '04/13/2021','05/13/2021',1,0,'ALL','ALL',
--'ABB,ABCBS,ARSTATEPOLICE,ASEPSE,BARB_EAST,BARB_WEST,BRYCE,EXCHNG,FEP,HA,HAEXCHNG,JBHUNT,SIMMONS_BANK,TYSON,USAA,USAM,WALMART',
				'ALL','Case Management,Chronic Condition Management,Clinical Support,Maternity,Social Work', 'ALL'
				'aagaither,acwhitten,acyates,adarmstrong,adcleveland,ADHope,adrider,ADWelch,aerorex,AETACKER,agjones,ajcombs,akheringer,alanderson,alholland,ALJEFFREY,alkennedy,almaggard,alwilson,amearnest,amgann,ampruitt,Amy Rorex,ancummings,anlacefield,arhumphries,arlisko,asarmstrong,asfranck,aswilliams,axgreene,axwalker,barobinson,bbcowling,BDTIPTON,behillenburg,bgwingerter,BJPATTERSON,blpowell,BLYandell,bnghent,bnvardaman,brittany ghent,CAFURLOW,cahansen,cajordan,camain,carobertson,caspradlin,castallings,castracener,cbmoore,CCSTANFIELD,cdthompson1,cejones,cfwilson,chhenry,CJACHORN,cjcorbell,cjgammel,cjlawson,clbateman,clciak,clflowers,clgoodner,cloregon,clrainey,CLSHUMAKER,cmallen,CMHartung,cncarter,csgott,cxponce,cxromes,DAHURST,DBDAVASHER,dcmorgan,DDHODGES,dgraine,DGSPANN,DJPOYNOR,dkbates,dlgooch,dlmartin,dmhill,drbradshaw,drcooper,ebrook,ensharp,enwilkerson,epgarner,executive1,eywestmoreland,flblasengame,FMPAGAN,GDASHCRAFT,gloaks,GMLEWIS,gncoven,GSFaircloth,hkashcraft,hlgoff,hlpenny,hnlarson,JACHAPPELL,jahigh,jamaxwell,jamayher,jataylor,jathomas,jbmills,jcrichardson,JDIrby,jdkirby,JDWALLACE,jerobertson,JGWHALEY,jkblount,JLALDERMAN,JLARCHER-OSWALT,JLARCHEROSWALT,jlhowland1,jlpurtle,JLRega,jlspears,JLWALKER,jmbillins,jmblevins,jmgriffith,jmrowland,jmsimons,John Blount,jowhite,jpallen,JPWARD,JRCOOK,jstimmons,jxblack,jxthurston,kahardman,KAHARRIS,KAJACKSON,KAKELLOGG,kareed,kegoodson,keharper,KEROARK,kewloszczynski,khbyrd,kjfranke,KJMulhollen,kkball,kkmcdonald,klbuckley,kldavenport,klevans,klhankins,kmgray,KMHENDON,kmholmescrockett,KMKOONCE,kmlittleton,knbarnett,knhernandez,knjohnson,knmcjunkins,krbooth,KRCHESHIER,KSMCKAIG,KSRANNEY,LALARKER,LALUCAS,LAMILLARD,LAShort,lataylor,lcroberson,lcstobaugh,LDKENDRIX,LDMAY,leadams,lemartin,lesheets,lggaertner,lkwhelchel,LLCHELLBERG,lljohnson,llpistole,llramsey,lmaugustine,lmdunn,lnpettit,lrsheridan,MALOCKWOOD,masmith,mastormes,mbchristian,mbshepherd,mcclements,mcedwards,MCMinor,mdheath,mdwallen,MEAULT,MJSULLENGERCABLE,MKCROW,mkduren,mkgolden,mkmichael,mlboren,mllee,MLLEWIS,mlrogers,MLTubbs,mmgermer,mngay,mrairhart,MRCALLAHAN,mrsmith,MXBELLAMY,MXYOUNG,nbmorgan,nchay,NDRICKMAN,nkcypert,NKPETTY,nlarnold,nlbolin,nlpettit,OACARPENTER,okallen,orbowman,pafincher,pahastings,palambert,pdblount,pdclayborn,PESCOTT,pjfisher,pkmartin,plwright,pmabshure,psmutchek,RASims,rathornton,RDNIX,RDTatum,Rick Moore,RLCOOK,rlhill,RNMOORE,rrloggains,rrmartin,RRRILEY,rschance,RVHINOJOSA,rxhughes,SAJOHNSON,samorgan,sarobinson,SBHuddleston,scpowell,scwilliams,sdadcock,sdfrazier,SDWRIGHT,SHTYSON,SKJimmerson,SKNORTHCUTT,skplummer,slcostello,slfluker,slgoines,sllove,SLMOTT,SLREED,SLYORK,smbradford,SMKORDSMEIER,SNFreire,snparker,sphodges,SRGREEN,srhill,SRLEACH,SSLAFEVER,sxwiess,TEGRAVETT,tgbridges,TL Spires, RN,TLBONEE,tlbrothers,tlclark,TLKIDD,tlking1,TLPUCKETT,tlspires,TMBUTLER,TNTEAGUE,Tonya Puckett,Tracy Spires, RN,trallen,trgoodwin,trhorton,trmorgan,TSSMITH1,vawilliams,vgkimbrough,vlbarnett,VLQUICK,vlsloan,WAARTIS,Wanda Bailey BS RN CCM CCP,wmfleming,WRBAILEY,wvcarr'

*/

CREATE PROCEDURE [dbo].[Report_CarePlanOutcome]
@StartDate			date,
@EndDate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL'
AS
BEGIN


----For testing purposes
--Declare
--	@StartDate			date,
--	@EndDate			date,
--	@YTD				bit,
--	@OnlyAuditable		bit = 0,
--	@LOB				varchar(MAX),
--	@CmOrgRegion		varchar(MAX),
--	@CompanyKey			varchar(MAX),
--	@CaseProgram		varchar(MAX),
--	@CaseManager		varchar(MAX) 

--Select
--	@StartDate			= '20200101',
--	@EndDate			= '20201231',
--	@YTD				= 0,
--	@OnlyAuditable		= 0,
--	@LOB				= 'ALL',
--	@CmOrgRegion		= 'ALL',
--	@CompanyKey			= 'ALL',
--	@CaseProgram		= 'ALL',
--	@CaseManager		= 'ALL'

	if (@YTD = 1)
	begin
		set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	end

	
	drop table if exists #cases

	select distinct 
		mmf.[MVDID], 
		mmf.[CaseID],
		mmf.[q4CaseProgram],
		mmf.[q1CaseOwner],
		mmf.[q1CaseCreateDate],
		mmf.[q1CaseCloseDate],
		mmf.[CarePlanID],
		ccq.[MemberID],
		ccq.[FirstName],
		ccq.[LastName],
		ccq.[LOB],
		ccq.[CMOrgRegion],
		ccq.[CompanyName],
		mmf.q2ConsentDate,
		mmf.q5CaseCategory,
		mmf.q5CaseType, mmf.q5CaseType1, mmf.q5CaseType2,
		mmf.qCaseLevel,
		--# of calendar days since the Consent Date at the date/time the report is retrieved
		DATEDIFF(DAY, mmf.q2ConsentDate, GETDATE()) CaseAge,
		CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
				WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
				WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
				WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
				WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
				WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
				WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
				WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
		ELSE NULL 
		END  AS PlanType
	into 
		#cases
	from 
		dbo.[ABCBS_MemberManagement_Form] mmf
		--logic to get active forms
		inner join dbo.[ABCBS_MMFHistory_Form] mmf_hist 
			on mmf_hist.[OriginalFormID] = mmf.[ID]
		inner join dbo.[HPAlertNote] hlan 
			on hlan.[LinkedFormID] = mmf_hist.[OriginalFormID] 
			and hlan.[LinkedFormType] = 'ABCBS_MMFHistory' 
			and	ISNULL(hlan.[IsDelete],0) != 1
		inner join dbo.[ComputedCareQueue] ccq 
			on ccq.[MVDID] = MMF.[MVDID]
		LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
			ON mmf.MVDID = IH.MVDID 
			AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
			and IsNull(IH.SpanVoidInd,'N') != 'Y'
			And MemberEffectiveDate Between @startDate AND @endDate
	where 
		mmf.[q1CaseCreateDate] between @startdate and @enddate
		and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
		and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
		and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[q4CaseProgram], @CaseProgram) > 0))
		and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.[q1CaseOwner], @CaseManager) > 0))
		and IsNull(mmf.[q2CloseReason],'--') != 'Void'
		and ((@CompanyKey = 'ALL') 
			or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
				or ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))


	;with [cteCases] AS (
	select 
		[MVDID],
		[q4CaseProgram],
		[CarePlanID]
	from 
		#cases
	group by 
		[MVDID],
		[q4CaseProgram],
		[CarePlanID]
	),
	[cteCPMO] as (
	select 
		cpi.[MVDID],
		cpi.[CarePlanType],
		cpo.[Status],			--Status: 0. Incomplete/ 1. Completed/ 2. Pending
		cpi.ActivatedDate,
		cpi.CarePlanId
	from
		dbo.[MainCarePlanMemberIndex] cpi
		inner join [cteCases] c
			on cpi.[MVDID] = c.[MVDID] and cpi.[CarePlanType] = c.[q4CaseProgram] and cpi.[CarePlanID] = c.[CarePlanID]
		inner join dbo.[MainCarePlanMemberProblems] cpp
			on cpi.[CarePlanID] = cpp.[CarePlanID]
		inner join dbo.[MainCarePlanMemberOutcomes] cpo
			on cpp.[ID] = cpo.[ProblemID]
	--where c.MVDID = '1681F71AB4C03BE719EF'
	) 
	,[cteCPMOCount] as (
	select 
		[MVDID],
		[CarePlanType],
		sum(case when [Status] = 0 then 1 else 0 end )		[CaseIncompleted],
		sum(case when [Status] = 1 then 1 else 0 end )		[CaseCompleted],
		sum(case when [Status] > 1 then 1 else 0 end )		[CasePending],
		ActivatedDate,
		CarePlanId
	from
		[cteCPMO]
	--where MVDID = '1600BBF9F452CB667C56'
	group by
		[MVDID],
		[CarePlanType],
		ActivatedDate,
		CarePlanId
	)

	select 
		c.[CaseID], 
		c.[MemberID],
		c.[FirstName],
		c.[LastName],
		IsNull(c.[q4CaseProgram],'n/a')						[CaseProgram], 
		c.q5CaseCategory CaseCategory,
		c.q5CaseType CaseType,
		c.qCaseLevel CaseLevel,
		c.[q1CaseOwner]										[CaseManager], 
		c.q2ConsentDate ConsentDate,
		c.[q1CaseCreateDate]								[CaseOpenedDate],
		c.CaseAge,
		a.ActivatedDate,
		(a.[CaseCompleted]+a.[CaseIncompleted]+a.[CasePending]) TotalOutcomes,
		a.[CaseCompleted],
		a.[CaseIncompleted],
		a.[CasePending],

		c.[q1CaseCloseDate]									[CaseClosedDate],
		c.[LOB],
		c.[CmOrgRegion],
		c.[CompanyName],
		c.PlanType
	from #cases c
		left join [cteCPMOCount] a 
			on c.[MVDID] = a.[MVDID] and c.[q4CaseProgram] = a.[CarePlanType] and c.CarePlanId = a.CarePlanId
	--where c.MVDID = '16698AC1849E192D2CDD'
	order by 
		c.[q4CaseProgram], 
		c.[q1CaseOwner], 
		c.[q1CaseCreateDate] DESC--4942
END