/****** Object:  Procedure [dbo].[Get_CareSpace_HpAlertStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 03/08/2017
-- Description:	SP returns the current status of HPAlert record
-- =============================================
CREATE PROCEDURE [dbo].[Get_CareSpace_HpAlertStatus] 
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select *
	from HPAlert
	where ID = @ID

END