/****** Object:  Procedure [dbo].[Get_EMSUsersByCompany]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/24/2008
-- Description:	 Returns the list of EMS users associated with the company
--		If @Company is empty or 'ALL' return the full list of users
-- =============================================
CREATE PROCEDURE [dbo].[Get_EMSUsersByCompany]
	@Company varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF ISNULL(@Company, '') != '' AND @Company != 'ALL'
	BEGIN
		-- Add selection criteria
		SELECT PrimaryKey
		  ,Username
		  ,LOWER(Email) AS Email
		  ,Password
		  ,Active
		  ,dbo.InitCap(LastName) AS LastName
		  ,dbo.InitCap(FirstName) AS FirstName
		  ,Company
		  ,Phone
		  ,ISNULL(Address1 + ', ', '') + ISNULL(Address2,'') AS Address
		  ,City
		  ,State
		  ,Zip
		  ,WebUrl
		  ,StateLicense
		  ,DriversLicense
		  ,SSN
		  ,Fax
		  ,LastLogin
		  ,SecureQu
		  ,SecureAn
		  ,SecurityQ1
		  ,SecurityA1
		  ,SecurityQ2
		  ,SecurityA2
		  ,SecurityQ3
		  ,SecurityA3
		FROM MainEMS
		WHERE Company = @Company
	END
	ELSE
	BEGIN
		SELECT PrimaryKey
		  ,Username
		  ,LOWER(Email) AS Email
		  ,Password
		  ,Active
		  ,dbo.InitCap(LastName) AS LastName
		  ,dbo.InitCap(FirstName) AS FirstName
		  ,Company
		  ,Phone
		  ,ISNULL(Address1 + ', ', '') + ISNULL(Address2,'') AS Address
		  ,City
		  ,State
		  ,Zip
		  ,WebUrl
		  ,StateLicense
		  ,DriversLicense
		  ,SSN
		  ,Fax
		  ,LastLogin
		  ,SecureQu
		  ,SecureAn
		  ,SecurityQ1
		  ,SecurityA1
		  ,SecurityQ2
		  ,SecurityA2
		  ,SecurityQ3
		  ,SecurityA3
		FROM MainEMS
	END

END