/****** Object:  Procedure [dbo].[Get_PlaceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_PlaceInfo] 
	@ICENUMBER varchar(15),
	@Language BIT = 1
As

Set Nocount On


Select RecordNumber, [Name], Address1, 
Address2, City, State, Postal, Website, Note, PlacesTypeId,
(
SELECT TOP 1 
	CASE @Language
		WHEN  1 
			THEN PlacesTypeName
		WHEN 0 
			THEN PlacesTypeNameSpanish 
	END 
From LookupPlacesTypeId Where 
PlacesTypeId = MainPlaces.PlacesTypeId) As PlaceName,
Substring(Phone,1,3) As PhoneArea,
Substring(Phone,4,3) As PhonePrefix,
Substring(Phone,7,4) As PhoneSuffix,
Substring(FaxPhone,1,3) As FaxArea,
Substring(FaxPhone,4,3) As FaxPrefix,
Substring(FaxPhone,7,4) As FaxSuffix,
dbo.FormatPhone(Phone) As FullPhone,
dbo.FormatPhone(FaxPhone) As FullFax

From MainPlaces Where ICENUMBER = @ICENUMBER