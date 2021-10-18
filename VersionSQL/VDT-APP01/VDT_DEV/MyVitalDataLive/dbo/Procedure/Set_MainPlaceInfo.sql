/****** Object:  Procedure [dbo].[Set_MainPlaceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_MainPlaceInfo]  

@ICENUMBER varchar(15),
@Name varchar(50),
@Address1 varchar(50),
@Address2 varchar(50),
@City varchar(50),
@State varchar(2),
@Postal varchar(5),
@Phone varchar(10),
@FaxPhone varchar(10),
@Website varchar(200),
@Note varchar(250),
@PlacesTypeId int
as

set nocount on

INSERT INTO MainPlaces (ICENUMBER, [Name], Address1, Address2,
City, State, Postal, Phone, FaxPhone, Website,
PlacesTypeId, Note, CreationDate, ModifyDate) VALUES
(@ICENUMBER, @Name, @Address1, @Address2, @City, @State,
@Postal, @Phone, @FaxPhone, @Website, @PlacesTypeId,
@Note, GETUTCDATE(), GETUTCDATE())