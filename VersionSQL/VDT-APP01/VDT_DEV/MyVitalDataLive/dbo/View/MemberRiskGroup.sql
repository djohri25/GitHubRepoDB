/****** Object:  View [dbo].[MemberRiskGroup]    Committed by VersionSQL https://www.versionsql.com ******/

/*
DROP VIEW
MemberRiskGroup;
*/

CREATE VIEW
MemberRiskGroup
AS
SELECT
MVDID,
RiskGroupID
FROM
ComputedCareQueue;