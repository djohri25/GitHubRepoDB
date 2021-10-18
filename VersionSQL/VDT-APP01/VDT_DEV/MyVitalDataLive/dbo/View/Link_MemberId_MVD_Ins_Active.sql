/****** Object:  View [dbo].[Link_MemberId_MVD_Ins_Active]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.Link_MemberId_MVD_Ins_Active
AS
SELECT     MVDId, ArchiveAttemptCount, ArchivedDate, IsArchived, Active, IsPrimary, Created, Cust_ID, InsMemberId
FROM         dbo.Link_MemberId_MVD_Ins
WHERE     (Active = 1)