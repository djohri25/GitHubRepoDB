/****** Object:  Procedure [dbo].[Rpt_MemberDiseaseCondition_DrLink]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberDiseaseCondition_DrLink]

@IceNumber varchar(15)
As

BEGIN
Declare @ICEGroup varchar(50),@cust_id int
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup


select @cust_id = cust_id from Link_MVDID_CustID lc
                   where lc.MVDId = @ICENUMBER

SELECT 
	distinct ReportDate as YearDate,
	CASE ISNULL(OtherName,'')
		WHEN '' THEN 
		(
			SELECT a.ConditionName FROM dbo.LookupCondition a WHERE a.ConditionId = b.ConditionId	
		)
		ELSE 
		(
			OtherName
		)
	END AS ConditionName,
	dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,
	dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,
	dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,
	dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,
	dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact
FROM dbo.MainCondition b
WHERE --ICENUMBER = @IceNumber
ICENUMBER in (Select IceNUmber From #IceNumbers) and  not EXISTS (SELECT * FROM Lookup_AbuseDiagnoses lA WHERE RTRIM(LTRIM(lA.ICD_Cd)) =  REPLACE(b.code, '.', '')  and  @cust_id = '11') 
order by ReportDate desc

END