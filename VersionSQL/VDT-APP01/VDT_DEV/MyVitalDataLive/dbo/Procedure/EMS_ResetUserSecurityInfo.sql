/****** Object:  Procedure [dbo].[EMS_ResetUserSecurityInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/23/2010
-- Description:	Gets details for single EMS user
-- =============================================
CREATE PROCEDURE [dbo].[EMS_ResetUserSecurityInfo]
	-- Add the parameters for the stored procedure here
	@username varchar(50) = NULL, 
	@facilityIP varchar(15) = NULL,
	@password varchar(50) = NULL,
	@securityQ1 int = NULL,
	@securityA1 varchar(50) = NULL,
	@securityQ2 int = NULL,
	@securityA2 varchar(50) = NULL,
	@securityQ3 int = NULL,
	@securityA3 varchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@CompanyID int, @CompanyName nvarchar(50), @PK int
	
	SELECT	TOP 1
			@CompanyID = ID, @CompanyName = m.Name
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = c.CompanyName
	WHERE	@FacilityIP BETWEEN c.IPAddressRangeMin and c.IPAddressRangeMax

	IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
		SELECT	@PK = PrimaryKey
		FROM	MainEMS
		WHERE	Username = @username AND Company IN ('Community Hospital Watervliet', 'Borgess Health')
	ELSE
		SELECT	@PK = PrimaryKey
		FROM	MainEMS
		WHERE	Username = @username AND CompanyID = @CompanyID
		
	UPDATE	MainEMS
	SET		Password = @password, 
			SecurityQ1 = @securityQ1, SecurityA1 = @securityA1, 
			SecurityQ2 = @securityQ2, SecurityA2 = @securityA2, 
			SecurityQ3 = @securityQ3, SecurityA3 = @securityA3
	WHERE	PrimaryKey = @PK
END