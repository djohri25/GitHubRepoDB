/****** Object:  Procedure [dbo].[GetCustomerIdByTin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerIdByTin]
 @TIN VARCHAR(250)
,@CustID INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT DISTINCT @CustID =  CustID_Import
	FROM dbo.MDUser u
	JOIN dbo.Link_MDAccountGroup ag ON u.ID = ag.MDAccountID
	JOIN dbo.MDGroup g ON ag.MDGroupID = g.ID
	JOIN dbo.Link_MDGroupNPI n ON g.ID = n.MDGroupID
	WHERE u.username = @TIN

END