/****** Object:  Procedure [dbo].[Set_MemberCarePlanProblem]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MemberCarePlanProblem]		   
@CpID int,
@SEQ int,
@IDDATE date,
@PRIORITY int,
@PROBNUM int,
@STATUS int,
@pPID int OUTPUT
as
begin
INSERT INTO [dbo].[MainCarePlanProblems]
           ([CarePlanID]
           ,[seq]
           ,[idDate]
           ,[priority]
           ,[problemNum]
           ,[status])
     VALUES
           (@CpID, @SEQ, @IDDATE, @PRIORITY, @PROBNUM, @STATUS)

SELECT @pPID = SCOPE_IDENTITY()
end