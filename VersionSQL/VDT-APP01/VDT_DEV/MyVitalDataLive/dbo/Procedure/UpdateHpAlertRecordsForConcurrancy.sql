/****** Object:  Procedure [dbo].[UpdateHpAlertRecordsForConcurrancy]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 04/17/2017
-- Description:	Update HPAlert table records of given memberId / MvdId which is being processed by particular user.
--				@ConcurrancyActionType --> 0: Lock, 1: Unlock, 2: Remove
--				04/17/2017 Based on current usecase, we are managing only Lock/Unlock of HPAlert table records.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateHpAlertRecordsForConcurrancy]
	@AlertId int = null,
	@MemberId varchar(20),
	@MvdId varchar(30) = null,
	@LockedByUser varchar(50) = null,
	@IsClosed bit = 0,
	@ConcurrancyActionType int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Later add extra check for existing locks if any

	if(@IsClosed = 0 and @ConcurrancyActionType = 0)
		begin
			--Locking workList items
			Update HPAlert
			set LockedBy = @LockedByUser
			where MemberID = @MemberId
				and StatusID = 0
		end
	else if (@ConcurrancyActionType = 1)
		begin
			--Unlocking workList items
			Update HPAlert
			set LockedBy = null
			where MemberID = @MemberId
				--and StatusID = 0
		end
END