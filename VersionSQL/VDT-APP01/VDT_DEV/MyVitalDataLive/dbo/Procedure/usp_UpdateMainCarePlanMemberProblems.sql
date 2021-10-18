/****** Object:  Procedure [dbo].[usp_UpdateMainCarePlanMemberProblems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Noha Elanwer
-- Create date: 05/28/2019
-- Description:	Update the Main Member problem care plan library
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMainCarePlanMemberProblems]
	-- Add the parameters for the stored procedure here
	@ID BIGINT
	,@CarePlanID BIGINT=NULL
	,@Seq INT=NULL
	,@IdDate DateTime =NULL
	,@Priority SMALLINT=NULL
	,@ProblemNum INT =NULL
	,@ProblemFreeText VARCHAR(MAX)=NULL
	,@Status BIT=NULL
	,@CPInativeDate DATETIME=NULL
	,@CreatedDate DateTime=NULL
	,@CreatedBy VARCHAR(50)= NULL
	,@UpdatedDate DATETIME =NULL
	,@UpdatedBy VARCHAR(50)= NULL
	,@Optionality INT
	,@Comments NVARCHAR(MAX)=NULL
	,@Closed BIT = NULL


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 UPDATE MainCarePlanMemberProblems
	 SET 
		CarePlanID=ISNULL(@CarePlanID,CarePlanId)
		,Seq=ISNULL(@Seq,Seq)
		,IdDate=ISNULL(@IdDate,IdDate)
		,Priority=ISNULL(@Priority, Priority)
		,ProblemNum=ISNULL(@ProblemNum, ProblemNum)
		,ProblemFreeText=ISNULL(@ProblemFreeText,ProblemFreeText)
		,Status=ISNULL(@Status,Status)
		,CPInactiveDate=ISNULL(@CPInativeDate,cpInactiveDate)
		,CreatedDate=ISNULL(@CreatedDate,CreatedDate)
		,CreatedBy=ISNULL(@CreatedBy,CreatedBy)
		,UpdatedDate=ISNULL(@UpdatedDate,UpdatedDate)
		,UpdatedBy=ISNULL(@UpdatedBy,UpdatedBy)
		,Optionality=ISNULL(@Optionality,Optionality)
		,Comments=ISNULL(@Comments,Comments)
		,Closed=ISNULL(@Closed,Closed)
	WHERE ID= @ID


END