/****** Object:  Procedure [dbo].[SET_MEMBER_OWNER]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Save Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[SET_MEMBER_OWNER]
	@CustID INT,
	@MVDID varchar(15),
	@OwnerType INT,
	@UserID varchar(128) NULL,
	@GroupID smallint NULL,
	@StartDate date,
	@EndDate date NULL,
	@CreatedBy varchar(50),
	@OwnerName varchar(50) NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CREATEDATE AS DATETIME = GETDATE() AT TIME ZONE 'UTC';

	INSERT INTO [dbo].[Final_MemberOwner]
	(CustID,MVDID,OwnerType,UserID,GroupID,StartDate,EndDate,CreatedBy,CreatedDate,OwnerName)
	VALUES(@CustID, @MVDID, @OwnerType, @UserID, @GroupID, @StartDate, @EndDate, @CreatedBy, @CREATEDATE, @OwnerName);
END