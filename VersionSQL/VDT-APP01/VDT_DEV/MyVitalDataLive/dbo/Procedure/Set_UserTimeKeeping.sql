/****** Object:  Procedure [dbo].[Set_UserTimeKeeping]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Set_UserTimeKeeping]
(
	@ID	INT = NULL, 
	@Username  varchar(30),
	@CustId  int,
	@StartDate  datetime,
	@EndDate  datetime = null,
	@Note  varchar(max),
	@MemberId varchar(20)=null,
	@NewID	INT OUTPUT
)

AS
BEGIN

	IF (@ID is null)
		BEGIN
			INSERT INTO dbo.UserTimeKeeping(UserName, CustId, StartDate, EndDate, Note,MemberId)
			Select @UserName, @CustID, @StartDate, @EndDate, @Note, @MemberId

			Select @NewID = SCOPE_IDENTITY();
		END
	ELSE 
		BEGIN
			Declare @currentStartDate datetime, @currentNote varchar(max), @currentEndDate datetime
			select @currentStartDate = StartDate, @currentEndDate = EndDate, @currentNote = Note from UserTimeKeeping where Id = @ID

			UPDATE dbo.UserTimeKeeping
			SET 
				StartDate = ISNULL(@StartDate,@currentStartDate), 
				EndDate = ISNULL(@EndDate,@currentEndDate), 
				Note = ISNULL(@Note,@currentNote)
				--,MemberId = @MemberId
			WHERE Id = @ID 
			--and UserName = @UserName and CustID = @CustID
		END
END