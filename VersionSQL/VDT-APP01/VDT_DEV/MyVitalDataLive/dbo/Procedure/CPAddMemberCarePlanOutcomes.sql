/****** Object:  Procedure [dbo].[CPAddMemberCarePlanOutcomes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 08/17/2019
-- Description:	Add outcomes to a member careplan / problem
-- =============================================
CREATE PROCEDURE [dbo].[CPAddMemberCarePlanOutcomes]
	@libraryID as smallint, 
	@probNum as bigint, 
	@newProb as bigint, 
	@username varchar(100)
AS	 
BEGIN
	SET NOCOUNT ON;

	declare @newOutcome as bigint
	declare @OutcomeNum as bigint = -1

	if (@probNum > 0)
	begin
		select @newProb as ProblemID,
			-1 as seq,
			[cpOutcomeText] as outcomeFreeText,
			SYSUTCDATETIME() as CreatedDate,
			@username as CreatedBy,
			[cpOutcomeNum] as OutcomeNum
			into #tempOutcomes
			from [dbo].[CarePlanLibraryOutcomes] where [cpProbNum] = @probNum

		set rowcount 1

		select @OutcomeNum = OutcomeNum from #tempOutcomes

		while @@rowcount <> 0
		begin
		    set rowcount 0

			insert into [MainCarePlanMemberOutcomes] (
				ProblemID, 
				seq,  
				outcomeFreeText, 
				CreatedDate, 
				CreatedBy, 
				OutcomeNum) 
			select @newProb as ProblemID,
				-1 as seq,
				[cpOutcomeText] as outcomeFreeText,
				SYSUTCDATETIME(),
				@username,
				[cpOutcomeNum] as OutcomeNum
				from [dbo].[CarePlanLibraryOutcomes] where [cpProbNum] = @probNum and [cpOutcomeNum] = @OutcomeNum

			SELECT @newOutcome = SCOPE_IDENTITY()
			delete #tempOutcomes where OutcomeNum = @OutcomeNum

			set rowcount 1
			select @OutcomeNum = OutcomeNum from #tempOutcomes
		end
		set rowcount 0
	end
	else
	begin
		insert into [MainCarePlanMemberOutcomes] (
			ProblemID, 
			seq,  
			outcomeFreeText, 
			CreatedDate, 
			CreatedBy, 
			OutcomeNum) 
			values(
				@newProb,
				-1,
				'*** New Outcome ***',
				SYSUTCDATETIME(),
				@username,
				-1)
		SELECT @newOutcome = SCOPE_IDENTITY()
	end
END