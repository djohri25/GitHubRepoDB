/****** Object:  Procedure [dbo].[Rpt_LabDataNote]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_LabDataNote]
@ICENUMBER VARCHAR (30), @ResultID INT, @SourceName VARCHAR (50)
AS
SET NOCOUNT ON


Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup


SELECT distinct Note
FROM dbo.MainLabNote
WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers) 
and resultID = @resultID and sourceName = @SourceName and isnull(note,'') <> ''