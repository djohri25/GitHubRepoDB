/****** Object:  Function [dbo].[fnMemberProcedureHistory]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE Function [dbo].[fnMemberProcedureHistory]
 (	@ICENUMBER	VARCHAR(30))
 RETURNS	@result  TABLE (
 
 	[MVDID] [varchar](30) NULL,
	[YearDate] [date] NULL,
	[Condition] [int] NULL,
	[Treatment] [varchar](1000) NULL,
	[code] [nvarchar](10) NOT NULL,
	[CodingSystem] [varchar](5) NOT NULL,
	[HVID] [int] NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NOT NULL,
	[HVFlag] [int] NOT NULL,
	[ReadOnly] [int] NOT NULL,
	[ServiceProviderNPI] [varchar](12) NULL,
	[RevenueCode] [varchar](5) NULL,
	[BillType] [varchar](4) NULL,
	[PlaceOfService] [varchar](2) NULL,
	[DRGCode] [varchar](3) NULL,
	[DischargeStatusCode] [varchar](2) NULL,
	[AdmissionDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[Mod1] [varchar](2) NULL,
	[Mod2] [varchar](2) NULL,
	[CreatedBy] [nvarchar](4000) NULL,
	[CreatedByOrganization] [nvarchar](4000) NULL,
	[UpdatedBy] [nvarchar](4000) NULL,
	[UpdatedByOrganization] [nvarchar](4000) NULL,
	[UpdatedByContact] [nvarchar](4000) NULL,
	[CreatedByNPI] [int] NULL,
	[UpdatedbyNPI] [int] NULL
 
 
 
 )
 AS 
 BEGIN

 INSERT INTO @result
Select x.*
,dbo.fnInitCap(IsNULL(d.ProviderFirstName,'')) + ' ' + dbo.fnInitCap(IsNULL(d.ProviderLastName,'')) as CreatedBy
,dbo.fnInitCap(IsNULL(d.BusinessName,'')) as CreatedByOrganization
,dbo.fnInitCap(IsNULL(d.ProviderFirstName,'')) + ' ' + dbo.fnInitCap(IsNULL(d.ProviderLastName,'')) as UpdatedBy
,dbo.fnInitCap(IsNULL(d.BusinessName,'')) as UpdatedByOrganization
,dbo.fnInitCap(IsNULL(d.ServicePhone,'')) as UpdatedByContact
,NULL as CreatedByNPI
,d.NPI as UpdatedbyNPI

From(
Select a.MVDID, ServiceFromDate as YearDate, NULL as Condition,dbo.fnRemoveExtraSpaces(LTrim(RTrim(IsNULL(b.Description1,'')+' '+IsNULL(b.Description2,'')))) as Treatment, b.code, 'CPT' as CodingSystem, NULL as HVID, GETUTCDATE() as CreationDate, GETUTCDATE() as ModifyDate, 0 as HVFlag, 0 as ReadOnly, a.ServiceProviderNPI, RevenueCode, BillType, a.PlaceOfService, DRGCode, DischargeStatusCode, AdmissionDate, DischargeDate, Mod1, Mod2
From dbo.FinalClaimsDetail a join dbo.LookUpCPT b on a.ProcedureCode = b.Code
Join dbo.FinalClaimsHeader c on a.ClaimNumber=c.ClaimNumber
Where a.MVDID = @ICENUMBER
Union
Select a.MVDID, ServiceFromDate as YearDate, NULL as Condition, dbo.fnRemoveExtraSpaces(LTrim(RTrim(IsNULL(b.AbbreviatedDescription,'')))) as Treatment, b.code, 'HCPCS' as CodingSystem, NULL as HVID, GETUTCDATE() as CreationDate, GETUTCDATE() as ModifyDate, 0 as HVFlag, 0 as ReadOnly, a.ServiceProviderNPI, RevenueCode, BillType, a.PlaceOfService, DRGCode, DischargeStatusCode, AdmissionDate, DischargeDate, Mod1, Mod2
From dbo.FinalClaimsDetail a join dbo.LookupHCPCS b on a.ProcedureCode = b.Code
Join dbo.FinalClaimsHeader c on a.ClaimNumber=c.ClaimNumber
Where a.MVDID = @ICENUMBER) x 
outer apply (Select Top 1 * From dbo.FinalProvider de where x.ServiceProviderNPI=de.NPI Order by AffiliationEffectiveDate desc) d
Order by YearDate Desc

 return
 END