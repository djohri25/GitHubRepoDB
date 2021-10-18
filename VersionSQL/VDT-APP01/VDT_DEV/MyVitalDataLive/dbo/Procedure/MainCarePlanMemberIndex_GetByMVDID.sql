/****** Object:  Procedure [dbo].[MainCarePlanMemberIndex_GetByMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Nelanwer
-- Create date: 05/14/2019
-- Description:	Gets the member main plan index by MVDID
-- =============================================
CREATE PROCEDURE [dbo].[MainCarePlanMemberIndex_GetByMVDID]
	-- Add the parameters for the stored procedure here
	@MVDID VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		CarePlanID, 
		CarePlanDate, 
		Author, 
		CarePlanType, 
		CarePlanStatus 
  FROM MainCarePlanMemberIndex 
  WHERE MVDID=@MVDID
  and IsNull(cpInactiveDate,'1900-01-01') = '1900-01-01'
  ORDER BY CarePlanDate DESC
END