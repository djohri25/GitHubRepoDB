/****** Object:  Procedure [dbo].[uspGetGapsInConditionsForms]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Name : Sunil N
date: 11/4/2019

ModifiedBy			Date				Description
Sunil Nokku			02/09/2021			Add Spanish GapsInCondition Letter (TFS 4420)
*/

CREATE PROCEDURE [dbo].[uspGetGapsInConditionsForms] ( 
	@ID		INT)
AS
BEGIN

SET NOCOUNT ON;

SELECT TOP 1
	   G.[ID] AS GID
	  ,L.[ID] AS LID
      ,G.[MVDID]
      ,[FormDate]
      ,[FormAuthor]
      ,[CaseID]
      ,LTRIM(RTRIM([Gaps1])) AS Gaps1
      ,REPLACE(REPLACE(REPLACE([Gaps1Options], '"', ''),'[' , ''),']' , '') AS Gaps1Options
      ,LTRIM(RTRIM([Gaps2])) AS Gaps2
      ,REPLACE(REPLACE(REPLACE([Gaps2Options], '"', ''),'[' , ''),']' , '') AS Gaps2Options
      ,LTRIM(RTRIM([Gaps3])) AS Gaps3
      ,REPLACE(REPLACE(REPLACE([Gaps3Options], '"', ''),'[' , ''),']' , '') AS Gaps3Options
      ,LTRIM(RTRIM([Gaps4])) AS Gaps4
      ,REPLACE(REPLACE(REPLACE([Gaps4Options], '"', ''),'[' , ''),']' , '') AS Gaps4Options
      ,LTRIM(RTRIM([Gaps5])) AS Gaps5
      ,REPLACE(REPLACE(REPLACE([Gaps5Options], '"', ''),'[' , ''),']' , '') AS Gaps5Options
      ,LTRIM(RTRIM([Gaps6])) AS Gaps6
      ,REPLACE(REPLACE(REPLACE([Gaps6Options], '"', ''),'[' , ''),']' , '') AS Gaps6Options
      ,LTRIM(RTRIM([Gaps7])) AS Gaps7
      ,REPLACE(REPLACE(REPLACE([Gaps7Options], '"', ''),'[' , ''),']' , '') AS Gaps7Options
      ,LTRIM(RTRIM([Gaps8])) AS Gaps8
      ,REPLACE(REPLACE(REPLACE([Gaps8Options], '"', ''),'[' , ''),']' , '') AS Gaps8Options
      ,LTRIM(RTRIM([Gaps9])) AS Gaps9
      ,REPLACE(REPLACE(REPLACE([Gaps9Options], '"', ''),'[' , ''),']' , '') AS Gaps9Options
      ,LTRIM(RTRIM([Gaps10])) AS Gaps10
      ,REPLACE(REPLACE(REPLACE([Gaps10Options], '"', ''),'[' , ''),']' , '') AS Gaps10Options
      ,LTRIM(RTRIM([Gaps11])) AS Gaps11
      ,REPLACE(REPLACE(REPLACE([Gaps11Options], '"', ''),'[' , ''),']' , '') AS Gaps11Options
      ,LTRIM(RTRIM([Gaps12])) AS Gaps12
      ,REPLACE(REPLACE(REPLACE([Gaps12Options], '"', ''),'[' , ''),']' , '') AS Gaps12Options
      ,LTRIM(RTRIM([Gaps13])) AS Gaps13
      ,REPLACE(REPLACE(REPLACE([Gaps13Options], '"', ''),'[' , ''),']' , '') AS Gaps13Options
      ,LTRIM(RTRIM([Gaps14])) AS Gaps14
      ,REPLACE(REPLACE(REPLACE([Gaps14Options], '"', ''),'[' , ''),']' , '') AS Gaps14Options
      ,LTRIM(RTRIM([Gaps15])) AS Gaps15
      ,REPLACE(REPLACE(REPLACE([Gaps15Options], '"', ''),'[' , ''),']' , '') AS Gaps15Options
      ,LTRIM(RTRIM([Gaps16])) AS Gaps16
      ,REPLACE(REPLACE(REPLACE([Gaps16Options], '"', ''),'[' , ''),']' , '') AS Gaps16Options
      ,LTRIM(RTRIM([Gaps17])) AS Gaps17
      ,REPLACE(REPLACE(REPLACE([Gaps17Options], '"', ''),'[' , ''),']' , '') AS Gaps17Options
      ,LTRIM(RTRIM([Gaps18])) AS Gaps18
      ,REPLACE(REPLACE(REPLACE([Gaps18Options], '"', ''),'[' , ''),']' , '') AS Gaps18Options
      ,LTRIM(RTRIM([Gaps19])) AS Gaps19
      ,REPLACE(REPLACE(REPLACE([Gaps19Options], '"', ''),'[' , ''),']' , '') AS Gaps19Options
      ,LTRIM(RTRIM([Gaps20])) AS Gaps20
      ,REPLACE(REPLACE(REPLACE([Gaps20Options], '"', ''),'[' , ''),']' , '') AS Gaps20Options
      ,LTRIM(RTRIM([Gaps21])) AS Gaps21
      ,REPLACE(REPLACE(REPLACE([Gaps21Options], '"', ''),'[' , ''),']' , '') AS Gaps21Options
      ,LTRIM(RTRIM([Gaps22])) AS Gaps22
      ,REPLACE(REPLACE(REPLACE([Gaps22Options], '"', ''),'[' , ''),']' , '') AS Gaps22Options
      ,LTRIM(RTRIM([Gaps23])) AS Gaps23
      ,REPLACE(REPLACE(REPLACE([Gaps23Options], '"', ''),'[' , ''),']' , '') AS Gaps23Options
      ,LTRIM(RTRIM([Gaps24])) AS Gaps24
      ,REPLACE(REPLACE(REPLACE([Gaps24Options], '"', ''),'[' , ''),']' , '') AS Gaps24Options
      ,LTRIM(RTRIM([Gaps25])) AS Gaps25
      ,REPLACE(REPLACE(REPLACE([Gaps25Options], '"', ''),'[' , ''),']' , '') AS Gaps25Options
      ,[EnableQuestion]
      ,[AddedGaps]
  FROM [dbo].[ABCBS_GapsInCondition_Form] G
	LEFT OUTER JOIN [dbo].[LetterMembers] L ON G.[MVDID] = L.[MVDID]
  WHERE 
	L.[LetterType] IN ( 27, 48 )
	AND L.ID = @ID ORDER BY G.ID DESC
END