/****** Object:  Procedure [dbo].[Rpt_MemberDiseaseCondition]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberDiseaseCondition]  
 @IceNumber VARCHAR(30)  
AS  

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 06/26/2019
-- Description: Get List of Conditions identified from the Claims for each member
-- Exec dbo.Rpt_MemberDiseaseCondition '16138198191D585902'
-- Notes:
-- Query straight from Final Tables
-- =============================================

SET NOCOUNT ON
  
Begin

Select 
(a.StatementFromDate) as YearDate
,c.ShortDesc as ConditionName
,dbo.fnInitCap(IsNULL(d.ProviderFirstName,'')) + ' ' + dbo.fnInitCap(IsNULL(d.ProviderLastName,'')) as CreatedBy
,dbo.fnInitCap(IsNULL(d.BusinessName,'')) as CreatedByOrganization
,dbo.fnInitCap(IsNULL(d.ProviderFirstName,'')) + ' ' + dbo.fnInitCap(IsNULL(d.ProviderLastName,'')) as UpdatedBy
,dbo.fnInitCap(IsNULL(d.BusinessName,'')) as UpdatedByOrganization
,dbo.fnInitCap(IsNULL(d.ServicePhone,'')) as UpdatedByContact
From dbo.FinalClaimsHeader a 
inner join dbo.FinalClaimsHeaderCode b on a.ClaimNumber=b.ClaimNumber
left join dbo.LookupICD9 c on b.CodeValue= c.CodeNoPeriod
outer apply (Select Top 1 * From FinalProvider de where a.RenderingProviderNPI=de.NPI Order by AffiliationEffectiveDate desc) d
Where b.CodeType='DIAG'
and a.MVDID = @IceNumber
Group by  a.StatementFromDate, c.ShortDesc, a.RenderingProviderNPI, d.ProviderFirstName, d.ProviderLastName, d.BusinessName, d.ProviderType, d.ServicePhone
Order by  (a.StatementFromDate) desc


End