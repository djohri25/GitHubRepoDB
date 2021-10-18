/****** Object:  Procedure [dbo].[Set_MainInsuranceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_MainInsuranceInfo]  

	@ICENUMBER varchar(15),
	@Name varchar(50),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@Postal varchar(5),
	@Phone varchar(10),
	@FaxPhone varchar(10),
	@PolicyHolder varchar(50),
	@GroupNumber varchar(50),
	@PolicyNumber varchar(50),
	@Website varchar(200),
	@InsuranceId int,
	@Medicaid varchar(50),
	@MedicareNumber varchar(50),
	@CreatedBy nvarchar(250) = null,
	@UpdatedBy nvarchar(250) = null,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

as

set nocount on

INSERT INTO MainInsurance (ICENUMBER, [Name], Address1, Address2,
	City, State, Postal, Phone, FaxPhone, PolicyHolderName, GroupNumber, 
	PolicyNumber, Website, InsuranceTypeId, Medicaid, MedicareNumber, CreationDate, ModifyDate,
	CreatedBy,CreatedByOrganization,
	UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
VALUES
	(@ICENUMBER, @Name, @Address1, @Address2, @City, @State,
	@Postal, @Phone, @FaxPhone, @PolicyHolder, @GroupNumber, @PolicyNumber,
	@Website, @InsuranceId, @Medicaid, @MedicareNumber, GETUTCDATE(), GETUTCDATE(),
	@CreatedBy,@Organization,
	@UpdatedBy,@UpdatedByContact,@Organization)