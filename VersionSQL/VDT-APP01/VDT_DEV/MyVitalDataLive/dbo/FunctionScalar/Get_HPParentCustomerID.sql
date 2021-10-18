/****** Object:  Function [dbo].[Get_HPParentCustomerID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Get_HPParentCustomerID] 
(
	@CustomerID int
)
RETURNS int
AS
BEGIN
	declare @ParentID int

	if exists(select cust_id from hpcustomer where cust_id = @CustomerID and parentid is null)
	begin
		set @ParentID = @customerID
	end
	else
	begin
		select @ParentID = parentid
		from hpcustomer 
		where cust_id = @CustomerID
	end

	RETURN @ParentID
END