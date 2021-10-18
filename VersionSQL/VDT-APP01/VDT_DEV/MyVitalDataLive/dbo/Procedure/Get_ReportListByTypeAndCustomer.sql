/****** Object:  Procedure [dbo].[Get_ReportListByTypeAndCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/11/2008
-- Description:	Return the list of specified type
--		reports
-- EXEC [dbo].[Get_ReportListByTypeAndCustomer] @Type = 'HP', @CustomerID = 10
-- =============================================
CREATE PROCEDURE [dbo].[Get_ReportListByTypeAndCustomer]
	@Type varchar(50),
	@CustomerID varchar(50)
AS

BEGIN
	SET NOCOUNT ON;

	SELECT ReportID, ReportName, ReportPath, ReportGroup, TemplateName, TemplateID, ReportParamsJSON
	FROM dbo.LookupCS_Report 
	WHERE type = @Type
	AND active = 1
	AND @CustomerID in (SELECT data FROM dbo.Split(Cust_IDs,','))
	ORDER BY ReportID
END