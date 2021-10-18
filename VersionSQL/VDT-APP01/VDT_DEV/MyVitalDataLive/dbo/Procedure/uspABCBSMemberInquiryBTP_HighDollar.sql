/****** Object:  Procedure [dbo].[uspABCBSMemberInquiryBTP_HighDollar]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[uspABCBSMemberInquiryBTP_HighDollar] @MemberID varchar(30), @LOB varchar(30)

as 
SET NOCOUNT ON

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 08/08/2019
-- Description: Inquire a specific member/lob high rx/med claim dollar and case status
-- Exec uspABCBSMemberInquiryBTP_HighDollar 'Y0043556104', 'HA'
-- Exec uspABCBSMemberInquiryBTP_HighDollar '60009018401', 'BH'
-- Exec uspABCBSMemberInquiryBTP_HighDollar 'M6149260102', 'US'
-- https://vdt.visualstudio.com/SupportSite%204.5/_workitems/edit/1852/
-- =============================================

IF NOT EXISTS (SELECT MVDID FROM ComputedCareQueue WHERE MemberID = @MemberID and LOB=@LOB)
BEGIN
	RAISERROR('Member ID not found.',16,1);
END

Declare @CustID int = 16
Declare @MonthID varchar(6) 

Select @MonthID = Max(MonthID)
From ComputedMemberTotalPaidClaimsRollling12
Where CustID = @CustID


Drop Table If Exists #FinalData

Select
a.monthid,
a.MemberID,
a.MVDID,
a.HighDollarClaim,
a.TotalPaidAmount,
c.source_code as LOB,
c.source_code_name as LOB_Name,
q1ContactDate as ContactDate, 
q4ContactType as ContactWith, 
Case When Upper(q7ContactSuccess)  = 'YES' Then 'Contacted' When b.MVDID is null Then 'Not Contacted' Else 'Unable to Reach' End as ContactSuccess
Into #FinalData
From ComputedMemberTotalPaidClaimsRollling12 a 
Inner Join LookupLOB c on a.LOB = c.source_code
Outer Apply (Select Top 1 * From ARBCBS_Contact_Form b Where a.MVDID = b.MVDID and b.q1ContactDate>=DATEADD(d,1,(EOMONTH(DATEADD(m,-13,GetDate())))) Order by q7ContactSuccess Desc ) b 
Where  a.MemberID = @MemberID and c.source_code = @LOB and a.MonthID = @MonthID

Select MemberID, LOB, Case when HighDollarClaim = 1 then 'Y' else 'N' end as HighDollarClaim, ContactDate, ContactWith, Case When HighDollarClaim = 1 Then ContactSuccess Else NULL End as CM_Label
From #FinalData