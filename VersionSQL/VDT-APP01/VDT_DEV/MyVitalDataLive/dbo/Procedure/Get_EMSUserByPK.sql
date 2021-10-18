/****** Object:  Procedure [dbo].[Get_EMSUserByPK]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/06/2008
-- Description:	 Returns EMS user information identified by PrimaryKey
-- =============================================
CREATE PROCEDURE [dbo].[Get_EMSUserByPK]
	@PrimaryKey int
AS
BEGIN

	SET NOCOUNT ON;

	SELECT PrimaryKey
	  ,Username
	  ,Email
      ,Password
      ,Active
      ,LastName
      ,FirstName
      ,Company
      ,Phone
      ,Address1
	  ,Address2
      ,City
      ,State
      ,Zip
      ,WebUrl
      ,StateLicense
      ,DriversLicense
      ,SSN
      ,Fax
      ,LastLogin
      ,SecurityQ1
      ,SecurityA1
      ,SecurityQ2
      ,SecurityA2
      ,SecurityQ3
      ,SecurityA3
	  ,Password
	FROM MainEMS
	WHERE PrimaryKey = @PrimaryKey
END