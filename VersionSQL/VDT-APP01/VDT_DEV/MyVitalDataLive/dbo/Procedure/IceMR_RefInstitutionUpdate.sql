/****** Object:  Procedure [dbo].[IceMR_RefInstitutionUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_RefInstitutionUpdate]  

@ICENUMBER varchar(15),
@Name varchar(50),
@Address1 varchar(50),
@City varchar(50),
@State varchar(2),
@Postal varchar(5),
@Phone varchar(10),
@FaxPhone varchar(10),
@Website varchar(200),
@RoomLoc varchar(50),
@Direction varchar(150),
@PlacesTypeID int



AS


SET NOCOUNT ON

INSERT INTO MainPlaces (ICENUMBER, [Name], Address1, City, State, Postal,
Phone, FaxPhone, Website, RoomLoc, Direction, PlacesTypeId, CreationDate, 
ModifyDate) VALUES (@ICENUMBER, @Name, @Address1, @City, @State, @Postal,
@Phone, @FaxPhone, @Website, @RoomLoc, @Direction, @PlacesTypeId,
GETUTCDATE(), GETUTCDATE())