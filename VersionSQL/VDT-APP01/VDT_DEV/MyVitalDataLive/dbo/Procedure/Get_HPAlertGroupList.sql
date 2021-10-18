/****** Object:  Procedure [dbo].[Get_HPAlertGroupList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 9/23/2009
-- Description:	 Retrieves the list of Alert Groups for particular customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPAlertGroupList]
	@CustomerId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select ID, Name, Description, Cust_ID,
		(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
		Active
	from HPAlertGroup a 
	where Cust_ID = @CustomerId
END