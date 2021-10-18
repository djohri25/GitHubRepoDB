/****** Object:  Procedure [dbo].[Get_ProductInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_ProductInfo]
@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 Medicaid,ProductType FROM MainInsurance mi WHERE  mi.ICENUMBER = @MVDID ORDER BY ModifyDate desc




   -- Select Medicaid,ProductType from MainInsurance m where m.ICENUMBER = @MVDID

 END