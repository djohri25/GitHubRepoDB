/****** Object:  Procedure [dbo].[Rpt_MemberSpecialists]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberSpecialists]  
 @ICENUMBER varchar(30)  
AS  

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 06/26/2019
-- Description: Get the List of Providers seen by Member.
-- Exec dbo.Rpt_MemberSpecialists '161364597FA6B'
-- Notes:
-- Query Straight from Final Tables. If there is performance issue, use computed tables.
--
-- Mike	03-16-2021	Add cast to PCPNPI in response to TFS 4874
-- =============================================

-- Get Latest Eligibility Info with PCP
Select a.MVDID, CAST(a.PCPNPI as varchar(15)) as NPI, 1 as RoleID
Into #PCPNPI
From dbo.vwRecentMemberEligibility a
Where CAST( a.PCPNPI as varchar(15)) is not null and a.MVDID = @ICENUMBER

Select MVDID, RenderingProviderNPI as NPI, 6 as RoleID
Into #ClaimsNPI
From dbo.FinalClaimsHeader a
Where a.RenderingProviderNPI is not null and a.MVDID = @ICENUMBER
and RenderingProviderNPI not in (Select NPI from #PCPNPI)
Group by MVDID, RenderingProviderNPI

Select 
(dbo.fnFullName(ProviderLastName, ProviderFirstName, NULL)) AS [Name]
,dbo.fnInitCap(ISNULL(ProviderFirstname + ' ','') + ISNULL(ProviderLastname,'')) AS FirstLastName
,dbo.fnFormatPhone(b.ServicePhone) as Phone
,dbo.fnFormatPhone(b.ServiceFax) as Fax  
,NULL as Cell
,ServiceAddress1 as Address1
,ServiceAddress2 as Address2
,ServiceCity as City
,ServiceState as [State]
,COALESCE(STUFF(ServiceZip, 6, 0, '-'), ServiceZip) as ZipCode
,(SELECT RoleName FROM LookupRoleId WHERE   
RoleId = a.RoleID) AS [Type]  
From (
Select *
From #PCPNPI
Union
Select *
From #ClaimsNPI) a
Inner Join dbo.FinalProvider b on a.NPI = CAST( b.NPI as varchar(15))
Where b.ProviderFirstName is not null
Order by RoleID