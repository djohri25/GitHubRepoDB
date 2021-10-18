/****** Object:  View [dbo].[vwCFRGroupMapping]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW vwCFRGroupMapping 
AS

     SELECT DB_Name() AS [Database], wfr.Rule_ID, wfr.Body, l.AlertGroup_ID, ag.Name AS AlertGroupName, q.OwnerGroup, og.Name AS OwnerGroupName, q.InQueue
       FROM HPWorkflowRule wfr
  LEFT JOIN Link_HPRuleAlertGroup l ON wfr.Rule_ID = l.Rule_ID
  LEFT JOIN HPAlertGroup ag ON l.AlertGroup_ID = ag.ID
OUTER APPLY (SELECT OwnerGroup, COUNT(*) AS InQueue 
               FROM CareFlowTask
			  WHERE RuleID = wfr.Rule_ID
			  GROUP BY RuleID, OwnerGroup) q
  LEFT JOIN HPAlertGroup og ON q.OwnerGroup = og.ID
      WHERE Query = 'SP'