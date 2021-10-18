/****** Object:  Procedure [dbo].[Get_RptProcedureName]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the stored procedure name which prepares data
	for report identified by ID passed as an argument
*/
create Procedure [dbo].[Get_RptProcedureName]
	@ReportID varchar(50)
as

set nocount on

Select top 1 ProcedureName From LookupCS_Report where ReportID = @ReportID