/****** Object:  Procedure [dbo].[uspCFRule2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFRule2]
AS
/* =================================================================
Author:	Deepank Johri
Create date: 09-23-2021
Description: Get distinct MVDID's for CFRule2
Example: EXEC dbo.uspCFRule2

Modifications
Date			Name			Comments	
09/23/2021      Deepank         Initial Version (TFS5856)

CREATE TABLE PredictedSUD_TopPercent
(
        MVDID varchar(30),
		PartyKey int,
		CFR_Indicator_MMEOverlap_p360d int,
		CFR_Indicator_OpioidUseDisorder_p360d int,
		CFR_Indicator_PredictedMMEOverlapSUDDx_f360d int,
		Prob_Predicted_SUD decimal(12,2)
)
====================================================================*/
BEGIN

SET NOCOUNT ON;

/********************************************
GET MVDID for Predicted SUD population
*********************************************/
TRUNCATE TABLE PredictedSUD_TopPercent
;
INSERT INTO PredictedSUD_TopPercent
SELECT TOP 17 PERCENT *
FROM 
	(SELECT DISTINCT M.MVDID--,M.MemberID, M.MemberLastName,M.MemberFirstName, M.DateOfBirth,M.Gender, M.CmOrgRegion,0,'Predicted SUD population' AS Category
		, Member_HealthHxTable.PartyKey
		, Member_HealthHxTable.CFR_Indicator_MMEOverlap_p360d
		, Member_HealthHxTable.CFR_Indicator_OpioidUseDisorder_p360d
		, Member_HealthHxTable.CFR_Indicator_PredictedMMEOverlapSUDDx_f360d
		, Member_HealthHxTable.Prob_Predicted_SUD
	FROM Datalogy.NewDirections.pastMMEOverlap_predictedSUD_DemoDxMMERx__active_360d AS Member_HealthHxTable (readuncommitted)
	JOIN Final.dbo.FinalMember M (readuncommitted) on Member_HealthHxTable.Partykey = M.PartyKey
	WHERE CFR_Indicator_PredictedMMEOverlapSUDDx_f360d > 0 AND Member_HealthHxTable.CmOrgRegion = 'WALMART' 
	) AS PredictedSUD
ORDER BY Prob_Predicted_SUD DESC
;

END