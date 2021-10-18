/****** Object:  Procedure [dbo].[Get_MMOFormOwner]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[Get_MMOFormOwner]
(	@CM_ORG_REGION varchar(8000)=null,
	@CompanyKey Varchar(100)=null,
	@CompanyName Varchar(1000)=null
)
AS
/*
Created by : Sunil Nokku
Created on : 11/25/2020

Modified		Modified Date			Description
Sunil			2021-07-27				Use temp tables for CmOrgRegion.
										Use ComputedCareQueue table.

exec Get_MMOFormOwner 
@CM_ORG_REGION='ABB,ABCBS,ARSTATEPOLICE,ASEPSE,BARB_EAST,BARB_WEST,BRYCE,EXCHNG,FEP,HA,HAEXCHNG,JBHUNT,MEDICAREADV,SIMMONS_BANK,TYSON,USAA,USAM,WALMART',
@CompanyKey='11753',
@CompanyName='WALMART'

exec Get_MMOFormOwner
@CM_ORG_REGION='ABB,ABCBS,ARSTATEPOLICE,ASEPSE,BARB_EAST,BARB_WEST,BRYCE,EXCHNG,FEP,HA,HAEXCHNG,JBHUNT,MEDICAREADV,SIMMONS_BANK,TYSON,USAA,USAM,WALMART',
@CompanyKey='2965',
@CompanyName='ARKANSAS CHILDREN''S HOSPITAL'


*/

BEGIN

SET NOCOUNT ON;

	DECLARE @v_CM_ORG_REGION varchar(8000) = null,
			@v_CompanyKey Varchar(100)=null,
			@v_CompanyName Varchar(1000)=null

	SET @v_CM_ORG_REGION = @CM_ORG_REGION
	SET @v_CompanyKey = @CompanyKey
	--SET @v_CompanyName = Replace(@CompanyName,'''','')
	SET @v_CompanyName = @CompanyName
	print @v_CompanyName
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

	SELECT DISTINCT mmo.FormAuthor
	FROM abcbs_monthlymemberoverview_form mmo
		INNER JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = mmo.MVDID
		AND ccq.CompanyName = @v_CompanyName
		AND ccq.CompanyKey = @v_CompanyKey
	INNER JOIN #EnumeratedCMOrgRegion cmor ON cmor.CmOrgRegionValue = ccq.CMOrgRegion

/*	SELECT DISTINCT mmo.FormAuthor
	FROM abcbs_monthlymemberoverview_form mmo
	INNER JOIN FinalMember fm ON fm.MVDID = mmo.MVDID
	INNER JOIN dbo.LookupCompanyName C ON fm.CompanyKey=C.company_key
	WHERE fm.CMORGRegion IN (SELECT VALUE FROM dbo.SplitStringVal(@v_CM_ORG_REGION,','))
	AND fm.CompanyKey = @v_CompanyKey
	AND C.Company_Name = @v_CompanyName */

END