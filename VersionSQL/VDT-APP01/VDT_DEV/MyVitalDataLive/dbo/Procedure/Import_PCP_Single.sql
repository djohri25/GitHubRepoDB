/****** Object:  Procedure [dbo].[Import_PCP_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/4/2011
-- Description:	Import single PCP record
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Import_PCP_Single] 
	@RecordID int,						
	@PCPID varchar(50),
	@Facility varchar(100),
	@Specialty varchar(100),
	@Gender varchar(50),
	@Languages varchar(max),
	@Address1 varchar(100),
	@Address2 varchar(100),
	@City varchar(100),
	@State varchar(50),
	@Zip varchar(50),
	@Phone varchar(50),
	@Fax varchar(50),
	@HoursMon varchar(50),
	@HoursTue varchar(50),
	@HoursWed varchar(50),
	@HoursThu varchar(50),
	@HoursFri varchar(50),
	@HoursSat varchar(50),
	@HoursSun varchar(50),
	@HospAffiliations varchar(1000),
	@Certification varchar(1000),
	@Notes varchar(max),
	@ImportResult int out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	select @ImportResult = -1
/*
	select 
		@RecordID = 5445,						
		@PCPID = '1043364110',
		@Facility = '',
		@Specialty = 'Family Practice',
		@Gender = 'M',
		@Languages = 'French;Polish',
		@Address1 = '1240 NW 119th St',
		@Address2 = '1',
		@City = 'Miami',
		@State = 'FL',
		@Zip = '33167',
		@Phone = '3056855688',
		@Fax = '3056855688',
		@HoursMon = '8:00 AM to 5:00 PM',
		@HoursTue = '8:00 AM to 5:00 PM',
		@HoursWed = '8:00 AM to 5:00 PM',
		@HoursThu = '8:00 AM to 5:00 PM',
		@HoursFri = '8:00 AM to 5:00 PM',
		@HoursSat = '9:00 AM to 5:00 PM',
		@HoursSun = '9:00 AM to 5:00 PM',
		@HospAffiliations = 'North Hills Hospital;Harris Methodist HEB',
		@Certification = 'Family Practice',
		@Notes = 'sample note'
*/

	BEGIN TRY

		if exists(select npi from dbo.LookupNPI where NPI = @PCPID)
		begin
			-- create updated record
			delete from LookupNPI_Custom where NPI = @PCPID
		
			insert into LookupNPI_Custom(
				[NPI]
				,Specialty
				,HospAffiliations
				,Certification
			  ,[OfficeHrMon]
			  ,[OfficeHrTue]
			  ,[OfficeHrWed]
			  ,[OfficeHrThu]
			  ,[OfficeHrFri]
			  ,[OfficeHrSat]
			  ,[OfficeHrSun]
			  ,Note				
			  ,[Entity Type Code]
			  ,[Replacement NPI]
			  ,[Employer Identification Number (EIN)]
			  ,[Provider Organization Name (Legal Business Name)]
			  ,[Provider Last Name (Legal Name)]
			  ,[Provider First Name]
			  ,[Provider Middle Name]
			  ,[Provider Name Prefix Text]
			  ,[Provider Name Suffix Text]
			  ,[Provider Credential Text]
			  ,[Provider Other Organization Name]
			  ,[Provider Other Organization Name Type Code]
			  ,[Provider Other Last Name]
			  ,[Provider Other First Name]
			  ,[Provider Other Middle Name]
			  ,[Provider Other Name Prefix Text]
			  ,[Provider Other Name Suffix Text]
			  ,[Provider Other Credential Text]
			  ,[Provider Other Last Name Type Code]
			  ,[Provider First Line Business Mailing Address]
			  ,[Provider Second Line Business Mailing Address]
			  ,[Provider Business Mailing Address City Name]
			  ,[Provider Business Mailing Address State Name]
			  ,[Provider Business Mailing Address Postal Code]
			  ,[Provider Business Mailing Address Country Code (If outside U S )]
			  ,[Provider Business Mailing Address Telephone Number]
			  ,[Provider Business Mailing Address Fax Number]
			  ,[Provider First Line Business Practice Location Address]
			  ,[Provider Second Line Business Practice Location Address]
			  ,[Provider Business Practice Location Address City Name]
			  ,[Provider Business Practice Location Address State Name]
			  ,[Provider Business Practice Location Address Postal Code]
			  ,[Provider Business Practice Location Address Country Code (If outside U S )]
			  ,[Provider Business Practice Location Address Telephone Number]
			  ,[Provider Business Practice Location Address Fax Number]
			  ,[Provider Enumeration Date]
			  ,[Last Update Date]
			  ,[NPI Deactivation Reason Code]
			  ,[NPI Deactivation Date]
			  ,[NPI Reactivation Date]
			  ,[Provider Gender Code]
			  ,[Authorized Official Last Name]
			  ,[Authorized Official First Name]
			  ,[Authorized Official Middle Name]
			  ,[Authorized Official Title or Position]
			  ,[Authorized Official Telephone Number]
			  ,[Healthcare Provider Taxonomy Code_1]
			  ,[Provider License Number_1]
			  ,[Provider License Number State Code_1]
			  ,[Healthcare Provider Primary Taxonomy Switch_1]
			  ,[Healthcare Provider Taxonomy Code_2]
			  ,[Provider License Number_2]
			  ,[Provider License Number State Code_2]
			  ,[Healthcare Provider Primary Taxonomy Switch_2]
			  ,[Healthcare Provider Taxonomy Code_3]
			  ,[Provider License Number_3]
			  ,[Provider License Number State Code_3]
			  ,[Healthcare Provider Primary Taxonomy Switch_3]
			  ,[Healthcare Provider Taxonomy Code_4]
			  ,[Provider License Number_4]
			  ,[Provider License Number State Code_4]
			  ,[Healthcare Provider Primary Taxonomy Switch_4]
			  ,[Healthcare Provider Taxonomy Code_5]
			  ,[Provider License Number_5]
			  ,[Provider License Number State Code_5]
			  ,[Healthcare Provider Primary Taxonomy Switch_5]
			  ,[Healthcare Provider Taxonomy Code_6]
			  ,[Provider License Number_6]
			  ,[Provider License Number State Code_6]
			  ,[Healthcare Provider Primary Taxonomy Switch_6]
			  ,[Healthcare Provider Taxonomy Code_7]
			  ,[Provider License Number_7]
			  ,[Provider License Number State Code_7]
			  ,[Healthcare Provider Primary Taxonomy Switch_7]
			  ,[Healthcare Provider Taxonomy Code_8]
			  ,[Provider License Number_8]
			  ,[Provider License Number State Code_8]
			  ,[Healthcare Provider Primary Taxonomy Switch_8]
			  ,[Healthcare Provider Taxonomy Code_9]
			  ,[Provider License Number_9]
			  ,[Provider License Number State Code_9]
			  ,[Healthcare Provider Primary Taxonomy Switch_9]
			  ,[Healthcare Provider Taxonomy Code_10]
			  ,[Provider License Number_10]
			  ,[Provider License Number State Code_10]
			  ,[Healthcare Provider Primary Taxonomy Switch_10]
			  ,[Healthcare Provider Taxonomy Code_11]
			  ,[Provider License Number_11]
			  ,[Provider License Number State Code_11]
			  ,[Healthcare Provider Primary Taxonomy Switch_11]
			  ,[Healthcare Provider Taxonomy Code_12]
			  ,[Provider License Number_12]
			  ,[Provider License Number State Code_12]
			  ,[Healthcare Provider Primary Taxonomy Switch_12]
			  ,[Healthcare Provider Taxonomy Code_13]
			  ,[Provider License Number_13]
			  ,[Provider License Number State Code_13]
			  ,[Healthcare Provider Primary Taxonomy Switch_13]
			  ,[Healthcare Provider Taxonomy Code_14]
			  ,[Provider License Number_14]
			  ,[Provider License Number State Code_14]
			  ,[Healthcare Provider Primary Taxonomy Switch_14]
			  ,[Healthcare Provider Taxonomy Code_15]
			  ,[Provider License Number_15]
			  ,[Provider License Number State Code_15]
			  ,[Healthcare Provider Primary Taxonomy Switch_15]
			  ,[Other Provider Identifier_1]
			  ,[Other Provider Identifier Type Code_1]
			  ,[Other Provider Identifier State_1]
			  ,[Other Provider Identifier Issuer_1]
			  ,[Other Provider Identifier_2]
			  ,[Other Provider Identifier Type Code_2]
			  ,[Other Provider Identifier State_2]
			  ,[Other Provider Identifier Issuer_2]
			  ,[Other Provider Identifier_3]
			  ,[Other Provider Identifier Type Code_3]
			  ,[Other Provider Identifier State_3]
			  ,[Other Provider Identifier Issuer_3]
			  ,[Other Provider Identifier_4]
			  ,[Other Provider Identifier Type Code_4]
			  ,[Other Provider Identifier State_4]
			  ,[Other Provider Identifier Issuer_4]
			  ,[Other Provider Identifier_5]
			  ,[Other Provider Identifier Type Code_5]
			  ,[Other Provider Identifier State_5]
			  ,[Other Provider Identifier Issuer_5]
			  ,[Other Provider Identifier_6]
			  ,[Other Provider Identifier Type Code_6]
			  ,[Other Provider Identifier State_6]
			  ,[Other Provider Identifier Issuer_6]
			  ,[Other Provider Identifier_7]
			  ,[Other Provider Identifier Type Code_7]
			  ,[Other Provider Identifier State_7]
			  ,[Other Provider Identifier Issuer_7]
			  ,[Other Provider Identifier_8]
			  ,[Other Provider Identifier Type Code_8]
			  ,[Other Provider Identifier State_8]
			  ,[Other Provider Identifier Issuer_8]
			  ,[Other Provider Identifier_9]
			  ,[Other Provider Identifier Type Code_9]
			  ,[Other Provider Identifier State_9]
			  ,[Other Provider Identifier Issuer_9]
			  ,[Other Provider Identifier_10]
			  ,[Other Provider Identifier Type Code_10]
			  ,[Other Provider Identifier State_10]
			  ,[Other Provider Identifier Issuer_10]
			  ,[Other Provider Identifier_11]
			  ,[Other Provider Identifier Type Code_11]
			  ,[Other Provider Identifier State_11]
			  ,[Other Provider Identifier Issuer_11]
			  ,[Other Provider Identifier_12]
			  ,[Other Provider Identifier Type Code_12]
			  ,[Other Provider Identifier State_12]
			  ,[Other Provider Identifier Issuer_12]
			  ,[Other Provider Identifier_13]
			  ,[Other Provider Identifier Type Code_13]
			  ,[Other Provider Identifier State_13]
			  ,[Other Provider Identifier Issuer_13]
			  ,[Other Provider Identifier_14]
			  ,[Other Provider Identifier Type Code_14]
			  ,[Other Provider Identifier State_14]
			  ,[Other Provider Identifier Issuer_14]
			  ,[Other Provider Identifier_15]
			  ,[Other Provider Identifier Type Code_15]
			  ,[Other Provider Identifier State_15]
			  ,[Other Provider Identifier Issuer_15]
			  ,[Other Provider Identifier_16]
			  ,[Other Provider Identifier Type Code_16]
			  ,[Other Provider Identifier State_16]
			  ,[Other Provider Identifier Issuer_16]
			  ,[Other Provider Identifier_17]
			  ,[Other Provider Identifier Type Code_17]
			  ,[Other Provider Identifier State_17]
			  ,[Other Provider Identifier Issuer_17]
			  ,[Other Provider Identifier_18]
			  ,[Other Provider Identifier Type Code_18]
			  ,[Other Provider Identifier State_18]
			  ,[Other Provider Identifier Issuer_18]
			  ,[Other Provider Identifier_19]
			  ,[Other Provider Identifier Type Code_19]
			  ,[Other Provider Identifier State_19]
			  ,[Other Provider Identifier Issuer_19]
			  ,[Other Provider Identifier_20]
			  ,[Other Provider Identifier Type Code_20]
			  ,[Other Provider Identifier State_20]
			  ,[Other Provider Identifier Issuer_20]
			  ,[Other Provider Identifier_21]
			  ,[Other Provider Identifier Type Code_21]
			  ,[Other Provider Identifier State_21]
			  ,[Other Provider Identifier Issuer_21]
			  ,[Other Provider Identifier_22]
			  ,[Other Provider Identifier Type Code_22]
			  ,[Other Provider Identifier State_22]
			  ,[Other Provider Identifier Issuer_22]
			  ,[Other Provider Identifier_23]
			  ,[Other Provider Identifier Type Code_23]
			  ,[Other Provider Identifier State_23]
			  ,[Other Provider Identifier Issuer_23]
			  ,[Other Provider Identifier_24]
			  ,[Other Provider Identifier Type Code_24]
			  ,[Other Provider Identifier State_24]
			  ,[Other Provider Identifier Issuer_24]
			  ,[Other Provider Identifier_25]
			  ,[Other Provider Identifier Type Code_25]
			  ,[Other Provider Identifier State_25]
			  ,[Other Provider Identifier Issuer_25]
			  ,[Other Provider Identifier_26]
			  ,[Other Provider Identifier Type Code_26]
			  ,[Other Provider Identifier State_26]
			  ,[Other Provider Identifier Issuer_26]
			  ,[Other Provider Identifier_27]
			  ,[Other Provider Identifier Type Code_27]
			  ,[Other Provider Identifier State_27]
			  ,[Other Provider Identifier Issuer_27]
			  ,[Other Provider Identifier_28]
			  ,[Other Provider Identifier Type Code_28]
			  ,[Other Provider Identifier State_28]
			  ,[Other Provider Identifier Issuer_28]
			  ,[Other Provider Identifier_29]
			  ,[Other Provider Identifier Type Code_29]
			  ,[Other Provider Identifier State_29]
			  ,[Other Provider Identifier Issuer_29]
			  ,[Other Provider Identifier_30]
			  ,[Other Provider Identifier Type Code_30]
			  ,[Other Provider Identifier State_30]
			  ,[Other Provider Identifier Issuer_30]
			  ,[Other Provider Identifier_31]
			  ,[Other Provider Identifier Type Code_31]
			  ,[Other Provider Identifier State_31]
			  ,[Other Provider Identifier Issuer_31]
			  ,[Other Provider Identifier_32]
			  ,[Other Provider Identifier Type Code_32]
			  ,[Other Provider Identifier State_32]
			  ,[Other Provider Identifier Issuer_32]
			  ,[Other Provider Identifier_33]
			  ,[Other Provider Identifier Type Code_33]
			  ,[Other Provider Identifier State_33]
			  ,[Other Provider Identifier Issuer_33]
			  ,[Other Provider Identifier_34]
			  ,[Other Provider Identifier Type Code_34]
			  ,[Other Provider Identifier State_34]
			  ,[Other Provider Identifier Issuer_34]
			  ,[Other Provider Identifier_35]
			  ,[Other Provider Identifier Type Code_35]
			  ,[Other Provider Identifier State_35]
			  ,[Other Provider Identifier Issuer_35]
			  ,[Other Provider Identifier_36]
			  ,[Other Provider Identifier Type Code_36]
			  ,[Other Provider Identifier State_36]
			  ,[Other Provider Identifier Issuer_36]
			  ,[Other Provider Identifier_37]
			  ,[Other Provider Identifier Type Code_37]
			  ,[Other Provider Identifier State_37]
			  ,[Other Provider Identifier Issuer_37]
			  ,[Other Provider Identifier_38]
			  ,[Other Provider Identifier Type Code_38]
			  ,[Other Provider Identifier State_38]
			  ,[Other Provider Identifier Issuer_38]
			  ,[Other Provider Identifier_39]
			  ,[Other Provider Identifier Type Code_39]
			  ,[Other Provider Identifier State_39]
			  ,[Other Provider Identifier Issuer_39]
			  ,[Other Provider Identifier_40]
			  ,[Other Provider Identifier Type Code_40]
			  ,[Other Provider Identifier State_40]
			  ,[Other Provider Identifier Issuer_40]
			  ,[Other Provider Identifier_41]
			  ,[Other Provider Identifier Type Code_41]
			  ,[Other Provider Identifier State_41]
			  ,[Other Provider Identifier Issuer_41]
			  ,[Other Provider Identifier_42]
			  ,[Other Provider Identifier Type Code_42]
			  ,[Other Provider Identifier State_42]
			  ,[Other Provider Identifier Issuer_42]
			  ,[Other Provider Identifier_43]
			  ,[Other Provider Identifier Type Code_43]
			  ,[Other Provider Identifier State_43]
			  ,[Other Provider Identifier Issuer_43]
			  ,[Other Provider Identifier_44]
			  ,[Other Provider Identifier Type Code_44]
			  ,[Other Provider Identifier State_44]
			  ,[Other Provider Identifier Issuer_44]
			  ,[Other Provider Identifier_45]
			  ,[Other Provider Identifier Type Code_45]
			  ,[Other Provider Identifier State_45]
			  ,[Other Provider Identifier Issuer_45]
			  ,[Other Provider Identifier_46]
			  ,[Other Provider Identifier Type Code_46]
			  ,[Other Provider Identifier State_46]
			  ,[Other Provider Identifier Issuer_46]
			  ,[Other Provider Identifier_47]
			  ,[Other Provider Identifier Type Code_47]
			  ,[Other Provider Identifier State_47]
			  ,[Other Provider Identifier Issuer_47]
			  ,[Other Provider Identifier_48]
			  ,[Other Provider Identifier Type Code_48]
			  ,[Other Provider Identifier State_48]
			  ,[Other Provider Identifier Issuer_48]
			  ,[Other Provider Identifier_49]
			  ,[Other Provider Identifier Type Code_49]
			  ,[Other Provider Identifier State_49]
			  ,[Other Provider Identifier Issuer_49]
			  ,[Other Provider Identifier_50]
			  ,[Other Provider Identifier Type Code_50]
			  ,[Other Provider Identifier State_50]
			  ,[Other Provider Identifier Issuer_50]
			  ,[Is Sole Proprietor]
			  ,[Is Organization Subpart]
			  ,[Parent Organization LBN]
			  ,[Parent Organization TIN]
			  ,[Authorized Official Name Prefix Text]
			  ,[Authorized Official Name Suffix Text]
			  ,[Authorized Official Credential Text]
			)
			SELECT [NPI]
				,@Specialty
				,@HospAffiliations
				,@Certification
				,@HoursMon
				,@HoursTue
				,@HoursWed
				,@HoursThu
				,@HoursFri
				,@HoursSat
				,@HoursSun
				,@Notes
				,[Entity Type Code]
				,[Replacement NPI]
				,[Employer Identification Number (EIN)]
				,[Provider Organization Name (Legal Business Name)]
				,[Provider Last Name (Legal Name)]
				,[Provider First Name]
				,[Provider Middle Name]
				,[Provider Name Prefix Text]
				,[Provider Name Suffix Text]
				,[Provider Credential Text]
				,[Provider Other Organization Name]
				,[Provider Other Organization Name Type Code]
				,[Provider Other Last Name]
				,[Provider Other First Name]
				,[Provider Other Middle Name]
				,[Provider Other Name Prefix Text]
				,[Provider Other Name Suffix Text]
				,[Provider Other Credential Text]
				,[Provider Other Last Name Type Code]
				,[Provider First Line Business Mailing Address]
				,[Provider Second Line Business Mailing Address]
				,[Provider Business Mailing Address City Name]
				,[Provider Business Mailing Address State Name]
				,[Provider Business Mailing Address Postal Code]
				,[Provider Business Mailing Address Country Code (If outside U S )]
				,[Provider Business Mailing Address Telephone Number]
				,[Provider Business Mailing Address Fax Number]
				,[Provider First Line Business Practice Location Address]
				,[Provider Second Line Business Practice Location Address]
				,[Provider Business Practice Location Address City Name]
				,[Provider Business Practice Location Address State Name]
				,[Provider Business Practice Location Address Postal Code]
				,[Provider Business Practice Location Address Country Code (If outside U S )]
				,[Provider Business Practice Location Address Telephone Number]
				,[Provider Business Practice Location Address Fax Number]
				,[Provider Enumeration Date]
				,[Last Update Date]
				,[NPI Deactivation Reason Code]
				,[NPI Deactivation Date]
				,[NPI Reactivation Date]
				,[Provider Gender Code]
				,[Authorized Official Last Name]
				,[Authorized Official First Name]
				,[Authorized Official Middle Name]
				,[Authorized Official Title or Position]
				,[Authorized Official Telephone Number]
				,[Healthcare Provider Taxonomy Code_1]
				,[Provider License Number_1]
				,[Provider License Number State Code_1]
				,[Healthcare Provider Primary Taxonomy Switch_1]
				,[Healthcare Provider Taxonomy Code_2]
				,[Provider License Number_2]
				,[Provider License Number State Code_2]
				,[Healthcare Provider Primary Taxonomy Switch_2]
				,[Healthcare Provider Taxonomy Code_3]
				,[Provider License Number_3]
				,[Provider License Number State Code_3]
				,[Healthcare Provider Primary Taxonomy Switch_3]
				,[Healthcare Provider Taxonomy Code_4]
				,[Provider License Number_4]
				,[Provider License Number State Code_4]
				,[Healthcare Provider Primary Taxonomy Switch_4]
				,[Healthcare Provider Taxonomy Code_5]
				,[Provider License Number_5]
				,[Provider License Number State Code_5]
				,[Healthcare Provider Primary Taxonomy Switch_5]
				,[Healthcare Provider Taxonomy Code_6]
				,[Provider License Number_6]
				,[Provider License Number State Code_6]
				,[Healthcare Provider Primary Taxonomy Switch_6]
				,[Healthcare Provider Taxonomy Code_7]
				,[Provider License Number_7]
				,[Provider License Number State Code_7]
				,[Healthcare Provider Primary Taxonomy Switch_7]
				,[Healthcare Provider Taxonomy Code_8]
				,[Provider License Number_8]
				,[Provider License Number State Code_8]
				,[Healthcare Provider Primary Taxonomy Switch_8]
				,[Healthcare Provider Taxonomy Code_9]
				,[Provider License Number_9]
				,[Provider License Number State Code_9]
				,[Healthcare Provider Primary Taxonomy Switch_9]
				,[Healthcare Provider Taxonomy Code_10]
				,[Provider License Number_10]
				,[Provider License Number State Code_10]
				,[Healthcare Provider Primary Taxonomy Switch_10]
				,[Healthcare Provider Taxonomy Code_11]
				,[Provider License Number_11]
				,[Provider License Number State Code_11]
				,[Healthcare Provider Primary Taxonomy Switch_11]
				,[Healthcare Provider Taxonomy Code_12]
				,[Provider License Number_12]
				,[Provider License Number State Code_12]
				,[Healthcare Provider Primary Taxonomy Switch_12]
				,[Healthcare Provider Taxonomy Code_13]
				,[Provider License Number_13]
				,[Provider License Number State Code_13]
				,[Healthcare Provider Primary Taxonomy Switch_13]
				,[Healthcare Provider Taxonomy Code_14]
				,[Provider License Number_14]
				,[Provider License Number State Code_14]
				,[Healthcare Provider Primary Taxonomy Switch_14]
				,[Healthcare Provider Taxonomy Code_15]
				,[Provider License Number_15]
				,[Provider License Number State Code_15]
				,[Healthcare Provider Primary Taxonomy Switch_15]
				,[Other Provider Identifier_1]
				,[Other Provider Identifier Type Code_1]
				,[Other Provider Identifier State_1]
				,[Other Provider Identifier Issuer_1]
				,[Other Provider Identifier_2]
				,[Other Provider Identifier Type Code_2]
				,[Other Provider Identifier State_2]
				,[Other Provider Identifier Issuer_2]
				,[Other Provider Identifier_3]
				,[Other Provider Identifier Type Code_3]
				,[Other Provider Identifier State_3]
				,[Other Provider Identifier Issuer_3]
				,[Other Provider Identifier_4]
				,[Other Provider Identifier Type Code_4]
				,[Other Provider Identifier State_4]
				,[Other Provider Identifier Issuer_4]
				,[Other Provider Identifier_5]
				,[Other Provider Identifier Type Code_5]
				,[Other Provider Identifier State_5]
				,[Other Provider Identifier Issuer_5]
				,[Other Provider Identifier_6]
				,[Other Provider Identifier Type Code_6]
				,[Other Provider Identifier State_6]
				,[Other Provider Identifier Issuer_6]
				,[Other Provider Identifier_7]
				,[Other Provider Identifier Type Code_7]
				,[Other Provider Identifier State_7]
				,[Other Provider Identifier Issuer_7]
				,[Other Provider Identifier_8]
				,[Other Provider Identifier Type Code_8]
				,[Other Provider Identifier State_8]
				,[Other Provider Identifier Issuer_8]
				,[Other Provider Identifier_9]
				,[Other Provider Identifier Type Code_9]
				,[Other Provider Identifier State_9]
				,[Other Provider Identifier Issuer_9]
				,[Other Provider Identifier_10]
				,[Other Provider Identifier Type Code_10]
				,[Other Provider Identifier State_10]
				,[Other Provider Identifier Issuer_10]
				,[Other Provider Identifier_11]
				,[Other Provider Identifier Type Code_11]
				,[Other Provider Identifier State_11]
				,[Other Provider Identifier Issuer_11]
				,[Other Provider Identifier_12]
				,[Other Provider Identifier Type Code_12]
				,[Other Provider Identifier State_12]
				,[Other Provider Identifier Issuer_12]
				,[Other Provider Identifier_13]
				,[Other Provider Identifier Type Code_13]
				,[Other Provider Identifier State_13]
				,[Other Provider Identifier Issuer_13]
				,[Other Provider Identifier_14]
				,[Other Provider Identifier Type Code_14]
				,[Other Provider Identifier State_14]
				,[Other Provider Identifier Issuer_14]
				,[Other Provider Identifier_15]
				,[Other Provider Identifier Type Code_15]
				,[Other Provider Identifier State_15]
				,[Other Provider Identifier Issuer_15]
				,[Other Provider Identifier_16]
				,[Other Provider Identifier Type Code_16]
				,[Other Provider Identifier State_16]
				,[Other Provider Identifier Issuer_16]
				,[Other Provider Identifier_17]
				,[Other Provider Identifier Type Code_17]
				,[Other Provider Identifier State_17]
				,[Other Provider Identifier Issuer_17]
				,[Other Provider Identifier_18]
				,[Other Provider Identifier Type Code_18]
				,[Other Provider Identifier State_18]
				,[Other Provider Identifier Issuer_18]
				,[Other Provider Identifier_19]
				,[Other Provider Identifier Type Code_19]
				,[Other Provider Identifier State_19]
				,[Other Provider Identifier Issuer_19]
				,[Other Provider Identifier_20]
				,[Other Provider Identifier Type Code_20]
				,[Other Provider Identifier State_20]
				,[Other Provider Identifier Issuer_20]
				,[Other Provider Identifier_21]
				,[Other Provider Identifier Type Code_21]
				,[Other Provider Identifier State_21]
				,[Other Provider Identifier Issuer_21]
				,[Other Provider Identifier_22]
				,[Other Provider Identifier Type Code_22]
				,[Other Provider Identifier State_22]
				,[Other Provider Identifier Issuer_22]
				,[Other Provider Identifier_23]
				,[Other Provider Identifier Type Code_23]
				,[Other Provider Identifier State_23]
				,[Other Provider Identifier Issuer_23]
				,[Other Provider Identifier_24]
				,[Other Provider Identifier Type Code_24]
				,[Other Provider Identifier State_24]
				,[Other Provider Identifier Issuer_24]
				,[Other Provider Identifier_25]
				,[Other Provider Identifier Type Code_25]
				,[Other Provider Identifier State_25]
				,[Other Provider Identifier Issuer_25]
				,[Other Provider Identifier_26]
				,[Other Provider Identifier Type Code_26]
				,[Other Provider Identifier State_26]
				,[Other Provider Identifier Issuer_26]
				,[Other Provider Identifier_27]
				,[Other Provider Identifier Type Code_27]
				,[Other Provider Identifier State_27]
				,[Other Provider Identifier Issuer_27]
				,[Other Provider Identifier_28]
				,[Other Provider Identifier Type Code_28]
				,[Other Provider Identifier State_28]
				,[Other Provider Identifier Issuer_28]
				,[Other Provider Identifier_29]
				,[Other Provider Identifier Type Code_29]
				,[Other Provider Identifier State_29]
				,[Other Provider Identifier Issuer_29]
				,[Other Provider Identifier_30]
				,[Other Provider Identifier Type Code_30]
				,[Other Provider Identifier State_30]
				,[Other Provider Identifier Issuer_30]
				,[Other Provider Identifier_31]
				,[Other Provider Identifier Type Code_31]
				,[Other Provider Identifier State_31]
				,[Other Provider Identifier Issuer_31]
				,[Other Provider Identifier_32]
				,[Other Provider Identifier Type Code_32]
				,[Other Provider Identifier State_32]
				,[Other Provider Identifier Issuer_32]
				,[Other Provider Identifier_33]
				,[Other Provider Identifier Type Code_33]
				,[Other Provider Identifier State_33]
				,[Other Provider Identifier Issuer_33]
				,[Other Provider Identifier_34]
				,[Other Provider Identifier Type Code_34]
				,[Other Provider Identifier State_34]
				,[Other Provider Identifier Issuer_34]
				,[Other Provider Identifier_35]
				,[Other Provider Identifier Type Code_35]
				,[Other Provider Identifier State_35]
				,[Other Provider Identifier Issuer_35]
				,[Other Provider Identifier_36]
				,[Other Provider Identifier Type Code_36]
				,[Other Provider Identifier State_36]
				,[Other Provider Identifier Issuer_36]
				,[Other Provider Identifier_37]
				,[Other Provider Identifier Type Code_37]
				,[Other Provider Identifier State_37]
				,[Other Provider Identifier Issuer_37]
				,[Other Provider Identifier_38]
				,[Other Provider Identifier Type Code_38]
				,[Other Provider Identifier State_38]
				,[Other Provider Identifier Issuer_38]
				,[Other Provider Identifier_39]
				,[Other Provider Identifier Type Code_39]
				,[Other Provider Identifier State_39]
				,[Other Provider Identifier Issuer_39]
				,[Other Provider Identifier_40]
				,[Other Provider Identifier Type Code_40]
				,[Other Provider Identifier State_40]
				,[Other Provider Identifier Issuer_40]
				,[Other Provider Identifier_41]
				,[Other Provider Identifier Type Code_41]
				,[Other Provider Identifier State_41]
				,[Other Provider Identifier Issuer_41]
				,[Other Provider Identifier_42]
				,[Other Provider Identifier Type Code_42]
				,[Other Provider Identifier State_42]
				,[Other Provider Identifier Issuer_42]
				,[Other Provider Identifier_43]
				,[Other Provider Identifier Type Code_43]
				,[Other Provider Identifier State_43]
				,[Other Provider Identifier Issuer_43]
				,[Other Provider Identifier_44]
				,[Other Provider Identifier Type Code_44]
				,[Other Provider Identifier State_44]
				,[Other Provider Identifier Issuer_44]
				,[Other Provider Identifier_45]
				,[Other Provider Identifier Type Code_45]
				,[Other Provider Identifier State_45]
				,[Other Provider Identifier Issuer_45]
				,[Other Provider Identifier_46]
				,[Other Provider Identifier Type Code_46]
				,[Other Provider Identifier State_46]
				,[Other Provider Identifier Issuer_46]
				,[Other Provider Identifier_47]
				,[Other Provider Identifier Type Code_47]
				,[Other Provider Identifier State_47]
				,[Other Provider Identifier Issuer_47]
				,[Other Provider Identifier_48]
				,[Other Provider Identifier Type Code_48]
				,[Other Provider Identifier State_48]
				,[Other Provider Identifier Issuer_48]
				,[Other Provider Identifier_49]
				,[Other Provider Identifier Type Code_49]
				,[Other Provider Identifier State_49]
				,[Other Provider Identifier Issuer_49]
				,[Other Provider Identifier_50]
				,[Other Provider Identifier Type Code_50]
				,[Other Provider Identifier State_50]
				,[Other Provider Identifier Issuer_50]
				,[Is Sole Proprietor]
				,[Is Organization Subpart]
				,[Parent Organization LBN]
				,[Parent Organization TIN]
				,[Authorized Official Name Prefix Text]
				,[Authorized Official Name Suffix Text]
				,[Authorized Official Credential Text]
			FROM dbo.LookupNPI 
			where NPI = @PCPID		
		end
		else
		begin
			delete from LookupNPI_Custom where NPI = @PCPID
			
			insert into LookupNPI_Custom
			(
				NPI
				,Specialty
				,[Provider First Line Business Practice Location Address]
				,[Provider Second Line Business Practice Location Address]
				,[Provider Business Practice Location Address City Name]
				,[Provider Business Practice Location Address State Name]
				,[Provider Business Practice Location Address Postal Code]
				,[Provider Business Practice Location Address Telephone Number]
				,[Provider Business Practice Location Address Fax Number]
				,HospAffiliations
				,Certification
				,OfficeHrMon
				,OfficeHrTue
				,OfficeHrWed
				,OfficeHrThu
				,OfficeHrFri
				,OfficeHrSat
				,OfficeHrSun
				,Note				
				,[Entity Type Code]
				,[Provider Organization Name (Legal Business Name)]
			)
			select
				@PCPID,
				@Specialty,
				@Address1,
				@Address2,
				@City,
				@State,
				@Zip,
				@Phone,
				@Fax,
				@HospAffiliations,
				@Certification,
				@HoursMon,
				@HoursTue,
				@HoursWed,
				@HoursThu,
				@HoursFri,
				@HoursSat,
				@HoursSun,
				@Notes,
				'2',			-- Facility
				@Facility			
		
		end
		
		if ISNULL(@languages,'') <> '' AND exists(select npi from LookupNPI_Custom where npi = @pcpid)
		begin
			declare @temp table(data varchar(50))
			
			insert into @temp(data)
			select DATA from dbo.Split(@languages,';')
			
			insert into PersonLanguagesSpoken(PersonID,PersonCategory,LanguageID)
			select @PCPID, 'Provider', ll.ID
			from @temp t 
				inner join LookupLanguage ll on ltrim(rtrim(t.data)) = ll.Name
			where ll.ID not in
				(
					select pls.LanguageID 
					from PersonLanguagesSpoken pls
					where pls.PersonID = @PCPID
				)			
		end
		
		
		set @ImportResult = 0

	END TRY
	BEGIN CATCH
		DECLARE @addInfo nvarchar(MAX)			
		
		SELECT	@ImportResult = -1,
				@addInfo = 
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', @PCPID=' + ISNULL(@PCPID, 'NULL') + ', @Facility=' + ISNULL(@Facility, 'NULL') + 
					', @Specialty=' + ISNULL(@Specialty, 'NULL') + ', @Gender=' + ISNULL(@Gender, 'NULL') + ', @Languages=' + ISNULL(@Languages, 'NULL') + 
					', @Address1=' + ISNULL(@Address1, 'NULL') + ', @Address2=' + ISNULL(@Address1, 'NULL') + ', @City=' + ISNULL(@City, 'NULL') + 
					', @State=' + ISNULL(@State, 'NULL') + ', @Zip=' + ISNULL(@Zip, 'NULL') + ', @Phone=' + ISNULL(@Phone, 'NULL') + 
					', @Fax=' + ISNULL(@Fax, 'NULL') + ', @HoursMon=' + ISNULL(@HoursMon, 'NULL') + ', @HoursTue=' + ISNULL(@HoursTue, 'NULL') + ', @HoursWed=' + ISNULL(@HoursWed, 'NULL') + ', @HoursThu=' + ISNULL(@HoursThu, 'NULL') + 
					', @HoursFri=' + ISNULL(@HoursFri, 'NULL') + ', @HoursSat=' + ISNULL(@HoursSat, 'NULL') + ', @HoursSun=' + ISNULL(@HoursSun, 'NULL') + 
					', @HospAffiliations=' + ISNULL(@HospAffiliations, 'NULL') + ', @Certification=' + ISNULL(@Certification, 'NULL') + ', @Notes=' + ISNULL(@Notes, 'NULL')

		EXEC ImportCatchError @addInfo
	END CATCH

--select @ImportResult as '@ImportResult'
END