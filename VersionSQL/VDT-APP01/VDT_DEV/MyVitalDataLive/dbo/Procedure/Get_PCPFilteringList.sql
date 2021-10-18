/****** Object:  Procedure [dbo].[Get_PCPFilteringList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PCPFilteringList]
	@CustomerID varchar(50) = null
AS
BEGIN
	--set @Customer = 'parkland'

	SET NOCOUNT ON;
	
	declare @ParentCustID int
	
	if( @CustomerID is null OR @CustomerID = '')
	begin
		select dbo.FullName(LastName,FirstName,'') + ' (' + NPI + ')' as 'Name', NPI
		from dbo.AsthmaReport_NPI	
		order by LastName
	end
	else
	begin
		if exists (select Cust_ID from HPCustomer where Cust_ID = @CustomerID and ParentID is null)
		begin
			set @ParentCustID = @CustomerID
		end
		else
		begin
			select @ParentCustID = ParentID from HPCustomer where Cust_ID = @CustomerID 
		end	
				
		select dbo.FullName(LastName,FirstName,'') + ' (' + NPI + ')' as 'Name', NPI
		from dbo.AsthmaReport_NPI	
		where custID = @ParentCustID
		order by LastName		
	end		
END