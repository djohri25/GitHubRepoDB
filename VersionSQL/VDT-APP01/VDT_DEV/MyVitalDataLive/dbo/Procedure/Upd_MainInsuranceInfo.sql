/****** Object:  Procedure [dbo].[Upd_MainInsuranceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_MainInsuranceInfo]  

@RecNum int,
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
@MedicareNum varchar(50),
@UpdatedBy nvarchar(250) = null,
@UpdatedByContact nvarchar(256) = NULL,
@Organization nvarchar(64) = NULL

as

set nocount on

	UPDATE MainInsurance SET
	[Name] = @Name,
	Address1 = @Address1, 
	Address2 = @Address2,
	City = @City,
	State = @State, 
	Postal = @Postal,
	Phone = @Phone,
	FaxPhone = @FaxPhone,
	PolicyHolderName = @PolicyHolder, 
	GroupNumber = @GroupNumber,
	PolicyNumber = @PolicyNumber, 
	Website = @Website, 
	InsuranceTypeId = @InsuranceId, 
	ModifyDate = GETUTCDATE(),
	Medicaid = @Medicaid,
	MedicareNumber = @MedicareNum,
	UpdatedBy =@UpdatedBy,
	UpdatedByContact = @UpdatedByContact,
	UpdatedByOrganization=@Organization
	WHERE RecordNumber = @RecNum
	