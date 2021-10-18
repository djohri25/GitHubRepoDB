/****** Object:  Procedure [dbo].[Ems_IsHealthPlanMember]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Returns count of number of health plans the MVD ID is a
--              member of.
-- =============================================
CREATE PROCEDURE [dbo].[Ems_IsHealthPlanMember]
	@mvdId VARCHAR(15)
AS
	SELECT	COUNT(*)
	FROM	Link_MVDID_CustID
	WHERE	MVDId = @mvdId