/****** Object:  Procedure [dbo].[Get_MainCarePlan_Goals]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MainCarePlanGoals]
	@CPID int
as
begin
set nocount on
SELECT [ID]
      ,[CarePlanID]
      ,[ProblemID]
      ,[seq]
      ,[LongTermGoal]
      ,[ShortTermGoal]
      ,[Intervention]
      ,[Outcome]
      ,[CompleteDate]
      ,[UnmetReason]
  FROM [dbo].[MainCarePlanGoals]
  where CarePlanID = @CPID
  order by ProblemID, seq
end 