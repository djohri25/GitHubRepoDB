/****** Object:  Procedure [dbo].[Get_MMOMemberID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MMOMemberID]
(	@CM_ORG_REGION varchar(8000)=null,
	@CompanyKey Varchar(100)=null,
	@CompanyName Varchar(1000)=null,
	@FormOwner varchar(8000)=null
)
AS
/*
Created by : Sunil Nokku
Created on : 11/25/2020

Modified		Modified Date			Description
Ed,Sunil		2021-07-27				Use temp tables for CmOrgRegion and FormOwner.
										Use ComputedCareQueue table.

EXEC Get_MMOMemberID 'WALMART','11753','WALMART','acyates,adcleveland,ADHope,adrider,agjones,alanderson,alholland,ambryant,ancummings,anlacefield,arlisko,asarmstrong,bgwingerter,blpowell,cahansen,cajordan,camain,castracener,cjcorbell,clbateman,clciak,clflowers,clgoodner,cncarter,cxromes,dlmartin,ebrook,enwilkerson,epgarner,flblasengame,gloaks,hlgoff,hnlarson,jahigh,jamayher,jataylor,jcrichardson,jehughes,jlpurtle,jlspears,jmblevins,jmgriffith,jmrowland,jowhite,jxthurston,kahardman,KAKELLOGG,kegoodson,kewloszczynski,kjmoss,klclark,kldavenport,klhankins,kllamb,knbarnett,knmcjunkins,LALUCAS,lcroberson,lcstobaugh,lgfisher,ljmcearl,LLCHELLBERG,lmdunn,lnpettit,lrsheridan,MALOCKWOOD,mbchristian,mbshepherd,mcclements,mcedwards,mdheath,mdwallen,mjlejeune,mkmichael,mlrogers,mmgermer,mngay,mrairhart,OACARPENTER,okallen,orbowman,pafincher,palambert,pdclayborn,pjfisher,psmutchek,rschance,saschefe,scpowell,SCRUSSELL,sdadcock,SDWRIGHT,SHTYSON,sllove,snparker,srhill,tlbrothers,tmcameron,trallen,trmorgan,vawilliams,vlbarnett,wvcarr'
*/
BEGIN

SET NOCOUNT ON;

	DECLARE @v_CM_ORG_REGION varchar(8000) = null,
			@v_CompanyKey Varchar(100)=null,
			@v_CompanyName Varchar(1000)=null,
			@v_FormOwner varchar(8000)=null,
			@v_num_cm_org_region int,
			@v_num_form_owner int;

	SET @v_CM_ORG_REGION = @CM_ORG_REGION
	SET @v_CompanyKey = @CompanyKey
	--SET @v_CompanyName = Replace(@CompanyName,'''','')
	SET @v_CompanyName = @CompanyName
	SET @v_FormOwner = @FormOwner

	DROP TABLE IF EXISTS #EnumeratedCMOrgRegion;
	CREATE TABLE #EnumeratedCMOrgRegion	(CmOrgRegionValue varchar(8000));
	INSERT INTO #EnumeratedCMOrgRegion (CmOrgRegionValue)
	SELECT
	Value
	FROM
	STRING_SPLIT( @v_CM_ORG_REGION, ',' )
	WHERE
	@v_CM_ORG_REGION IS NOT NULL
	AND @v_CM_ORG_REGION != 'ALL';

	DROP TABLE IF EXISTS #EnumeratedFormOwner;
	CREATE TABLE #EnumeratedFormOwner (FormOwnerValue varchar(8000));
	INSERT INTO	#EnumeratedFormOwner (FormOwnerValue)
	SELECT
	Value
	FROM
	STRING_SPLIT( @v_FormOwner, ',' )
	WHERE
	@v_FormOwner IS NOT NULL
	AND @v_FormOwner != 'ALL';

	SELECT DISTINCT ccq.MemberID
	FROM abcbs_monthlymemberoverview_form mmo
	INNER JOIN #EnumeratedFormOwner fo ON fo.FormOwnerValue = mmo.FormAuthor
	INNER JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = mmo.MVDID
		AND ccq.CompanyName = @v_CompanyName
		AND ccq.CompanyKey = @v_CompanyKey
	INNER JOIN #EnumeratedCMOrgRegion cmor ON cmor.CmOrgRegionValue = ccq.CMOrgRegion
/*
	INNER JOIN FinalMember fm ON fm.MVDID = mmo.MVDID
		AND fm.CompanyKey = @v_CompanyKey
	INNER JOIN dbo.LookupCompanyName C ON fm.CompanyKey=C.company_key
		AND C.Company_Name = @v_CompanyName
	INNER JOIN #EnumeratedCMOrgRegion cmor ON cmor.Value = fm.CMOrgRegion
	INNER JOIN #EnumeratedFormOwner fo ON fo.Value = mmo.FormAuthor;
*/

END