/****** Object:  Procedure [dbo].[CPAddMemberCarePlanGoals]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Add goals to a member careplan / problem
-- =============================================
CREATE PROCEDURE [dbo].[CPAddMemberCarePlanGoals]
	@libraryID as smallint, 
	@probNum as bigint, 
	@newProb as bigint, 
	@username varchar(100)
AS	 
BEGIN
	SET NOCOUNT ON;

	declare @newGoal as bigint
	declare @GoalNum as bigint = -1

	if (@probNum > 0)
	begin
		select @newProb as ProblemID,
			-1 as seq,
			[cpGoalText] as goalFreeText,
			case when [cpGoalType] = 1 then 'S' else 'L' end as goalType,
			SYSUTCDATETIME() as CreatedDate,
			@username as CreatedBy,
			[cpGoalNum] as GoalNum
			into #tempGoals
			from [dbo].[CarePlanLibraryGoals] where [cpProbNum] = @probNum

		set rowcount 1

		select @GoalNum = GoalNum from #tempGoals

		while @@rowcount <> 0
		begin
		    set rowcount 0

			insert into [MainCarePlanMemberGoals] (
				ProblemID, 
				seq,  
				goalFreeText, 
				goalType, 
				CreatedDate, 
				CreatedBy, 
				GoalNum) 
			select @newProb as ProblemID,
				-1 as seq,
				[cpGoalText] as goalFreeText,
				case when [cpGoalType] = 1 then 'S' else 'L' end as goalType,
				SYSUTCDATETIME(),
				@username,
				[cpGoalNum] as GoalNum
				from [dbo].[CarePlanLibraryGoals] where [cpProbNum] = @probNum and [cpGoalNum] = @GoalNum

			SELECT @newGoal = SCOPE_IDENTITY()
			EXEC dbo.CPAddMemberCarePlanInterventions @libraryID, @GoalNum, @newGoal, @username
			delete #tempGoals where GoalNum = @GoalNum

			set rowcount 1
			select @GoalNum = GoalNum from #tempGoals
		end
		set rowcount 0
	end
	else
	begin
		insert into [MainCarePlanMemberGoals] (
			ProblemID, 
			seq,  
			goalFreeText, 
			goalType, 
			CreatedDate, 
			CreatedBy, 
			GoalNum) 
			values(
				@newProb,
				-1,
				'*** New Goal ***',
				'S',
				SYSUTCDATETIME(),
				@username,
				-1)
		SELECT @newGoal = SCOPE_IDENTITY()
		EXEC dbo.CPAddMemberCarePlanInterventions @libraryID, @GoalNum, @newGoal, @username
	end
END