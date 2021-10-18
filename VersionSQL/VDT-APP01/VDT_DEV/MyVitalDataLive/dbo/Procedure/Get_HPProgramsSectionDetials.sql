/****** Object:  Procedure [dbo].[Get_HPProgramsSectionDetials]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPProgramsSectionDetials]
	@CustomerID int
AS
BEGIN
	SET NOCOUNT ON;

	select HealthcareProgramsSectionDesc 
	from hpCustomer
	where cust_id = dbo.Get_HPParentCustomerID(@CustomerID)
END