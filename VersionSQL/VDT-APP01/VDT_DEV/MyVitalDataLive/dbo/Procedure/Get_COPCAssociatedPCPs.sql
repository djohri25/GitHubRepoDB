/****** Object:  Procedure [dbo].[Get_COPCAssociatedPCPs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/29/2013
-- Description:	Get PCPs associated with the specified COPC group
-- =============================================
CREATE PROCEDURE [dbo].[Get_COPCAssociatedPCPs]  
	@CopcFacilityID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select f.NPI, dbo.FullName( LEFT(n.[Provider Last Name (Legal Name)],50), LEFT(n.[Provider First Name],50), n.[Provider Middle Name]) as pcpFullname
	from Link_CopcFacilityNPI f
		inner join LookupNPI n on f.NPI = n.NPI
	where f.CopcFacilityID = 
		case isnull(@CopcFacilityID,0)
		when 0 then f.CopcFacilityID
		else @CopcFacilityID
		end
	order by n.[Provider Last Name (Legal Name)]
END