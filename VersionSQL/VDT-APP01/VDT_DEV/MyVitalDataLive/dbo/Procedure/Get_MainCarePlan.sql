/****** Object:  Procedure [dbo].[Get_MainCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MainCarePlan]
	@MVDID varchar(50),
	@CPID int
as
begin
set nocount on

if (@CPID < 0)
 select @CPID = max(CarePlanID) from [dbo].[MainCarePlanIndex] where MVDID = @MVDID

SELECT [CarePlanID]
      ,[Cust_ID]
      ,[MVDID]
      ,[cpLibraryID]
      ,[CarePlanDate]
      ,[Author]
      ,[Language]
      ,[CarePlanReview]
	  ,[CaseID]
  FROM [dbo].[MainCarePlanIndex]
Where CarePlanID = @CPID
end