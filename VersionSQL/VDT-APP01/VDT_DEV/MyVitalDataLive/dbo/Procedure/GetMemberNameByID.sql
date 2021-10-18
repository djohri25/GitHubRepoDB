/****** Object:  Procedure [dbo].[GetMemberNameByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Sandberg
-- Create date: 9/15/20
-- Description:	obtains the member's first and last name
-- =============================================
CREATE PROCEDURE [dbo].[GetMemberNameByID]
	-- Add the parameters for the stored procedure here
	@CustomerID int,
	@MemberID VARCHAR(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT m.MemberFirstName, m.MemberLastName
	FROM dbo.[FinalMemberETL] m
	WHERE m.MemberID = @MemberID AND m.CustID = @CustomerID
END