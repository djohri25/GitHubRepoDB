/****** Object:  Procedure [dbo].[uspABCBSMemberInquiryMaternity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[uspABCBSMemberInquiryMaternity] @MemberID varchar(30), @LOB varchar(30)
as 
BEGIN
	SET NOCOUNT ON
	
	-- =============================================
	-- Author:		Mike Grover
	-- Create date: 10/24/2020
	-- Description: Inquire a specific member/lob and return the user info around maternity CM.
	-- Exec uspABCBSMemberInquiryMaternity '50000215301', 'BX'
	-- Exec uspABCBSMemberInquiryMaternity '60009018401', 'BH'
	-- Exec uspABCBSMemberInquiryMaternity 'M6149260102', 'US'
	-- https://vdt.visualstudio.com/SupportSite%204.5/_workitems/edit/3633/
	-- If the member has an active MMF for Case Program = Maternity and Referral Reason = Maternity – Mom 
	-- with a maternity enrollment form created in the last 45 days, based on these factors we want to 
	-- prevent the online enrollment with the enrollment indicator field labeled as 'Allow_Enrollment:N', 
	-- otherwise return 'Allow_Enrollment:Y'
	-- =============================================
	
	Declare @CustID int = 16
	Declare @MVDID varchar(30)
	DECLARE @MMFID int = -1
	DECLARE @MEFID int = -1
	
	IF NOT EXISTS (SELECT MVDID FROM ComputedCareQueue WHERE MemberID = @MemberID and LOB = @LOB)
	BEGIN
		RAISERROR('Member ID not found.',16,1);
	END
	
	SELECT @MVDID = MVDID FROM ComputedCareQueue WHERE MemberID = @MemberID and LOB = @LOB
	
	SELECT top 1 @MMFID = ID from ABCBS_MemberManagement_Form where MVDID = @MVDID and CaseProgram = 'Maternity' and ReferralReason = 'Maternity - Mom' and SectionCompleted < 3 and DATEDIFF(day,FormDate,GetDate()) <= 45
	SELECT top 1 @MEFID = ID from ABCBS_MaternityEnrollment_Form where MVDID = @MVDID and DATEDIFF(day,FormDate,GetDate()) <= 45
	
	SELECT 'Allow_Enrollment:' + CASE WHEN @MMFID > 0 and @MEFID > 0 then 'N' else 'Y' end
END