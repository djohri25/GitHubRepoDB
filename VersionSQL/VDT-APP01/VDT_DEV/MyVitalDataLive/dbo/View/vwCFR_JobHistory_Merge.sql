/****** Object:  View [dbo].[vwCFR_JobHistory_Merge]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW [dbo].[vwCFR_JobHistory_Merge] AS

SELECT m.*, 
       DATEDIFF(ss, StartTime, EndTime) AS SecElapsed,
	   CAST(DATEDIFF(ss, StartTime, EndTime) / 60.0 AS numeric(10,2)) AS MinElapsed 
  FROM CFR_JobHistory_Merge m
 WHERE CAST(StartTime AS date) > CAST(DATEADD(dd,-7,GETUTCDATE()) AS date)