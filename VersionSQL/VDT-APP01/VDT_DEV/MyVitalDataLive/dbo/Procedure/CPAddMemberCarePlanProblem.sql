/****** Object:  Procedure [dbo].[CPAddMemberCarePlanProblem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Add a problem (and children) to careplan
-- =============================================
CREATE PROCEDURE [dbo].[CPAddMemberCarePlanProblem] 
	@libraryID as smallint,
	@carePlanID as bigint,
	@username as varchar(100),
	@probNum as bigint
AS
BEGIN
	SET NOCOUNT ON;

	declare @newProb as bigint

    if (@probNum > -1)
    begin
        -- check to see if this problem is already in the member's current careplan
        select * into #membercareplan from [MainCarePlanMemberProblems] where [CarePlanID] = @carePlanID and problemNum = @probNum

        if (@@ROWCOUNT > 0)
			return

        insert into [MainCarePlanMemberProblems] (
			CarePlanID, 
			seq, 
			idDate, 
			[priority], 
			problemNum, 
			problemFreeText, 
			[status], 
			CreatedDate, 
			CreatedBy, 
			Optionality)
		select @carePlanID as CarePlanID,
		-1 as seq,
		SYSUTCDATETIME() as idDate, 
		0 as [priority],
		[cpProbNum] as problemNum,
		[cpProbText] as problemFreeText,
		0 as [status],
		SYSUTCDATETIME() as CreatedDate,
		@username as CreatedBy,
		0 as Optionality
		from [dbo].[CarePlanLibraryProblems]
		where [cpProbNum] = @probNum and [cpLibraryID] = @libraryID

		SELECT @newProb = SCOPE_IDENTITY()
    end
	else
	begin
        insert into [MainCarePlanMemberProblems] (
			CarePlanID, 
			seq, 
			idDate, 
			[priority], 
			problemNum, 
			problemFreeText, 
			[status], 
			CreatedDate, 
			CreatedBy, 
			Optionality) 
        values(@carePlanID, -1, SYSUTCDATETIME(), 0, -1, '*** New Problem ***', 0, SYSUTCDATETIME(), @username, 0)
		SELECT @newProb = SCOPE_IDENTITY()
	end

	EXEC dbo.CPAddMemberCarePlanGoals @libraryID, @probNum, @newProb, @username
	EXEC dbo.CPAddMemberCarePlanOutcomes @libraryID, @probNum, @newProb, @username
END