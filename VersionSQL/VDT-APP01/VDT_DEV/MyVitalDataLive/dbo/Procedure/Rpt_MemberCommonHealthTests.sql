/****** Object:  Procedure [dbo].[Rpt_MemberCommonHealthTests]    Committed by VersionSQL https://www.versionsql.com ******/

--Rpt_MemberCommonHealthTests S79YR53GW6
--CREATE 
--
CREATE 
Procedure [dbo].Rpt_MemberCommonHealthTests 
	@ICENUMBER varchar(15)
As

Set Nocount On

SELECT DISTINCT(MHT.TestID), LHT.TestName HealthTestsName, dbo.ConcatenateHealthTestDates(@IceNumber,MHT.TestID) DateDoneList
FROM MainHealthTest MHT JOIN LookupHealthTest LHT ON MHT.TestID = LHT.TestID 
WHERE MHT.IceNumber = @ICENUMBER
ORDER BY LHT.TestName