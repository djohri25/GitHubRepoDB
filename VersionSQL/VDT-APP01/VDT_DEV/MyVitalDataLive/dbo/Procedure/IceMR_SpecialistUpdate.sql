/****** Object:  Procedure [dbo].[IceMR_SpecialistUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_SpecialistUpdate]  

@ICENUMBER varchar(15),
@FirstName varchar(50),
@Address1 varchar(50),
@City varchar(50),
@State varchar(2),
@Postal varchar(5),
@Specialty varchar(50),
@Phone varchar(10),
@FaxPhone varchar(10),
@NurseName varchar(50),
@NursePhone varchar(10),
@RoleID int



AS


SET NOCOUNT ON

INSERT INTO MainSpecialist (ICENUMBER, LastName, Address1, City, State, Postal,
Specialty, Phone, FaxPhone, NurseName, NursePhone, RoleID, CreationDate, 
ModifyDate) VALUES (@ICENUMBER, @FirstName, @Address1, @City, @State, @Postal,
@Specialty, @Phone, @FaxPhone, @NurseName, @NursePhone, @RoleID,
GETUTCDATE(), GETUTCDATE())