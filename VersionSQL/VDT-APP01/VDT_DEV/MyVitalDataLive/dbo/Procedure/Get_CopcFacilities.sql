/****** Object:  Procedure [dbo].[Get_CopcFacilities]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_CopcFacilities]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
      ,FacilityName
      ,Active
      ,CreationDate
      ,ModifyDate
  FROM CopcFacility
  order by FacilityName
  
END