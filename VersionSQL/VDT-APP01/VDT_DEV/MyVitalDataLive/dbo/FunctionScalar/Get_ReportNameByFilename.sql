/****** Object:  Function [dbo].[Get_ReportNameByFilename]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/24/2010
-- Description:	Get report name based on report file name
-- =============================================
CREATE FUNCTION [dbo].[Get_ReportNameByFilename]
(
	@fileName varchar(50)
)
RETURNS varchar(100)
AS
BEGIN	
	DECLARE @reportName varchar(50)

	select @reportName = reportName from dbo.LookupCS_Report where reportpath like ('%/' + @filename)

	RETURN @reportName

END