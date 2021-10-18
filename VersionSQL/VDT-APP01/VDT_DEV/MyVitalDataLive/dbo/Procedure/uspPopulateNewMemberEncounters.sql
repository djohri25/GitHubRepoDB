/****** Object:  Procedure [dbo].[uspPopulateNewMemberEncounters]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE proc [dbo].[uspPopulateNewMemberEncounters] 

as

SET NOCOUNT ON

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 06/25/2019
-- Description: Find All Encounters from Claims Table and Populate to AfFiniteABCBSLive.dbo.EDVisitHistory 
-- Notes:
-- add a new section here to find new batchID
-- only add ED visits if there's a new Visit or a new NPI
-- ensure that IsSubcriberClientEmployee is factored in
-- =============================================

-- Get Latest Eligibility Info

TRUNCATE Table dbo.EDVisitHistory

Insert Into dbo.EDVisitHistory 
(ICENUMBER
,VisitDate
,FacilityName
,PhysicianFirstName
,PhysicianLastName
,PhysicianPhone
,[Source]
,SourceRecordID
,Created
,CancelNotification
,CancelNotifyReason
,IsHospitalAdmit
,VisitType
,SourceFormType
,MatchName
,MatchRecordID
,FacilityNPI
,POS
,ChiefComplaint
,ClaimID
,ClaimNumber
,TotalPaidAmount
,BatchID
,CustID
)

Select 
a.MVDID as MVDID
, a.StatementFromDate as VisitDate
, c.[BusinessName] as FacilityName
, c.[ProviderFirstName] as PhysicianFirstName
, c.[ProviderLastName] as PhysicianLastName
, c.[ServicePhone] as PhysicianPhone
, 'CountyCare : Claims' as [Source] -- Should be '{ClientName} : Claims'
, a.RecordID as SourceRecordID
, GetUTCDate() as Created
, 0 as CancelNotification
, NULL as CancelNotifyReason
, Case When IsNULL(a.AdmissionDate,'') <> '' Then 1 Else 0 End as IsHospitalAdmit
, Case When EmergencyIndicator = 1 Then 'ER' When cast(IsNULL(a.AttendingProviderNPI, a.RenderingProviderNPI) as varchar(20))= cast(d.PCPNPI as varchar(20)) Then 'PHYSICIAN' Else 'OTHER' END as VisitType
, NULL as SourceFormType 
, NULL as MatchName
, NULL as MatchRecordID
, Cast(a.RenderingProviderNPI as varchar(20)) as FacilityNPI
, a.PlaceOfService as POS
, NULL as ChiefComplaint
, NULL as ClaimID
, a.ClaimNumber as ClaimNumber
, a.TotalPaidAmount as TotalPaidAmount
, a.CurrentBatchID as BatchID
, a.CustID
From dbo.FinalClaimsHeader a 
Outer Apply (Select Top 1 * From FinalProvider c where a.RenderingProviderNPI = c.NPI Order by AffiliationEffectiveDate desc) c
Outer Apply (Select Top 1 * From FinalEligibility d where a.mvdid=d.MVDID Order by MemberEffectiveDate desc, CurrentBatchID ) d
where a.StatementFromDate > DATEADD(YEAR,-1,GetDate())