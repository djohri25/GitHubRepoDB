/****** Object:  Procedure [dbo].[UPDATE_MEMBER_OWNER]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Update Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_MEMBER_OWNER]
	@CustID INT,
	@MVDID varchar(15),
	@OwnerType INT,
	@UserID varchar(128) NULL,
	@GroupID smallint NULL,
	@StartDate date,
	@EndDate date NULL,
	@UpdatedBy varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CREATEDATE AS DATETIME = GETDATE() AT TIME ZONE 'UTC';

	UPDATE [dbo].[Final_MemberOwner]
	SET EndDate = @EndDate
		,@UpdatedBy = @UpdatedBy
		,UpdatedDate = @CREATEDATE
	WHERE
	CustID = @CustID
	AND MVDID = @MVDID 
	AND OwnerType = @OwnerType
	AND (UserID = @UserID OR GroupID = @GroupID)
	AND StartDate = @StartDate
END