/****** Object:  Procedure [dbo].[Get_LabResult]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_LabResult]
@ICENUMBER VARCHAR (15), @OrderID VARCHAR (50), @SourceName VARCHAR (50)
AS
SET NOCOUNT ON

SELECT resultID,isnull(ResultName,'') + isnull(': ' + ResultValue,'') + isnull(' ' + ResultUnits,'') as Result,	
	CONVERT(VARCHAR(30),ISNULL(ReportedDate,''),101) as ResultDate, AbnormalFlag, RangeAlpha as ReferenceRange, SourceName
FROM dbo.MainLabResult
WHERE ICENUMBER = @ICENUMBER and orderID = @OrderID and sourceName = @SourceName
ORDER BY reportedDate desc