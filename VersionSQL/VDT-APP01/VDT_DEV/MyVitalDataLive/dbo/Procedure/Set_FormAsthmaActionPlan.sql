/****** Object:  Procedure [dbo].[Set_FormAsthmaActionPlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/13/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormAsthmaActionPlan]
	@MVDID varchar(20),
	@BestPeakFlow varchar(50),
	@FormDate date,
	@Triggers varchar(100),
	@ProviderName varchar(100),
	@ProviderPhone varchar(50),
	@NextAppt varchar(50),
	@GreenPeakFlowGreaterThan varchar(50),
	@GreenSeeProviderHowOften varchar(50),
	@GreenMedBeforeExercise1 varchar(50),
	@GreenMedBeforeExercise2 varchar(50),
	@GreenMedBeforeExercise3 varchar(50),
	@GreenOtherMed1 varchar(50),
	@GreenOtherMed2 varchar(50),
	@GreenOtherMed3 varchar(50),
	@YellowPeakFlowStart varchar(50),
	@YellowPeakFlowEnd varchar(50),
	@YellowInZoneFor varchar(50),
	@YellowMedTake1 varchar(50),
	@YellowMedHowMuch1 varchar(50),
	@YellowMedTake2 varchar(50),
	@YellowMedHowMuch2 varchar(50),
	@YellowAdd varchar(50),
	@YellowAddFor varchar(50),
	@RedPeakFlow varchar(50),
	@RedAdd1 varchar(50),
	@RedAddHowMuch1 varchar(50),
	@RedAdd2 varchar(50),
	@RedAddHowMuch2 varchar(50),
	@CreatedBy varchar(50),
	@GreenMedList varchar(max),
	@YellowMedList varchar(max),
	@RedMedList varchar(max),
	@GaveToParent bit = 0,
	@ShippedToHome bit = 0,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

	INSERT INTO FormAsthmaActionPlan
           (MVDID
           ,BestPeakFlow
           ,FormDate
           ,[Triggers]
           ,ProviderName
           ,ProviderPhone
           ,NextAppt
           ,GreenPeakFlowGreaterThan
           ,GreenSeeProviderHowOften
           ,GreenMedBeforeExercise1
           ,GreenMedBeforeExercise2
           ,GreenMedBeforeExercise3
           ,GreenOtherMed1
           ,GreenOtherMed2
           ,GreenOtherMed3
           ,YellowPeakFlowStart
           ,YellowPeakFlowEnd
           ,YellowInZoneFor
           ,YellowMedTake1
           ,YellowMedHowMuch1
           ,YellowMedTake2
           ,YellowMedHowMuch2
           ,YellowAdd
           ,YellowAddFor
           ,RedPeakFlow
           ,RedAdd1
           ,RedAddHowMuch1
           ,RedAdd2
           ,RedAddHowMuch2
           ,GaveToParent
           ,ShippedToHome
           ,CreatedBy)
     VALUES
     (
           @MVDID
           ,@BestPeakFlow
           ,@FormDate
           ,@Triggers
           ,@ProviderName
           ,@ProviderPhone
           ,@NextAppt
           ,@GreenPeakFlowGreaterThan
           ,@GreenSeeProviderHowOften
           ,@GreenMedBeforeExercise1
           ,@GreenMedBeforeExercise2
           ,@GreenMedBeforeExercise3
           ,@GreenOtherMed1
           ,@GreenOtherMed2
           ,@GreenOtherMed3
           ,@YellowPeakFlowStart
           ,@YellowPeakFlowEnd
           ,@YellowInZoneFor
           ,@YellowMedTake1
           ,@YellowMedHowMuch1
           ,@YellowMedTake2
           ,@YellowMedHowMuch2
           ,@YellowAdd
           ,@YellowAddFor
           ,@RedPeakFlow
           ,@RedAdd1
           ,@RedAddHowMuch1
           ,@RedAdd2
           ,@RedAddHowMuch2
           ,@GaveToParent
           ,@ShippedToHome           
           ,@CreatedBy     
     )
     
     select @FormID = @@IDENTITY
     
     insert into LinkAAPFormMedication(FormID,MedicationID,HowMuch,HowOften)
     select @FormID, Name, HowMuch,HowOften
     from dbo.GetAAPMedicationTable(@GreenMedList)
     
     insert into LinkAAPFormMedication(FormID,MedicationID,HowMuch,HowOften)
     select @FormID, Name, HowMuch,HowOften
     from dbo.GetAAPMedicationTable(@YellowMedList)
     
     insert into LinkAAPFormMedication(FormID,MedicationID,HowMuch,HowOften)
     select @FormID, Name, HowMuch,HowOften
     from dbo.GetAAPMedicationTable(@RedMedList)
     
     declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId
	from Link_MemberId_MVD_Ins
	where MVDId = @MVDID
     
     select @noteText = 'Asthma Action Plan Form Saved. '
     
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
		0,0,0,0,'AAP',@FormID)
     
     set @Result = 0
END