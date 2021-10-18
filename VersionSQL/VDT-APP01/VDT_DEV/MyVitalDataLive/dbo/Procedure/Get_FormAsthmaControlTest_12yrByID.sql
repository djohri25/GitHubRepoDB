/****** Object:  Procedure [dbo].[Get_FormAsthmaControlTest_12yrByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormAsthmaControlTest_12yrByID]
	@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 ID
      ,MVDID
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
      ,Created
      ,CreatedBy
      ,ModifiedDate
      ,ModifiedBy
      ,isnull(GaveToParent,0) as GaveToParent
      ,isnull(ShippedToHome,0) as ShippedToHome      
  FROM FormAsthmaControlTest_12yr f
  where ID = @ID
  order by Created desc
END