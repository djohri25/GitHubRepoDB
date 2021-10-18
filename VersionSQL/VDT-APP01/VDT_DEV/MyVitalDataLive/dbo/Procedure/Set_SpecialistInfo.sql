/****** Object:  Procedure [dbo].[Set_SpecialistInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_SpecialistInfo]  

@ICENUMBER varchar(15),
@LastName varchar(50),
@FirstName varchar(50),
@Address1 varchar(50),
@Address2 varchar(50),
@City varchar(50),
@State varchar(2),
@Postal varchar(5),
@Phone varchar(10),
@PhoneCell varchar(10),
@FaxPhone varchar(10),
@RoleId int

as

set nocount on

INSERT INTO MainSpecialist (ICENUMBER, LastName, FirstName, Address1, Address2,
City, State, Postal, Phone, PhoneCell, FaxPhone, RoleId, 
CreationDate, ModifyDate) VALUES
(@ICENUMBER, @LastName, @FirstName, @Address1, @Address2, @City, @State,
@Postal, @Phone, @PhoneCell, @FaxPhone, @RoleId,
GETUTCDATE(), GETUTCDATE())