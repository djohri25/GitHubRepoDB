/****** Object:  Procedure [dbo].[Get_HospitalByIP]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/31/2008
-- Description:	Returns hospital by name
-- =============================================
CREATE PROCEDURE [dbo].[Get_HospitalByIP]
	@IP varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT	ID,
			Name,
			Address,
			City,
			State,
			Zip,
			ContactName,
			ContactEmail,
			Substring(ContactPhone,1,3) AS ContactPhoneArea,
			Substring(ContactPhone,4,3) AS ContactPhonePrefix,
			Substring(ContactPhone,7,4) AS ContactPhoneSuffix,
			dbo.FormatPhone(ContactPhone) AS ContactPhone,
			Website,
			IP,
			ApprovedDate,
			Active,
			CredentialsRequired,
			AutoApprove,
			RestrictedEmailDomains,
			RequiresDetailConfirmation
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = CompanyName
	WHERE	dbo.FormatIPAddress(@IP) BETWEEN IPAddressRangeMin AND IPAddressRangeMax
END