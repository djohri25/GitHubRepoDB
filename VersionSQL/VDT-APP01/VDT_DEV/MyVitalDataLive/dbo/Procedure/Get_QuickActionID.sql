/****** Object:  Procedure [dbo].[Get_QuickActionID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_QuickActionID
(
	@p_ActionName varchar(250),
	@p_ID bigint OUTPUT,
	@p_CustomerId int,
	@p_ProductId int
)
AS
BEGIN
	SELECT
	@p_ID = ID
	FROM
	QuickAction
	WHERE
	ActionName = @p_ActionName
	AND CustomerId = @p_CustomerId
	AND ProductId = @p_ProductId
END;