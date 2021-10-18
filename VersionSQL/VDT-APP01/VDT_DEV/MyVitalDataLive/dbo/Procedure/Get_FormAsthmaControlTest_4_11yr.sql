/****** Object:  Procedure [dbo].[Get_FormAsthmaControlTest_4_11yr]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormAsthmaControlTest_4_11yr]
	@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 ID
      ,MVDID
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
      ,Created
      ,CreatedBy
      ,ModifiedDate
      ,ModifiedBy
      ,isnull(GaveToParent,0) as GaveToParent
      ,isnull(ShippedToHome,0) as ShippedToHome      
  FROM FormAsthmaControlTest_4_11yr f
  where MVDID = @MVDID
  order by Created desc
END