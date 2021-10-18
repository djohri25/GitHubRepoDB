/****** Object:  Function [dbo].[Get_CareQForAdmissionAutoQ]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/24/2019
-- Description:	Get appropriate CareQ for Admission AutoQ based on member's CMOrgRegion
-- 03/13/2020	dpatel	Added ARSTATEPOLICE AND HA CmOrgRegion in conditions.
-- 12/10/2020	dpatel/snokku Implement HAEXCHNG CM Org Region
-- 12/18/2020	mgrover Implement BRYCE and extend the Barb East / Barb West company key list (TFS 4177)
-- 04/28/2021	mgrover Implement Chambers Bancshares, Greenway Equipment and Riceland Foods and extend the Barb East / Barb West company key list (TFS 5145)
-- 04/28/2021	mgrover Implement Chicot Memorial Medical Center and extend the Barb East / Barb West company key list (TFS 5146)
-- 05/12/2021	mgrover Implement New BlueTouchPoint Groups and Revisions to AutoQ Routing (TFS 5275)
-- 05/12/2021	mgrover Implement Hugg and Hall Equipment (TFS 5147)
-- =============================================
CREATE FUNCTION [dbo].[Get_CareQForAdmissionAutoQ]
(
	@MVDID varchar(50)
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GroupName nvarchar(50)

	Set @GroupName = (SELECT 
		   case when FM.CmOrgRegion in('WALMART','ABB','JBHUNT','TYSON','EXCHNG','ASEPSE','ARSTATEPOLICE','HA', 'HAEXCHNG', 'BRYCE','SIMMONS_BANK') THEN 'Nurse Nav Admission'
		   when FM.CmOrgRegion IN('BARB_EAST','BARB_WEST') AND COMPANYKEY in(2,306,2864,11794,16932,17517,50025,15463,19003,426,18776,440,11438,16042,19571,217,22675,11145,17387,21207,23952,3821) then 'Nurse Nav Admission'
		   --when CMORGREGION in('FEP') THEN 'FEP (NO AD GROUP YET)'			--disabled right now since no HpAlertGroup exist
		   --when CMORGREGION IN('MEDICAREADV') THEN 'MA (NO AD GROUP YET)'		--disabled right now since no HpAlertGroup exist
		   else 'Clinical Support' 
		   end as NewQ
		   FROM FinalMember FM 
		   WHERE MVDID = @MVDID)

	-- Return the result of the function
	RETURN @GroupName

END

--select * from HpALertGroup