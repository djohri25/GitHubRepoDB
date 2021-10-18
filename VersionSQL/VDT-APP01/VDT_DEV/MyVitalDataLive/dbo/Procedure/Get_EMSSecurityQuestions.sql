/****** Object:  Procedure [dbo].[Get_EMSSecurityQuestions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_EMSSecurityQuestions]
	@Username varchar(50),
	@FacilityIP varchar(15),
	@SecurityQ1 int = 0 OUT,
	@SecurityQ2 int = 0 OUT,
	@SecurityQ3 int = 0 OUT,
	@PINResetFlag int = 0 OUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	@CompanyID int, @CompanyName nvarchar(50)
	
	SELECT	TOP 1
			@CompanyID = ID, @CompanyName = m.Name
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = c.CompanyName
	WHERE	@FacilityIP BETWEEN c.IPAddressRangeMin and c.IPAddressRangeMax

	IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
		SELECT	TOP 1 
				@SecurityQ1 = ISNULL(SecurityQ1, 0), 
				@SecurityQ2 = ISNULL(SecurityQ2, 0), 
				@SecurityQ3 = ISNULL(SecurityQ3, 0),
				@PINResetFlag = CASE WHEN [Password] IS NULL THEN 1 ELSE 0 END
		FROM	MainEMS
		WHERE	Username = @Username AND Company IN ('Community Hospital Watervliet', 'Borgess Health')
	ELSE
		SELECT	TOP 1 
				@SecurityQ1 = ISNULL(SecurityQ1, 0), 
				@SecurityQ2 = ISNULL(SecurityQ2, 0), 
				@SecurityQ3 = ISNULL(SecurityQ3, 0),
				@PINResetFlag = CASE WHEN [Password] IS NULL THEN 1 ELSE 0 END
		FROM	MainEMS
		WHERE	Username = @Username AND CompanyID = @CompanyID
END