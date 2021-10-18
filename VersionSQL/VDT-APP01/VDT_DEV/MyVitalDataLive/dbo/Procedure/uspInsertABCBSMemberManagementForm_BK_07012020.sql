/****** Object:  Procedure [dbo].[uspInsertABCBSMemberManagementForm_BK_07012020]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[uspInsertABCBSMemberManagementForm_BK_07012020] 
(
	@MVDID varchar(20),
	@CreatedDate datetime = null,
	@Owner varchar(100)= null,
	@ReferralId varchar(max)= null,
	@ReferralDate datetime= null,
	@TaskSource varchar(max)= null,
	@ReferralExternal varchar(max)= null,
	@ReferralSource varchar(50)=null,
	@CaseProgram varchar(max)= null,
	@NonViableReason varchar(max)= null,
	@FormAuthor varchar(max)= null,
	@ParentReferralID varchar(max)= null,
	@IsCaseConversion varchar(max)= null,
	@Inprogress varchar(10),
	@q15AssignTo varchar(100) =null,
	@CaseOwner varchar(100)=null, 
	@CareQ varchar(200)=null,
	@qNonViableReason varchar(max)=null,
	@qViableReason varchar(max)=null,
	@q19AssignedUser varchar(max)=null,
	@FormID bigint output
 )

AS
BEGIN
		SET NOCOUNT ON

	INSERT INTO [dbo].[ABCBS_MemberManagement_Form]
			(
			   [MVDID]
	          ,[FormDate]
	          ,[FormAuthor]
	          ,[ReferralID]
	          ,[ReferralDate]
	          ,[ReferralOwner]
	          ,[ReferralSource]
	          ,[ReferralExternal]
	          ,[ReferralReason]
	          ,[CaseProgram]
			   ,[NonViableReason]
			   ,[ParentReferralID]
			   ,[CaseConversion]
			   ,[InProgress]
			   ,q15AssignTo
			   ,q1CaseOwner
			   ,q16CareQ
			   ,qNonViableReason
			   ,qViableReason
			   ,q18User
			   ,q19AssignedUser
			)
	VALUES (
				@MVDID
				,@CreatedDate
				,@FormAuthor
				,@ReferralId
				,@ReferralDate
				,@Owner
				,@ReferralSource
				,@ReferralExternal
				,@TaskSource
				,@CaseProgram
				,@NonViableReason
				,@ParentReferralID
				,@IsCaseConversion
				,@Inprogress
				,@q15AssignTo
				,@CaseOwner
				,@CareQ
				,@qNonViableReason
				,@qViableReason
				,@q19AssignedUser
				,@q19AssignedUser)

	set @FormID = Scope_identity();

--SnapShot
  INSERT INTO [dbo].[ABCBS_MMFHistory_Form]
			(
			   [MVDID]
	          ,[FormDate]
	          ,[FormAuthor]
	          ,[ReferralID]
	          ,[ReferralDate]
	          ,[ReferralOwner]
	          ,[ReferralSource]
	          ,[ReferralExternal]
	          ,[ReferralReason]
	          ,[CaseProgram]
			   ,[NonViableReason]
			   ,[ParentReferralID]
			   ,[CaseConversion]
			   ,[InProgress]
			   ,q15AssignTo
			   ,q1CaseOwner
			   ,q16CareQ
			   ,qNonViableReason
			   ,qViableReason
			   ,q18User
			   ,q19AssignedUser
			   ,OriginalFormID
			)
	VALUES (
				@MVDID
				,@CreatedDate
				,@FormAuthor
				,@ReferralId
				,@ReferralDate
				,@Owner
				,@ReferralSource
				,@ReferralExternal
				,@TaskSource
				,@CaseProgram
				,@NonViableReason
				,@ParentReferralID
				,@IsCaseConversion
				,@Inprogress
				,@q15AssignTo
				,@CaseOwner
				,@CareQ
				,@qNonViableReason
				,@qViableReason
				,@q19AssignedUser
				,@q19AssignedUser
				,@FormID)



END