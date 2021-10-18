/****** Object:  Procedure [dbo].[uspInsertABCBSMemberManagementForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 05/15/2019
-- MODIFIED: Added @ReferralOwner varchar(max)= null, 05/16/2019
-- MOdified: Added q15AssignTo,q1CaseOwner,q16CareQ column to the insert statement, 07/70/2019
-- Description:	Inserts into MemberReferral Table based on input values
-- Execution: exec dbo.ABCBS_MemberManagement_Form 1
-- dpatel: 06/15/2020	Updated set @FormID = @@identity; to set @FormID = SCOPE_IDENTITY(); Added new HistoryFormId optional output parameter to avoid querying MMFHistory table to get new Id.
-- Scott	2021-02-03	Added Version to both inserts to use Version 2
-- Jose		20210525	Added ARITHABORT
--================================================


CREATE PROCEDURE [dbo].[uspInsertABCBSMemberManagementForm] 
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
@SectionCompleted varchar(max) = null,
@FormID bigint output,
@HistoryFormId bigint = null output
AS
BEGIN

SET ARITHABORT ON
SET NOCOUNT ON

INSERT INTO [dbo].[ABCBS_MemberManagement_Form] (
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
	,SectionCompleted
	,[Version]
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
	,@SectionCompleted
	,'V2'
	)

set @FormID = SCOPE_IDENTITY();

--SnapShot
INSERT INTO [dbo].[ABCBS_MMFHistory_Form] (
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
	,SectionCompleted
	,[Version]

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
	,@FormID
	,@SectionCompleted
	,'V2'
	)

set @HistoryFormId = SCOPE_IDENTITY();

END