/****** Object:  Procedure [dbo].[Get_ActionTypes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Priya,Petluri>
-- Create date: <09/07/2016>
-- Description:	<Get all ActionTypes for specific Cust_id or ActionTypeD>
-- =============================================

CREATE PROCEDURE [dbo].[Get_ActionTypes]
@Cust_ID	INT,
@ActionTypeID	INT	= NULL,
@LobId Int = null	

AS
BEGIN
	SET NOCOUNT ON;

	SELECT ActionTypeID
		, ActionTypeDescription
		, Cust_ID
		, LobId
		, Case IsActive when 1 then 1 else 0 end as IsActive
		, CreatedDate
		, UpdatedDate
	FROM Lookup_HPActionType
	Where Cust_ID = @Cust_ID 
	AND (ActionTypeID = @ActionTypeID or @ActionTypeID is NULL)
	and (LobId = @LobId or @LobId is null)
	and IsActive = 1
END