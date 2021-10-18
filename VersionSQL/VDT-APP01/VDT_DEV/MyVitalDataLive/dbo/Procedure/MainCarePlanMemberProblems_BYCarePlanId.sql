/****** Object:  Procedure [dbo].[MainCarePlanMemberProblems_BYCarePlanId]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[MainCarePlanMemberProblems_BYCarePlanId]
	-- Add the parameters for the stored procedure here
	@CarePlanId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		[ID]
      ,[CarePlanID]
      ,[seq]
      ,[idDate]
      ,[priority]
      ,[problemNum]
      ,[problemFreeText]
      ,CAST(case when Status < 1 then 0 else 1 end as bit) as Status
      ,[cpInactiveDate]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[UpdatedDate]
      ,[UpdatedBy]
      ,[Optionality]
      ,[Comments]
      ,[Closed]	
	FROM 
	[MainCarePlanMemberProblems] 
	WHERE Status < 1 
	 AND  [CarePlanID] = @CarePlanId
END