/****** Object:  View [dbo].[Link_MemberId_MVD_Ins]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE view [dbo].[Link_MemberId_MVD_Ins]
as

-- Show Member Data with the most recent eligibility info by Latest BatchID and MemberEffectiveDate with PCP Info if available.



Select a.MVDID, a.MemberID as InsMemberId, b.CustID as Cust_ID, Cast(NULL as DateTime) as Created, NULL as IsPrimary, a.Isactive as Active, 0 as Archived, NULL as ArchivedDate, 0 as ArchiveAttemptCount, NULL as System_MemID
From ComputedCareQueue a
Inner Join FinalMember b on a.MVDID = b.MVDID
Union 
Select *
From Link_LegacyMemberId_MVD_Ins