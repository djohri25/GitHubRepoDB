/****** Object:  Procedure [dbo].[Set_HPMemberMessage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/16/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPMemberMessage]
	@InsMemberID varchar(50),
	@Owner varchar(50),
	@UserType varchar(20) = 'HP',
	@Note varchar(2000),
	@CustID int,	
	@SendToHP bit,
	@SendToPCP bit,
	@SendToNurture bit,
	@SendToNone bit,
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @newNoteID int,
		@curDate datetime,
		@mvdid varchar(50)
	
	select @mvdid = MVDId
	from Link_MemberId_MVD_Ins
	where Cust_ID = @CustID and
		InsMemberId = @InsMemberID
	
	if(@mvdid is not null)
	begin
		select @curDate = getutcdate()
				
		insert into HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,datemodified,modifiedby,ModifiedByType,
			SendToHP,SendToPCP,SendToNurture,SendToNone)
		values(@MVDID,@Note,0,@curDate,@Owner,@UserType,@curDate,@Owner,@UserType,
			@SendToHP,@SendToPCP,@SendToNurture,@SendToNone)

		set @Result = 0
	end
	else
	begin
		set @Result = -1
	end
	
END