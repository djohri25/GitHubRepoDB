/****** Object:  Procedure [dbo].[uspInsertDataScienceGeoCodes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspInsertDataScienceGeoCodes]
AS

/*
Author: Sunil Nokku			
Date: 20210217
Description: To Import DataScience Geocodes from 135 to 134
EXEC uspInsertDataScienceGeoCodes
*/
BEGIN

SET NOCOUNT ON;
	
	TRUNCATE TABLE MemberGeocode
	DROP INDEX IX_MemberID ON MemberGeocode

	INSERT INTO [dbo].[MemberGeocode]
           ([MemberID]
           ,[Lat]
           ,[Lon]
           ,[GeoCode])
	SELECT [MemberID]
           ,[Lat]
           ,[Lon]
           ,[GeoCode]
	FROM [VD-RPT02].Datalogy.dbo.MemberGeocode

	CREATE NONCLUSTERED INDEX IX_MemberID ON MemberGeocode (MemberID)

	TRUNCATE TABLE AddresLatLonGeoCodeMaster
	
	INSERT INTO [dbo].[AddresLatLonGeoCodeMaster]
           ([SummaryQuery]
           ,[ResultsAddress]
           ,[Lat]
           ,[Lon]
           ,[BlockFIPS]
           ,[rownumber])
	SELECT [SummaryQuery]
           ,[ResultsAddress]
           ,[Lat]
           ,[Lon]
           ,[BlockFIPS]
           ,[rownumber]
	FROM [VD-RPT02].Datalogy.dbo.AddresLatLonGeoCodeMaster

END