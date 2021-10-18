/****** Object:  Procedure [dbo].[Get_HealthTestDetail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_HealthTestDetail] 

	@ICENUMBER varchar(15),
	@TestId int
As

SET NOCOUNT ON

SELECT RecordNumber, TestId, DateDone,
Month(DateDone) As MonMonth, Year(DateDone) As MonYear, Day(DateDone) As MonDay
FROM MainHealthTest
WHERE ICENUMBER = @ICENUMBER AND TestId = @TestId
ORDER BY DateDone