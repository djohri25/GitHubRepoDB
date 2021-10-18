/****** Object:  Procedure [dbo].[EMS_LookupAccount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/22/2010
-- Description:	Verifies whether given username and facility exists
-- =============================================
CREATE PROCEDURE [dbo].[EMS_LookupAccount] 
	@Username varchar(50) = NULL, 
	@FacilityIP varchar(15) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@CompanyID int, @CompanyName nvarchar(50)
	
	SELECT	TOP 1
			@CompanyID = ID, @CompanyName = m.Name
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = c.CompanyName
	WHERE	@FacilityIP BETWEEN c.IPAddressRangeMin and c.IPAddressRangeMax

	DECLARE	@result int
	SET		@result = 0
	
	IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
		SELECT	TOP 1 @result = 1
		FROM	MainEMS
		WHERE	Username = @Username AND Company IN ('Community Hospital Watervliet', 'Borgess Health')
	ELSE
		SELECT	TOP 1 @result = 1
		FROM	MainEMS
		WHERE	Username = @Username AND CompanyID = @CompanyID

	SELECT	@result
END