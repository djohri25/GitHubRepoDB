/****** Object:  Procedure [dbo].[Get_ShowReportSection]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Returns boolean value whether patient PDF report setion
--	should be displayed on the report or not
-- =============================================
CREATE PROCEDURE [dbo].[Get_ShowReportSection]
	@SectionName varchar(100),
	@IceNumber varchar(20),
	@username varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @showSection bit 
	set @showSection = 1

	if(@SectionName = 'PatientRefSheet')
	begin
		select @showsection = isnull(ShowPatientRefSheet,0)
		from dbo.Link_MVDID_CustID li 
			inner join hpcustomer c on li.cust_id = c.cust_id
		where li.mvdid = @IceNumber
	end

	select @showSection
END