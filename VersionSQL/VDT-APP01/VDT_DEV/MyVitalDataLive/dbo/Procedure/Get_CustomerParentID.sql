/****** Object:  Procedure [dbo].[Get_CustomerParentID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/12/2010
-- Description:	Returns the top level parent of the customer
--	e.g. Amerigroup is the top level parent of Amerigroup of Florida
-- =============================================
create PROCEDURE [dbo].[Get_CustomerParentID]
	@CustomerName varchar(50),
	@ParentCustID varchar(50) output
AS
BEGIN
	SET NOCOUNT ON;

	declare @temp table (data varchar(50))
	declare @query varchar(1000)

	if exists (select c2.cust_id 
		from hpcustomer c1
			inner join hpcustomer c2 on c1.parentid = c2.cust_id
		where c1.name = @CustomerName)
	begin
		select top 1 @ParentCustID = c2.cust_id 
		from hpcustomer c1
			inner join hpcustomer c2 on c1.parentid = c2.cust_id
		where c1.name = @CustomerName
	end
	else
	begin
		select @ParentCustID = cust_id 
		from hpcustomer
		where name = @CustomerName
	end
		
END