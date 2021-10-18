/****** Object:  Procedure [dbo].[Get_SurveyShowAlways]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the flag indicating whether the user selected "Show Always" Survey pages on Logg in
*/
Create Procedure [dbo].[Get_SurveyShowAlways]  

@ICENUMBER varchar(15)

as

set nocount on

BEGIN

	SELECT isNull(SurveyShowAlways,'0') FROM dbo.UserAdditionalInfo WHERE MVDID = @ICENUMBER

END