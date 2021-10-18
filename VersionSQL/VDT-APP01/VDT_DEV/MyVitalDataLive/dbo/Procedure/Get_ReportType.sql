/****** Object:  Procedure [dbo].[Get_ReportType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_ReportType]

as

set nocount on

Select ReportID,ReportName From LookupCS_Report Order By ReportName