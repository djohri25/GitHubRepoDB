/****** Object:  Procedure [dbo].[MainCarePlanMemberOutcomes_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Updates the Member Care Plan Interventions
-- Create date: 05/14/2019
-- Description:	Updates the Main Care Plan Outcome Table
-- =============================================
CREATE PROCEDURE [dbo].[MainCarePlanMemberOutcomes_Update]
	-- Add the parameters for the stored procedure here
		@Id BIGINT 
	   ,@ProblemId BIGINT 
	   ,@Seq INT 
	   ,@OutcomeNum BIGINT = NULL
	   ,@OutcomeFreeText VARCHAR(MAX) = NULL
	   ,@Status INT = NULL
	   ,@CompleteDate  DATETIME = NULL
	   ,@CPInactiveDate DATETIME = NULL
	   ,@UpdatedBy VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE
		MainCarePlanMemberOutcomes
	SET 
		 ProblemId= ISNULL(@ProblemId,ProblemId)
		,Seq= ISNULL(@Seq,seq)
		,OutcomeNum=ISNULL(@OutcomeNum,OutcomeNum)
		,OutcomeFreeText=ISNULL(@OutcomeFreeText,OutcomeFreeText)
		,CompleteDate=ISNULL(@CompleteDate,CompleteDate)
		,CPInactiveDate=ISNULL(@CPInactiveDate,CPInactiveDate)
		,UpdatedDate= GetDate()
		,UpdatedBy=ISNULL(@UpdatedBy,UpdatedBy)
		,Status=ISNULL(@Status,Status)
	WHERE Id=@Id
 END	