/****** Object:  Procedure [dbo].[Set_FormAsthmaControlTest_4_11yr]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/13/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormAsthmaControlTest_4_11yr]
	@MVDID varchar(20),
	@AsthmaTodayID int,
	@AsthmaTodayComment varchar(100),
	@ProblemExerciseID int,
	@ProblemExerciseComment varchar(100),
	@CoughID int,
	@CoughComment varchar(100),
	@WakeupID int,
	@WakeupComment varchar(100),
	@DaytimeSymptomsID int,
	@DaytimeSymptomsComment varchar(100),
	@WheezeID int,
	@WheezeComment varchar(100),
	@WakeupPerMonthID int,
	@WakeupPerMonthComment varchar(100),
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
		CONVERT(int, @AsthmaTodayID) +
		CONVERT(int, @ProblemExerciseID) +
		CONVERT(int, @CoughID) +
		CONVERT(int, @WakeupID) +
		CONVERT(int, @DaytimeSymptomsID) +
		CONVERT(int, @WheezeID) +
		CONVERT(int, @WakeupPerMonthID)
	
	set @TotalScore = @totScore
	
	INSERT INTO FormAsthmaControlTest_4_11yr
           (MVDID
           ,AsthmaTodayID
           ,AsthmaTodayComment
           ,ProblemExerciseID
           ,ProblemExerciseComment
           ,CoughID
           ,CoughComment
           ,WakeupID
           ,WakeupComment
           ,DaytimeSymptomsID
           ,DaytimeSymptomsComment
           ,WheezeID
           ,WheezeComment
           ,WakeupPerMonthID
           ,WakeupPerMonthComment
           ,TotalScore
           ,GaveToParent
           ,ShippedToHome	           
           ,CreatedBy)
     VALUES
     (
           @MVDID
           ,@AsthmaTodayID
           ,@AsthmaTodayComment
           ,@ProblemExerciseID
           ,@ProblemExerciseComment
           ,@CoughID
           ,@CoughComment
           ,@WakeupID
           ,@WakeupComment
           ,@DaytimeSymptomsID
           ,@DaytimeSymptomsComment
           ,@WheezeID
           ,@WheezeComment
           ,@WakeupPerMonthID
           ,@WakeupPerMonthComment
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
		0,0,0,0,'ACT_4_11yr',@FormID)
		     
     set @Result = 0
END