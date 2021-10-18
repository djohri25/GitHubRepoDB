/****** Object:  Procedure [dbo].[uspInsertMemberReferral]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 05/15/2019
-- MODIFIED: 
-- Description:	Inserts into MemberReferral Table based on input values
-- Execution: exec dbo.InsertMemberReferral 1
--================================================


CREATE  PROCEDURE [dbo].[uspInsertMemberReferral] 
(			@DocID bigint =null
           ,@ParentDocID bigint = null
           ,@MemberID varchar(30) = null
           ,@TaskID bigint = null
           ,@TaskSource nvarchar(100) = null
           ,@CaseProgram varchar(100) = null
           ,@ParentReferralID bigint = null
           ,@NonViableReason nvarchar(100) = null
           ,@CreatedDate datetime = null
           ,@CreatedBy nvarchar(100) = null
           ,@CheckAssignment bit = null
           ,@Cust_ID int= null
		   ,@ReferralId bigint output
												)
AS
BEGIN
		SET NOCOUNT ON



				INSERT INTO [dbo].[MemberReferral]
						   ([DocID]
						   ,[ParentDocID]
						   ,[MemberID]
						   ,[TaskID]
						   ,[TaskSource]
						   ,[CaseProgram]
						   ,[ParentReferralID]
						   ,[NonViableReason]
						   ,[CreatedDate]
						   ,[CreatedBy]
						   ,[CheckAssignment]
						   ,[Cust_ID])
				values (	@DocID  
						   ,@ParentDocID  
						   ,@MemberID 
						   ,@TaskID  
						   ,@TaskSource  
						   ,@CaseProgram 
						   ,@ParentReferralID  
						   ,@NonViableReason 
						   ,@CreatedDate 
						   ,@CreatedBy 
						   ,@CheckAssignment  
						   ,@Cust_ID  )

						   set @ReferralId=scope_identity()
						   
END