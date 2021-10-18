/****** Object:  Procedure [dbo].[Upd_SpecialistInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_SpecialistInfo]  

@RecNum int,
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


UPDATE MainSpecialist SET
LastName = @LastName, 
FirstName = @FirstName, 
Address1 = @Address1, 
Address2 = @Address2,
City = @City, 
State = @State, 
Postal = @Postal, 
Phone = @Phone, 
PhoneCell = @PhoneCell, 
FaxPhone = @FaxPhone, 
RoleId = @RoleId, 
ModifyDate = GETUTCDATE()
WHERE RecordNumber = @RecNum