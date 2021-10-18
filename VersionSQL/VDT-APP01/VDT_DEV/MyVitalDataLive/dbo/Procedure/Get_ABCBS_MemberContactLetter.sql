/****** Object:  Procedure [dbo].[Get_ABCBS_MemberContactLetter]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_ABCBS_MemberContactLetter
(
	@p_MVDID nvarchar(255),
	@p_LetterName nvarchar(255),
	@p_ID bigint = NULL OUTPUT,
	@p_LetterMemberID bigint = NULL OUTPUT,
	@p_ContactFormID nvarchar(100) = NULL OUTPUT
)
AS
BEGIN

	SELECT
	@p_ID = mcl.ID,
	@p_LetterMemberID = lm.ID,
	@p_ContactFormID = mcl.ContactFormID
	FROM
	ABCBS_MemberContactLetter mcl
	INNER JOIN LetterMembers lm
	ON lm.ID = mcl.LetterMemberID
	INNER JOIN LetterTemplate lt
	ON lt.LetterType = lm.LetterType
	WHERE
	lm.MVDID = @p_MVDID
	AND lt.LetterName = @p_LetterName
	AND
	CASE
-- Use Contact Form ID if specified
	WHEN @p_ContactFormID IS NULL THEN 1
	WHEN mcl.ContactFormID = @p_ContactFormID THEN 1
	ELSE 0
	END = 1
	AND
	CASE
-- Most likely the ID is unknown, but use it if specified
	WHEN @p_ID IS NULL THEN 1
	WHEN mcl.ID = @p_ID THEN 1
	ELSE 0
	END = 1;

END;