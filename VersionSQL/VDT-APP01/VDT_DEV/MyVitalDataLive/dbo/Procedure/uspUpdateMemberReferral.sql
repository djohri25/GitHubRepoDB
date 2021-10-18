/****** Object:  Procedure [dbo].[uspUpdateMemberReferral]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 05/15/2019
-- MODIFIED: 
-- Description:	Updates the MemberReferral Table based on input values
-- Execution: exec [uspUpdateMemberReferral] 1
--================================================


CREATE  PROCEDURE [dbo].[uspUpdateMemberReferral] ( @ReferralID bigint,
	@DocID bigint = NULL,  @ParentDocID bigint = NULL,  @MemberID varchar(30)  =  NULL,  @TaskID bigint  = NULL,  @TaskSource nvarchar(100) =  NULL,  
	@CaseProgram varchar(100) =  NULL,  @ParentReferralID bigint =  NULL,  @NonViableReason nvarchar(100) =  NULL,  @CreatedDate datetime = NULL , 
	@CreatedBy nvarchar(100) =  NULL,  @CheckAssignment bit  =  NULL,  @Cust_ID int  =  NULL )
AS
BEGIN
SET NOCOUNT ON


if exists (select 1 from [MemberReferral] where id =@ReferralID )

Begin
UPDATE [dbo].[MemberReferral]
   SET [DocID] = isNull(@DocID,[DocID])
      ,[ParentDocID] = isnull(@ParentDocID,[ParentDocID])
      ,[MemberID] = isnull(@MemberID,[MemberID])
      ,[TaskID] = isnull(@TaskID,[TaskID])
      ,[TaskSource] =  isnull(@TaskSource,[TaskSource])
      ,[CaseProgram] = isnull(@CaseProgram,[CaseProgram])
      ,[ParentReferralID] = isnull(@ParentReferralID,[ParentReferralID])
      ,[NonViableReason] = isnull(@NonViableReason,[NonViableReason])
      ,[CreatedDate] = isnull(@CreatedDate,[CreatedDate])
      ,[CreatedBy] = isnull(@CreatedBy,[CreatedBy])
      ,[CheckAssignment] = isnull(@CheckAssignment,[CheckAssignment])
      ,[Cust_ID] = isnull(@Cust_ID,[Cust_ID])
 WHERE Id = @ReferralID


 End



END