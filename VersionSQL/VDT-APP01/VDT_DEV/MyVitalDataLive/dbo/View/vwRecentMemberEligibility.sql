/****** Object:  View [dbo].[vwRecentMemberEligibility]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE view [dbo].[vwRecentMemberEligibility]
as

-- Show Member Data with the most recent eligibility info by Latest BatchID and MemberEffectiveDate with PCP Info if available.

Select 

a.MVDID,
a.MemberID,
a.MemberFirstName,
a.MemberLastName,
a.MemberMiddleName,
a.Gender,
DateOfBirth,
SSN,
Relationship,
SubscriberID,
Address1,
Address2,
City,
State,
Zipcode,
Race,
a.Ethnicity,
a.CurrentCoPayLevel,
Suffix,
HomePhone,
WorkPhone,
Fax,
Email,
Language,
SpokenLanguage,
WrittenLanguage,
OtherLanguage
LOB,
MemberEffectiveDate,
MemberTerminationDate,
BusinessName,
ProviderFirstName,
ProviderLastName,
ServiceAddress1,
ServiceAddress2,
ServiceCity,
ServiceState,
ServiceZip,
ServicePhone,
ServiceFax,
ServiceStatus,
a.CustID,
a.CurrentBatchID,
PCPNPI,
TIN
From FinalMember a
Outer Apply (
(Select MVDID, MemberID, LOB, PCPNPI, MemberEffectiveDate, MemberTerminationDate, CustID, CurrentBatchID,
ROW_NUMBER() OVER(PARTITION BY MVDID ORDER BY CurrentBatchID, MemberEffectiveDate DESC) AS RowRank
From FinalEligibility fe Where a.MVDID = fe.MVDID)) b
Outer Apply (Select Top 1 * From FinalProvider fp where cast(b.PCPNPI as varchar(20)) =cast(fp.NPI as varchar(20)) Order by AffiliationEffectiveDate desc) c
Where a.MemberID = b.MemberID and b.RowRank=1