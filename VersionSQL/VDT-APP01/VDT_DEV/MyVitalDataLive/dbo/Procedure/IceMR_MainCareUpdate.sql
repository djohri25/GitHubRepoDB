/****** Object:  Procedure [dbo].[IceMR_MainCareUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_MainCareUpdate]
	@ICENUMBER varchar(15),
	@LastName varchar(50),
	@FirstName varchar(50),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@Postal varchar(5),
	@PhoneHome varchar(10),
	@PhoneCell varchar(10),
	@PhoneOther varchar(10),
	@CareTypeId int,
	@RelationshipId int

As
 
SET NOCOUNT ON
	
	INSERT INTO MainCareInfo(
	ICENUMBER,
	LastName,	
	FirstName, 
	Address1, 
	Address2,
	City, 
	State, 
	Postal, 
	PhoneHome, 
	PhoneCell,
	PhoneOther, 
	CareTypeId, 
	RelationshipId, 
	CreationDate,
	ModifyDate) VALUES(

	@ICENUMBER,
	@LastName,	
	@FirstName, 
	@Address1, 
	@Address2,
	@City, 
	@State, 
	@Postal, 
	@PhoneHome, 
	@PhoneCell,
	@PhoneOther, 
	@CareTypeId, 
	@RelationshipId, 
	GETUTCDATE(),
	GETUTCDATE()
	)
	