/****** Object:  Procedure [dbo].[Set_MemberCarePlanGoal]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MemberCarePlanGoal]		   
@CpID int,
@cpProbID int,
@SEQ int,
@COMPLETEDATE date,
@LTG int,
@STG int,
@INTERVENTION int,
@OUTCOME int,
@UREASON varchar(MAX),
@pGID int OUTPUT
as
begin
INSERT INTO [dbo].[MainCarePlanGoals]
           ([CarePlanID]
           ,[ProblemID]
           ,[seq]
           ,[LongTermGoal]
           ,[ShortTermGoal]
           ,[Intervention]
           ,[Outcome]
           ,[CompleteDate]
           ,[UnmetReason])
     VALUES
           (@CpID, @cpProbID, @SEQ, @LTG, @STG, @INTERVENTION, @OUTCOME, @COMPLETEDATE, @UREASON)
		   
SELECT @pGID = SCOPE_IDENTITY()
end