/****** Object:  Procedure [dbo].[GetWidgetUserPreferences]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC dbo.GetWidgetUserPreferences @UserID = 'rcheruku', @CustID = 10
------------------------------------------------
--	User		Date		Updates
------------------------------------------------
--	dpatel		11/12/2018	Updated proc to accept ApplicationId parameter that will differentiate Widgets Preferences per customer/user combination for particular application.
-- =============================================
CREATE PROCEDURE [dbo].[GetWidgetUserPreferences]
	 @UserID VARCHAR(50)
	,@CustID VARCHAR(10)
	,@ApplicationId int = NULL
AS
BEGIN

	SET NOCOUNT ON;

	--Hard coded only till front-end code is ready to pass ApplicationId
	--Table currently has entries only for PlanLink - ApplicationId - 2
	if @ApplicationId is null
		begin
			set @ApplicationId = 2
		end

	DECLARE @Results TABLE 
	(
	  UserPreferenceId INT, UserID VARCHAR(50), CustID INT, WidgetId INT, WidgetName VARCHAR(100), WidgetListTitle VARCHAR(250), WidgetTemplateUrl VARCHAR(8000)
	 ,WidgetJSFile VARCHAR(8000), WidgetSpecifcEvents VARCHAR(MAX), DefaultLayout VARCHAR(8000), OrderNumber INT, WidgetGroup VARCHAR(100), IsUserDefault BIT
	)

	INSERT INTO @Results
	(
	  UserPreferenceId, UserID, CustID, WidgetId, WidgetName, WidgetListTitle, WidgetTemplateUrl
	 ,WidgetJSFile, WidgetSpecifcEvents, DefaultLayout, OrderNumber, WidgetGroup, IsUserDefault
	)

	SELECT
	 UP.ID as UserPreferenceId
	,UP.UserID
	,UP.CustID
	,W.ID as WidgetId
	,W.WidgetName
	,W.WidgetListTitle
	,W.WidgetTemplateUrl
	,W.WidgetJSFile
	,W.WidgetSpecifcEvents
	,COALESCE(NULLIF(UP.UserDefinedLayout,''), NULLIF(W.DefaultLayout,'')) AS DefaultLayout
	,W.OrderNumber
	,W.WidgetGroup
	,CAST(CASE WHEN UP.UserDefinedLayout IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsUserDefault
	FROM dbo.Widget W
	JOIN dbo.UserPreference UP ON W.ID = UP.ProductID 
	JOIN dbo.ProductType PT ON UP.ProductTypeID = PT.ID
	WHERE UP.ApplicationId = @ApplicationId
	AND UP.CustID = @CustID
	AND UP.UserID = @UserID

	INSERT INTO @Results
	(
		UserPreferenceId, UserID, CustID, WidgetId, WidgetName, WidgetListTitle, WidgetTemplateUrl
		,WidgetJSFile, WidgetSpecifcEvents, DefaultLayout, OrderNumber, WidgetGroup, IsUserDefault
	)

	SELECT
		UP.ID as UserPreferenceId
	,UP.UserID
	,UP.CustID
	,W.ID as WidgetId
	,W.WidgetName
	,W.WidgetListTitle
	,W.WidgetTemplateUrl
	,W.WidgetJSFile
	,W.WidgetSpecifcEvents
	,COALESCE(NULLIF(UP.UserDefinedLayout,''), NULLIF(W.DefaultLayout,'')) AS DefaultLayout
	,W.OrderNumber
	,W.WidgetGroup
	,CAST(CASE WHEN UP.UserDefinedLayout IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsUserDefault
	FROM dbo.Widget W
	JOIN dbo.UserPreference UP ON W.ID = UP.ProductID 
	JOIN dbo.ProductType PT ON UP.ProductTypeID = PT.ID
	WHERE UP.ApplicationId = @ApplicationId
	AND UP.CustID = @CustID
	AND UP.UserID IS NULL
	AND NOT EXISTS (SELECT 1 FROM @Results R WHERE R.WidgetId = W.ID)

	SELECT 
	 UserPreferenceId, UserID, CustID, WidgetId, WidgetName, WidgetListTitle, WidgetTemplateUrl
	,WidgetJSFile, WidgetSpecifcEvents, DefaultLayout, OrderNumber, WidgetGroup, IsUserDefault
	FROM @Results

			-- Record SP Log
	DECLARE @params NVARCHAR(1000) = NULL
	SET @params = LEFT(
	 '@UserID=' + ISNULL(CAST(@UserID AS VARCHAR(100)), 'null') + ';' 
	+'@CustID=' + ISNULL(CAST(@CustID AS VARCHAR(100)), 'null') + ';' 
	, 1000);
	
	EXEC dbo.Set_StoredProcedures_Log '[dbo].[DashboardCareflowList]', @UserID, NULL, @params

END