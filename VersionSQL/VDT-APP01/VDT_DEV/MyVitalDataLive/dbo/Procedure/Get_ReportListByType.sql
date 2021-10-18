/****** Object:  Procedure [dbo].[Get_ReportListByType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/11/2008
-- Description:	Return the list of specified type reports
-- EXEC dbo.Get_ReportListByType @Type = 'HP'
-- =============================================
CREATE PROCEDURE [dbo].[Get_ReportListByType]
	@Type VARCHAR(50)
AS

BEGIN

	SET NOCOUNT ON;

	SELECT ReportID,ReportName,ReportPath, ReportGroup, TemplateName, TemplateID, ReportParamsJSON
	FROM dbo.LookupCS_Report 
	WHERE [Type] = @Type 
	AND Active = 1
	ORDER BY ReportID

END