/****** Object:  Procedure [dbo].[MainCarePlanMemberInterventions_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Updates the Member Care Plan Interventions
-- Create date: 05/14/2019
-- Description:	Updates the Main Care Plan Interventions Table
-- =============================================
CREATE PROCEDURE [dbo].[MainCarePlanMemberInterventions_Update]
	-- Add the parameters for the stored procedure here
		@Id BIGINT 
	   ,@GoalId BIGINT = NULL
	   ,@Seq INT = NULL
	   ,@InterventionNum BIGINT = NULL
	   ,@InterventionsFreeText VARCHAR(MAX) = NULL
	   ,@OutCome INT = NULL
	   ,@CompleteDate  DATETIME = NULL
	   ,@Comment VARCHAR(MAX)=NULL
	   ,@CPInactiveDate DATETIME = NULL
	   ,@UpdatedBy VARCHAR(50)
	   ,@Status INT = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE
		MainCarePlanMemberInterventions
	SET 
		GoalId= ISNULL(@GoalId,GoalID)
		,Seq= ISNULL(@Seq,seq)
		,InterventionNum=ISNULL(@InterventionNum,InterventionNum)
		,InterventionFreeText=ISNULL(@InterventionsFreeText,InterventionFreeText)
		,Outcome=ISNULL(@OutCome,OutCome)
		,CompleteDate=ISNULL(@CompleteDate,CompleteDate)
		,Comment= ISNULL(@Comment,Comment)
		,CPInactiveDate=ISNULL(@CPInactiveDate,CPInactiveDate)
		,UpdatedDate= GetDate()
		,UpdatedBy=ISNULL(@UpdatedBy,UpdatedBy)
		,Status=ISNULL(@Status,Status)
	WHERE Id=@Id
 END	