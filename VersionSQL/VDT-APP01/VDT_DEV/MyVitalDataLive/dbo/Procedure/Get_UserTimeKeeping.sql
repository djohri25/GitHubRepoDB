/****** Object:  Procedure [dbo].[Get_UserTimeKeeping]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_UserTimeKeeping]
(
	@Username  varchar(30),
	@CustId  int
)
AS
BEGIN
	SELECT
	utk.Id,
	utk.StartDate,
	utk.EndDate,
	utk.Note,
	utk.Username UserName,
	utk.CustId CustomerId,
	utk.MemberId,
	fm.MemberFirstName,
	fm.MemberMiddleName,
	fm.MemberLastName
	FROM
	UserTimeKeeping utk
	INNER JOIN FinalMember fm
	ON fm.CustID = @CustID
	AND fm.MemberID = utk.MemberID
	WHERE
	utk.CustID = @CustId 
	AND utk.UserName = @UserName
	ORDER BY
	utk.Id DESC;
END