/****** Object:  Procedure [dbo].[Get_RptRecord]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns report record identified by ID passed as an argument
*/
CREATE Procedure [dbo].[Get_RptRecord]
	@ReportID varchar(50)
as

set nocount on

Select top 1 ReportName,ProcedureName,ReportPath 
From LookupCS_Report 
where ReportID = @ReportID