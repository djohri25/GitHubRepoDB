/****** Object:  Procedure [dbo].[Set_ABCBS_MemberContactLetter]    Committed by VersionSQL https://www.versionsql.com ******/

/*
DROP PROCEDURE
Set_ABCBS_MemberContactLetter;
*/

CREATE PROCEDURE
Set_ABCBS_MemberContactLetter
(
	@p_ID bigint = NULL OUTPUT,
	@p_LetterMemberID bigint,
	@p_ContactFormID nvarchar(100) = NULL
)
AS
BEGIN
	INSERT INTO
	ABCBS_MemberContactLetter
	(
		LetterMemberID,
		ContactFormID,
		CreatedDatetime
	)
	VALUES
	(
		@p_LetterMemberID,
		@p_ContactFormID,
		getUTCDate()
	);

	SET @p_ID = SCOPE_IDENTITY();
END;