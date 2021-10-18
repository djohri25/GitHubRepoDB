/****** Object:  Procedure [dbo].[Get_HPStatusList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/07/2008
-- Description:	 Returns the list of available alert statuses
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPStatusList]
	@CustID int = null
AS
BEGIN
	SET NOCOUNT ON

	declare @parentHPCustomerID int
	
	if(@CustID is null)
	begin
		SELECT	ID, Name 
		FROM	LookupHPAlertStatus
	end
	else
	begin				
		set @parentHPCustomerID = dbo.Get_HPParentCustomerID(@CustID)
	
		SELECT	ID, Name 
		FROM	LookupHPAlertStatus s
			inner join dbo.Link_HpCustomer_AlertStatus li on s.ID = li.StatusID
		where CustID = @parentHPCustomerID
	end
END