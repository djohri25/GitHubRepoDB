/****** Object:  Procedure [dbo].[uspCFRule3]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFRule3]
AS
/* =================================================================
Author:	Deepank Johri
Create date: 09-23-2021
Description: Get distinct MVDID's for CFRule3
Example: EXEC dbo.uspCFRule3

Modifications
Date			Name			Comments	
09/23/2021      Deepank         Initial Version (TFS5856)

CREATE TABLE MMEOverlapANDOpioidUseDisorder_p360d
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

--==========================================================================
-- GET MVDID for mme overlap and opioid use disorder
--==========================================================================
TRUNCATE TABLE MMEOverlapANDOpioidUseDisorder_p360d
;
INSERT INTO MMEOverlapANDOpioidUseDisorder_p360d
SELECT 
	DISTINCT M.MVDID--,M.MemberID, M.MemberLastName,M.MemberFirstName, M.DateOfBirth,M.Gender, M.CmOrgRegion,0,'MMEOverlapANDOpioidUseDisorder' AS Category
	, Member_HealthHxTable.PartyKey
	, Member_HealthHxTable.CFR_Indicator_MMEOverlap_p360d
	, Member_HealthHxTable.CFR_Indicator_OpioidUseDisorder_p360d
	, Member_HealthHxTable.CFR_Indicator_PredictedMMEOverlapSUDDx_f360d
	, Member_HealthHxTable.Prob_Predicted_SUD
FROM Datalogy.NewDirections.pastMMEOverlap_predictedSUD_DemoDxMMERx__active_360d AS Member_HealthHxTable (readuncommitted)
JOIN Final.dbo.FinalMember M (readuncommitted) on Member_HealthHxTable.Partykey = M.PartyKey
WHERE (CFR_Indicator_MMEOverlap_p360d > 0 AND CFR_Indicator_OpioidUseDisorder_p360d > 0 AND Member_HealthHxTable.CmOrgRegion = 'WALMART')
;        

END