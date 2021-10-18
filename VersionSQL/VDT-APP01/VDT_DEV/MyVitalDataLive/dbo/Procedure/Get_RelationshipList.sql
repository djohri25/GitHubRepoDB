/****** Object:  Procedure [dbo].[Get_RelationshipList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_RelationshipList]
@Language BIT = 1
AS

SET NOCOUNT ON
IF @Language = 1
	-- 1 = english
	SELECT RelationshipID, RelationshipName FROM LookupRelationshipID ORDER BY RelationshipID

ELSE
	-- 0 = spanish
	SELECT RelationshipID, RelationshipNameSpanish RelationshipName FROM LookupRelationshipID ORDER BY RelationshipID