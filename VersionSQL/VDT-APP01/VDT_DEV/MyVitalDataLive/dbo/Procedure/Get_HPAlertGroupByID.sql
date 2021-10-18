/****** Object:  Procedure [dbo].[Get_HPAlertGroupByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 9/23/2009
-- Description:	 Retrieves the Alert Group identified by ID
-- =============================================
create PROCEDURE [dbo].[Get_HPAlertGroupByID]
	@GroupId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select ID,Name, Description, Cust_ID,
		(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
		Active
	from HPAlertGroup a 
	where ID = @GroupId
END