/****** Object:  Procedure [dbo].[GetCmorgregion]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATEd by : Sunil N
--Date: 04/22/2019
--EXEC GetCmorgregion 

CREATE PROCEDURE [dbo].[GetCmorgregion]
as
BEGIN

SET NOCOUNT ON;

SELECT DISTINCT
--LTRIM(rtrim(brandingname)) brandingname,
LTRIM(rtrim(cmorgregion)) cmorgregion FROM Lookup_vdt_brand_cmorgregion  

END