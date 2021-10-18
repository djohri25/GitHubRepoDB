/****** Object:  Procedure [dbo].[Rpt_MemberHospitals]    Committed by VersionSQL https://www.versionsql.com ******/

--Rpt_MemberHospitals S79YR53GW6

--CREATE 
--
CREATE
Procedure [dbo].Rpt_MemberHospitals
	@ICENUMBER varchar(15)
As

Select [Name], Address1, 
Address2, City, [State], [Postal] ZipCode, Website, Note, 
(Select PlacesTypeName From LookupPlacesTypeId Where 
PlacesTypeId = MainPlaces.PlacesTypeId) As [Type],
dbo.FormatPhone(Phone) As Phone,
dbo.FormatPhone(FaxPhone) As Fax

From MainPlaces Where ICENUMBER = @ICENUMBER