/****** Object:  Procedure [dbo].[Get_CustomerDetailsByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_CustomerDetailsByID]
@CustID int
AS
BEGIN
SELECT Cust_ID,name FROM HPCustomer h WHERE h.Cust_ID = 13
END