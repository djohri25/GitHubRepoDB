/****** Object:  Procedure [dbo].[Get_MainCarePlan_Problems]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MainCarePlanProblems]
	@CPID int
as
begin
set nocount on


SELECT [ID]
      ,[CarePlanID]
      ,[seq]
      ,[idDate]
      ,[priority]
      ,[problemNum]
      ,[status]
      ,[CreatedDate]
  FROM [dbo].[MainCarePlanProblems]
  WHERE CarePlanID = @CPID
  order by seq
 end