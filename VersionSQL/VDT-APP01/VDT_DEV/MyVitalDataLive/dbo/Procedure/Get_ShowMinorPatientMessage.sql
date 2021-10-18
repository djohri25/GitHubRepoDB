/****** Object:  Procedure [dbo].[Get_ShowMinorPatientMessage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/13/2010
-- Description:	Returns a flag whether to show the popup notification
--		about minor patient
-- =============================================
create PROCEDURE [dbo].[Get_ShowMinorPatientMessage]
	@ICENUMBER varchar(20),
	@Username varchar(50),
	@UserType varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @showMessage bit,
		@companyID int,
		@companyName varchar(50),
		@minorLimit int
 
	select @showMessage = 0,
		@minorLimit = 0

	if exists(select mvdid from dbo.Link_MemberId_MVD_Ins where mvdid = @icenumber)
	begin
		-- Don't display for health plan members since those members/contacts don't need to be notified about hospital admit
		set @showMessage = 0
	end
	else
	begin
		if(@userType = 'CONTACT')
		begin
			select @companyID = ID, @companyName = Name from mainemshospital where contactEmail = @Username
		end
		else
		begin
			select @companyID = CompanyID, @companyName = Company from mainems where email = @Username
		end

		if( (@companyID is null or @companyID = '') and  (@companyName is not null and @companyName <> '') )
		begin
			-- Try to identify the hospital by name
			select @companyID = ID from mainEMSHospital where Name = @companyName
		end

		SELECT @minorLimit = isnull(MinorsAge,0)
		FROM MainEMSHospital
		WHERE ID = @companyID

		if exists (select recordNumber 
			from mainpersonaldetails
			where icenumber = @ICENUMBER and dob is not null and dbo.GetAgeInYears( dob, getutcdate()) < @minorLimit)
		begin
			set @showMessage = 1
		end
	end    

	select @showMessage
END