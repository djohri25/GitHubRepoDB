/****** Object:  Procedure [dbo].[CPAddMemberCarePlanInterventions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Add member interventions into careplan
-- =============================================
CREATE PROCEDURE [dbo].[CPAddMemberCarePlanInterventions] 
	@libraryID as smallint, 
	@GoalNum as bigint, 
	@newGoal as bigint, 
	@username as varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

    if (@GoalNum > -1)
    begin
        insert into [MainCarePlanMemberInterventions] (
			GoalID, 
			seq, 
			InterventionNum, 
			interventionFreeText, 
			CreatedDate, 
			CreatedBy)
		select @newGoal as GoalID,
		-1 as seq,
		[cpInterventionNum] as InterventionNum,
		[cpInterventionText] as interventionFreeText,
		SYSUTCDATETIME() as CreatedDate,
		@username as CreatedBy
		from [dbo].[CarePlanLibraryInterventions]
		where [cpGoalNum] = @GoalNum
    end
	else
	begin
        insert into [MainCarePlanMemberInterventions] (
			GoalID, 
			seq, 
			InterventionNum, 
			interventionFreeText, 
			CreatedDate, 
			CreatedBy)
        values(@newGoal, -1,  -1, '*** New Intervention ***', SYSUTCDATETIME(), @username)
	end

END