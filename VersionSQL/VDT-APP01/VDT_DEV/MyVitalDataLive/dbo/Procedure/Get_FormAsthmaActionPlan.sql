/****** Object:  Procedure [dbo].[Get_FormAsthmaActionPlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormAsthmaActionPlan]
	@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 ID
      ,MVDID
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
      ,Created
      ,CreatedBy
      ,ModifiedDate
      ,ModifiedBy
      ,dbo.GetAAPMedicationList(f.ID,'green') as 'GreenMedList'
      ,dbo.GetAAPMedicationList(f.ID,'yellow') as 'YellowMedList'
      ,dbo.GetAAPMedicationList(f.ID,'red') as 'RedMedList'
      ,isnull(GaveToParent,0) as GaveToParent
      ,isnull(ShippedToHome,0) as ShippedToHome
	  ,'' as FUllName
  FROM FormAsthmaActionPlan f
  where MVDID = @MVDID
  order by Created desc
END