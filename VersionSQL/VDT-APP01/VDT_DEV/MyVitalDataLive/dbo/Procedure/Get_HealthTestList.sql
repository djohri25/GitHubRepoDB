/****** Object:  Procedure [dbo].[Get_HealthTestList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_HealthTestList]
@Language BIT = 1
As

SET NOCOUNT ON
IF(@Language = 1)
	BEGIN -- 1 = english
		SELECT TestID, TestName FROM LookupHealthTest ORDER BY TestName
	END
ELSE
	BEGIN -- 0 = spanish
		SELECT TestID, TestNameSpanish TestName FROM LookupHealthTest ORDER BY TestNameSpanish
	END