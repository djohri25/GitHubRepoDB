/****** Object:  Procedure [dbo].[uspCFR_MapRuleExclusion]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_MapRuleExclusion] (@Action varchar(50) = 'DISPLAY',
                                                 @RuleID varchar(1000),
                                                 @ExclusionID varchar(1000) = NULL,
                                                 @Family varchar(1000) = NULL
										         )
AS
/*

note:  @Action is DISPLAY - List all the exclusions applied to the RuleID (or RuleIDs) in @RuleID
				  ADD	  - Add an exclusion, exclusions, or family of exclusions to the Rule or Rules in @Rules
				  DELETE  - Removed an exclusion, exclusions, or family of exclusions to the Rule or Rules in @Rules
				  
	  @RuleID is a comma delimited list of rules to act on.
	  @ExclusionID is a comma delimited list of rules to add/delete when @Action is 'ADD' or 'DELETE'
	  @ExclusionID is a comma delimited list of famalies of rules to add/delete when @Action is 'ADD' or 'DELETE'

Modifications:
WHO		WHEN		WHAT
Scott	2021-08-23	Created to avoid the tedious task of mapping excptions to rules.

SELECT * FROM CFR_Exclusion
SELECT * FROM HPWorkFlowRule

EXEC uspCFR_MapRuleExclusion @Action = 'DISPLAY', @RuleID = '284'
EXEC uspCFR_MapRuleExclusion @Action = 'ADD', @RuleID = '284,285,286,287,288,289', @ExclusionID = '20'
EXEC uspCFR_MapRuleExclusion @Action = 'DELETE', @RuleID = '284,285,286,287,288,289', @ExclusionID = '20'

EXEC uspCFR_MapRuleExclusion @Action = 'ADD', @RuleID = '284,285,286,287,288,289', @Family = 'Company,Standard,Universal', @pExclusionID = 20
EXEC uspCFR_MapRuleExclusion @Action = 'DELETE', @RuleID = '284,285,286,287,288,289', @Family = 'Company,Standard,Universal'

EXEC uspCFR_MapRuleExclusion @RuleID = '245'

*/
BEGIN
SET NOCOUNT ON

DECLARE @pAction varchar(50) = @Action
DECLARE @pRuleID varchar(1000) =	@RuleID	--	'284,285,286,287,288,289'
DECLARE @pFamily varchar(1000) = @Family 
DECLARE @pExclusionID varchar(1000) = @ExclusionID

PRINT OBJECT_NAME(@@PROCID) 

IF @pAction = 'ADD'
	BEGIN
		IF @pFamily IS NULL AND @pExclusionID IS NULL 
			BEGIN
				PRINT 'Error:  Must have a family or exclusion to ADD to Rule.'
			END
		--Add families
		IF @pFamily IS NOT NULL
			BEGIN

			;WITH New AS
				(
				SELECT r.RuleID, e.ExclusionID
				  FROM (SELECT Rule_ID AS RuleID 
			              FROM HPWorkFlowRule
			              WHERE Rule_ID IN (SELECT value FROM STRING_SPLIT(@pRuleID,','))) r
	             CROSS 
	              JOIN  (SELECT ID AS ExclusionID 
			               FROM CFR_Exclusion
			              WHERE Family IN (SELECT value AS ExclusionID FROM STRING_SPLIT(@pFamily,','))) e
				) MERGE CFR_Rule_Exclusion Old 
				  USING New ON New.RuleID = Old.RuleID AND New.ExclusionID = Old.ExclusionID
				  WHEN NOT MATCHED THEN INSERT (RuleID, ExclusionID) VALUES (RuleID, ExclusionID);
			
			END

		--Add individual exclusions
		IF @pExclusionID IS NOT NULL
			BEGIN

				;WITH New AS 
					(
					SELECT r.RuleID, e.ExclusionID
					  FROM (SELECT Rule_ID AS RuleID 
							  FROM HPWorkFlowRule
							  WHERE Rule_ID IN (SELECT value FROM STRING_SPLIT(@pRuleID,','))) r
					 CROSS 
					  JOIN  (SELECT ID AS ExclusionID 
							   FROM CFR_Exclusion
							  WHERE ID IN (SELECT value AS ExclusionID FROM STRING_SPLIT(@pExclusionID,','))) e
					) MERGE CFR_Rule_Exclusion Old
					  USING New ON New.RuleID = Old.RuleID AND New.ExclusionID = Old.ExclusionID
				  WHEN NOT MATCHED THEN INSERT (RuleID, ExclusionID) VALUES (RuleID, ExclusionID);

			  END
	END

IF @pAction = 'DELETE'
	BEGIN
		IF @pFamily IS NULL AND @pExclusionID IS NULL 
			BEGIN
				PRINT 'Error:  Must have a family or exclusion to DELETE from Rule.'
			END
        IF @pFamily IS NOT NULL
			BEGIN
			    DELETE re
				  FROM CFR_Rule_Exclusion re
				  JOIN (SELECT r.RuleID, e.ExclusionID 
				          FROM (SELECT value AS RuleID FROM STRING_SPLIT(@pRuleID,',')) r
				         CROSS 
						  JOIN (SELECT ID AS ExclusionID
						          FROM CFR_Exclusion
						         WHERE Family IN (SELECT value AS Family FROM STRING_SPLIT(@Family,','))) e
						) del
					ON re.RuleID = del.RuleID 
				   AND re.ExclusionID = del.ExclusionID
			END
		--Delete individual exclusions
		IF @pExclusionID IS NOT NULL
			BEGIN
			    DELETE re
				  FROM CFR_Rule_Exclusion re
				  JOIN (SELECT r.RuleID, e.ExclusionID 
				          FROM (SELECT value AS RuleID FROM STRING_SPLIT(@pRuleID,',')) r
				         CROSS 
						  JOIN (SELECT value AS ExclusionID FROM STRING_SPLIT(@pExclusionID,',')) e
						) del
					ON re.RuleID = del.RuleID 
				   AND re.ExclusionID = del.ExclusionID
			  END

	END
	   	 
SELECT wfr.Rule_ID, wfr.[Name], wfr.Body AS [Procedure], e.Family,e.ID AS ExclusionID, e.Exclusion 
  FROM HPWorkFlowRule wfr
  LEFT JOIN CFR_Rule_Exclusion re ON wfr.Rule_ID = re.RuleID
  LEFT JOIN CFR_Exclusion e ON re.ExclusionID = e.ID
 WHERE wfr.Rule_ID IN (SELECT * FROM STRING_SPLIT(@pRuleID,','))
 ORDER BY wfr.Rule_ID, e.ID

END