/****** Object:  Procedure [dbo].[Rpt_LabDataResult]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_LabDataResult]
@ICENUMBER VARCHAR (15), @OrderID INT, @SourceName VARCHAR (50)
AS
SET NOCOUNT ON


Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup



if (isnull(@SourceName,'') = '')
BEGIN

SELECT distinct isnull(ResultName,'') + isnull(' (' + Code + ')','') 
	+ isnull(': ' + ResultValue,'') + isnull(' ' + ResultUnits,'')
	+ case isnull(AbnormalFlag,'')
		when '' then ''
		else ' (' + AbnormalFlag + ')'
	end as ResultFull, 
	isnull(ResultName,'') + isnull(' (' + Code + ')','') as ResultName,
	dbo.Get_LabResultValue(ResultValue,RangeLow,RangeHigh,'InRange') as ResultInRange,
	dbo.Get_LabResultValue(ResultValue,RangeLow,RangeHigh,'OutOfRange') as ResultOutOfRange,
	isnull(RangeAlpha,'') as ReferenceRange,
	ResultUnits as Unit,
	ReportedDate as ResultDate, AbnormalFlag,ICENUMBER,
	resultID, sourceName
FROM dbo.MainLabResult
WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers)
and OrderID = @OrderID --and sourceName = @SourceName
ORDER BY ReportedDate desc

END
ELSE
BEGIN

SELECT distinct isnull(ResultName,'') + isnull(' (' + Code + ')','') 
	+ isnull(': ' + ResultValue,'') + isnull(' ' + ResultUnits,'')
	+ case isnull(AbnormalFlag,'')
		when '' then ''
		else ' (' + AbnormalFlag + ')'
	end as ResultFull, 
	isnull(ResultName,'') + isnull(' (' + Code + ')','') as ResultName,
	dbo.Get_LabResultValue(ResultValue,RangeLow,RangeHigh,'InRange') as ResultInRange,
	dbo.Get_LabResultValue(ResultValue,RangeLow,RangeHigh,'OutOfRange') as ResultOutOfRange,
	isnull(RangeAlpha,'') as ReferenceRange,
	ResultUnits as Unit,
	ReportedDate as ResultDate, AbnormalFlag,ICENUMBER,
	resultID, sourceName
FROM dbo.MainLabResult
WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers)
and OrderID = @OrderID and sourceName = @SourceName
ORDER BY ReportedDate desc

END