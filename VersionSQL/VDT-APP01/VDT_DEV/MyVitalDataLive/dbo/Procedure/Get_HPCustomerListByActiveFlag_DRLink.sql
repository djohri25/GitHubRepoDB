/****** Object:  Procedure [dbo].[Get_HPCustomerListByActiveFlag_DRLink]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[Get_HPCustomerListByActiveFlag_DRLink]
	@NPI varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

   select a.cust_id, a.name from HPCustomer a
   join dbo.Lookup_DRLink_NPI_to_CustID b on 
   a.cust_id = b.cust_id where b.NPI = @NPI

END