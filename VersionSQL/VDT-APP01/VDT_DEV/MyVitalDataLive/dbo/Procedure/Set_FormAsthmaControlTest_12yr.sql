/****** Object:  Procedure [dbo].[Set_FormAsthmaControlTest_12yr]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/13/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormAsthmaControlTest_12yr]
	@MVDID varchar(20),
	@WorkID int,
	@WorkComment varchar(100),
	@ShortnessBreathID int,
	@ShortnessBreathComment varchar(100),
	@WakeupID int,
	@WakeupComment varchar(100),
	@InhalerID int,
	@InhalerComment varchar(100),
	@ControlID int,
	@ControlComment varchar(100),
	@TotalScore int,
	@CreatedBy varchar(50),
	@GaveToParent bit = 0,
	@ShippedToHome bit = 0,	
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @totScore int, @UserType varchar(10)	
	
	select @totScore = 
		case isnull(@WorkID,'-1')
		when '-1' then 0
		else CONVERT(int,@WorkID)
		end +
		case isnull(@ShortnessBreathID,'-1')
		when '-1' then 0
		else CONVERT(int,@ShortnessBreathID)
		end +
		case isnull(@WakeupID,'-1')
		when '-1' then 0
		else CONVERT(int,@WakeupID)
		end +
		case isnull(@InhalerID,'-1')
		when '-1' then 0
		else CONVERT(int,@InhalerID)
		end +
		case isnull(@ControlID,'-1')
		when '-1' then 0
		else CONVERT(int,@ControlID)
		end
	
	set @TotalScore = @totScore
	
	INSERT INTO FormAsthmaControlTest_12yr
           (MVDID
		  ,WorkID
		  ,WorkComment
		  ,ShortnessBreathID
		  ,ShortnessBreathComment
		  ,WakeupID
		  ,WakeupComment
		  ,InhalerID
		  ,InhalerComment
		  ,ControlID
		  ,ControlComment
		  ,TotalScore
           ,GaveToParent
           ,ShippedToHome		  
		  ,CreatedBy)
     VALUES
     (
		  @MVDID
		  ,@WorkID
		  ,@WorkComment
		  ,@ShortnessBreathID
		  ,@ShortnessBreathComment
		  ,@WakeupID
		  ,@WakeupComment
		  ,@InhalerID
		  ,@InhalerComment
		  ,@ControlID
		  ,@ControlComment
		  ,@TotalScore
           ,@GaveToParent
           ,@ShippedToHome  		  
		  ,@CreatedBy  
     )
     
     select @FormID = @@IDENTITY
     
     declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId
	from Link_MemberId_MVD_Ins
	where MVDId = @MVDID
     
     select @noteText = 'Asthma Control Test Form Saved. '
     
     if(ISNULL(@GaveToParent,0) = 1)
     begin
		select @noteText = @noteText + 'Gave to parent. '
     end
     
     if(ISNULL(@ShippedToHome,0) = 1)
     begin
		select @noteText = @noteText + 'Shipped to home address. '
     end     
     
     if exists(select top 1 * from MDUser where Username =  @CreatedBy)
     begin
		set @UserType = 'MD'
	end
	else
	begin
		set @UserType = 'HP'		
	end
     
	insert into HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,
		datemodified,modifiedby,ModifiedByType,
		SendToHP,SendToPCP,SendToNurture,SendToNone,LinkedFormType,LinkedFormID)
	values(@MVDID,@noteText,0,GETUTCDATE(),@CreatedBy,@UserType,
		GETUTCDATE(),@CreatedBy,@UserType,
		0,0,0,0,'ACT_12yr',@FormID)
     
          
     set @Result = 0
END