/****** Object:  Procedure [dbo].[GET_MEMBER_OWNER]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Get Member Ownership Data
--              Optional parameter returns only the active primary owner
-- =============================================
CREATE PROCEDURE [dbo].[GET_MEMBER_OWNER]
	@CustID INT,
	@MVDID varchar(15),
	@JustPrimary smallint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@JustPrimary > 0)
	BEGIN
		SELECT CustID, MVDID, OwnerType, UserID, GroupID, StartDate, EndDate, OwnerName, CreatedBy, CreatedDate
		FROM [dbo].[Final_MemberOwner]
		WHERE CustID = @CustID
			AND MVDID = @MVDID
			AND OwnerType = 1 
			AND (EndDate = null or EndDate = '')
	END
	ELSE
	BEGIN
		SELECT CustID, MVDID, OwnerType, UserID, GroupID, StartDate, EndDate, OwnerName, CreatedBy, CreatedDate
		FROM [dbo].[Final_MemberOwner]
		WHERE CustID = @CustID
			AND MVDID = @MVDID
		ORDER BY StartDate DESC, OwnerType DESC
	END

END