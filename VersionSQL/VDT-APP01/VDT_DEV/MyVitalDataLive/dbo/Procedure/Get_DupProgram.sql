/****** Object:  Procedure [dbo].[Get_DupProgram]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_DupProgram]
	@MVDID varchar(50),
	@CustID varchar(10),
	@Program varchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RefID int
	
	SELECT TOP 1 @RefID = ReferralID FROM ABCBS_MemberManagement_Form
	WHERE MVDID = @MVDID 
		and CaseProgram = @Program 
		and InProgress='No' 
		and ISNULL(qCloseCase,'No') <> 'Yes' 
		and CAST(SectionCompleted as int) < 3
		--and qCloseCase != 'Yes'
		--and SectionCompleted > 0

	select @RefID
END