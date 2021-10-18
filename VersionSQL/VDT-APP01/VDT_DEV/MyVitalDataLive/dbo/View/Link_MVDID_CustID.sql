/****** Object:  View [dbo].[Link_MVDID_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW [dbo].[Link_MVDID_CustID]
AS
SELECT     MVDId, Cust_ID, InsMemberId, IsArchived, Active
FROM         dbo.Link_MemberId_MVD_Ins
WHERE     (IsPrimary = 1)