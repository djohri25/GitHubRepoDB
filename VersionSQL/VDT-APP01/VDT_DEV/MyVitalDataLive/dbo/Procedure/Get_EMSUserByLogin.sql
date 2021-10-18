/****** Object:  Procedure [dbo].[Get_EMSUserByLogin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/06/2008
-- Description:	 Returns EMS user information identified by Login (currently Email)
-- =============================================
CREATE PROCEDURE [dbo].[Get_EMSUserByLogin]
	@Login varchar(50),
	@FacilityIP varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyID int, @CompanyName varchar(50)
	
	SELECT	TOP 1
			@CompanyID = ID, @CompanyName = m.Name
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = c.CompanyName
	WHERE	@FacilityIP BETWEEN c.IPAddressRangeMin and c.IPAddressRangeMax

	IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
		SELECT	PrimaryKey, Username, Email, Password, Active, LastName, 
				FirstName, Company, Phone, Address1, Address2, City, State,
				Zip, WebUrl, StateLicense, DriversLicense, SSN, Fax,
				SecurityQ1, SecurityQ2, SecurityQ3, SecurityA1, SecurityA2,
				SecurityA3, LastLogin
		FROM	MainEMS
		WHERE	Username = @Login AND Company IN ('Community Hospital Watervliet', 'Borgess Health')
	ELSE
		SELECT	PrimaryKey, Username, Email, Password, Active, LastName, 
				FirstName, Company, Phone, Address1, Address2, City, State,
				Zip, WebUrl, StateLicense, DriversLicense, SSN, Fax,
				SecurityQ1, SecurityQ2, SecurityQ3, SecurityA1, SecurityA2,
				SecurityA3, LastLogin
		FROM	MainEMS
		WHERE	Username = @Login AND CompanyID = @CompanyID
END