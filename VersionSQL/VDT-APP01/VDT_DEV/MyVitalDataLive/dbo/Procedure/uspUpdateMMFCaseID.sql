/****** Object:  Procedure [dbo].[uspUpdateMMFCaseID]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Modified timeout - Sunil.
EXEC uspUpdateMMFCaseID
*/
CREATE PROCEDURE
[dbo].[uspUpdateMMFCaseID]
AS
BEGIN
	SET NOCOUNT ON;

	SET LOCK_TIMEOUT 10000;  

	UPDATE
	ABCBS_MemberManagement_Form
	SET
	CaseID = ID
	WHERE
	SectionCompleted IN ( 2, 3 )
	AND ISNULL( CaseID, '' ) = ''
	AND ISNULL( CaseProgram, '' ) != '';
END;