/****** Object:  Procedure [dbo].[Get_ProviderLinkUserTINInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
------------------------------------------------
--	Author		Date		Comments
------------------------------------------------
--	dpatel		06/12/2018	Added GroupId column to returning dataset
-- =============================================
CREATE PROCEDURE [dbo].[Get_ProviderLinkUserTINInfo]
	@UserName VARCHAR(30)
AS

BEGIN

	SELECT C.Cust_id AS CustomerID, C.Name AS CustomerName, FirstName, LastName, Organization, GroupName AS TIN, G.SecondaryName AS GroupName, G.ID as GroupId
	FROM dbo.MDUser M 
	JOIN dbo.Link_MDAccountGroup L ON L.MDAccountID = M.ID 
	JOIN dbo.MDGroup G ON G.ID = L.MDGroupID
	JOIN dbo.HPCustomer C ON C.Cust_ID = G.CustID_Import
	WHERE M.UserName = @UserName 

END