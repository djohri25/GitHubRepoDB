/****** Object:  Procedure [dbo].[Get_HPFullCustomerList]    Committed by VersionSQL https://www.versionsql.com ******/

-- Stored procedure
-- =============================================
-- Author:		sw
-- Create date: 04/23/2008
-- Description:	Returns the list of Health Plan customers matching 
--	the criteria
--  @User - currently logged in user. The return list will contain only his employer/customer.
--		Unless, @User has admin or superadmin rights then the list contains all customers matching @ActiveFilter
--	@ActiveFilter - might have the following values: ALL, ACTIVE, INACTIVE
-- =============================================
create PROCEDURE [dbo].[Get_HPFullCustomerList]
	@User varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Cust_ID
	  ,Name
	  ,Type
	  ,Address1
	  ,Address2
	  ,City
	  ,State
	  ,PostalCode
	  ,PrimaryAgent
	  ,Active
	FROM HPCustomer 
	where Active = 1
	order by Name
	
END