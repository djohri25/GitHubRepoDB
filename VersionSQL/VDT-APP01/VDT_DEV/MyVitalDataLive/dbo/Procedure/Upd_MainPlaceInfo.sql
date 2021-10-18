/****** Object:  Procedure [dbo].[Upd_MainPlaceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_MainPlaceInfo]  

@RecNum int,
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

UPDATE MainPlaces SET
[Name] = @Name,
Address1 = @Address1,
Address2 = @Address2,
City = @City,
State = @State,
Postal = @Postal,
Phone = @Phone,
FaxPhone = @FaxPhone,
Website = @Website,
Note = @Note,
PlacesTypeId = @PlacesTypeId,
ModifyDate = GETUTCDATE()
WHERE RecordNumber = @RecNum