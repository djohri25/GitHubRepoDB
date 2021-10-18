/****** Object:  View [dbo].[vwCustomerUsers]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW
vwCustomerUsers
AS
SELECT DISTINCT
hpaga.Agent_ID UserID,
hpag.Cust_ID CustomerID
FROM
Link_HPAlertGroupAgent hpaga
INNER JOIN HPAlertGroup hpag
ON hpag.ID = hpaga.Group_ID;