/****** Object:  Procedure [dbo].[Get_FacilityNPI]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/28/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FacilityNPI]
	@FacilityName varchar(100),
	@VisitSourceName varchar(100),
	@NPI varchar(20) output
AS
BEGIN
	SET NOCOUNT ON;

    -- Since facility name can be same for different facilities in different cities/states then currently we can only use this 
	-- method for visits coming from discharge reports

	if(@VisitSourceName = 'Discharge Data')
	begin
		select @NPI = NPI
		from mainEmsHospital
		where Name = @FacilityName

		if(isnull(@NPI,'') = '')
		begin
			select top 1 @NPI = MainNPI
			from DischargeReportFacility
			where Name = @FacilityName
		end

		if(isnull(@NPI,'') = '')
		begin
			-- If not found store it so it may be looked up and reported on later
			insert into DischargeReportFacility_Unknown(FacilityName,VisitSourceName)
			values(@FacilityName, @VisitSourceName)
		end
	end
END