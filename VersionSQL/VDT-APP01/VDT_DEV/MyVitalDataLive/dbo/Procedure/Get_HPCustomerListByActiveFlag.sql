/****** Object:  Procedure [dbo].[Get_HPCustomerListByActiveFlag]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/7/2009
-- Description:	Returns the list of Health Plan customers
--	matching the search criteria
--	@ActiveFilter - might have the following values: ALL, ACTIVE, INACTIVE
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPCustomerListByActiveFlag]
	@ActiveFilter varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	declare @query varchar(1000)

	set @query = 'select cust_id, name from HPCustomer where ParentID is null '

    if( len(isnull(@ActiveFilter,'')) > 0 and @ActiveFilter != 'ALL')
	begin
		-- Add selection criteria
		if( @ActiveFilter = 'ACTIVE')
		BEGIN
			select @query = @query + ' and Active = 1'
		END
		ELSE if( @ActiveFilter = 'INACTIVE')
		BEGIN
			select @query = @query + ' and Active = 0 or Active is null'
		END
	end
	
	exec(@query)
END