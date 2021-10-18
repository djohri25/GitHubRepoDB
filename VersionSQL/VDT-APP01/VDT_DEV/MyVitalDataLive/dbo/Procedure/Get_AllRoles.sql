/****** Object:  Procedure [dbo].[Get_AllRoles]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Sandberg
-- Create date: 9/11/2020
-- Description:	Get all roles for a particular customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_AllRoles]
	@CustomerID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT *
    FROM [dbo].[Role] r
	WHERE r.CustID = @CustomerID
	ORDER BY r.[Description]

END