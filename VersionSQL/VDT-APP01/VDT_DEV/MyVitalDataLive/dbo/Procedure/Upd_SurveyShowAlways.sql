/****** Object:  Procedure [dbo].[Upd_SurveyShowAlways]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_SurveyShowAlways]  

@ICENUMBER varchar(15),
@ShowAlways bit

AS

SET NOCOUNT ON

UPDATE UserAdditionalInfo SET SurveyShowAlways = @ShowAlways, LastUpdate = getutcdate()
WHERE MVDID = @ICENUMBER