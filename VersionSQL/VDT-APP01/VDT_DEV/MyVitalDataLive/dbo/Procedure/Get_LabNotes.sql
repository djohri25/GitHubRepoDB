/****** Object:  Procedure [dbo].[Get_LabNotes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_LabNotes]
@ICENUMBER VARCHAR (15), @ResultID VARCHAR (50), @SourceName VARCHAR (50)
AS
SET NOCOUNT ON

SELECT Note
FROM dbo.mainLabNote
WHERE ICENUMBER = @ICENUMBER and resultID = @ResultID
	and isnull(note,'') <> '' and sourceName = @SourceName