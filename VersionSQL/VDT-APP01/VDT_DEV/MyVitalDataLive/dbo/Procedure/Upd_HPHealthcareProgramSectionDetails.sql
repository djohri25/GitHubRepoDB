/****** Object:  Procedure [dbo].[Upd_HPHealthcareProgramSectionDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPHealthcareProgramSectionDetails]
	@CustomerID int,
	@HCProgramsSectionDescription varchar(300),
	@UserID varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	update hpCustomer 
		set HealthcareProgramsSectionDesc = @HCProgramsSectionDescription,
			UpdatedBy = @UserID
	where cust_id = dbo.get_hpparentcustomerid(@customerID)
END