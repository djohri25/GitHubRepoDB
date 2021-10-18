/****** Object:  Procedure [dbo].[DashboardHCCSuspects]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:	EXEC dbo.DashboardHCCSuspects @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardHCCSuspects]
	@CustID INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT Suspect, Pct
	FROM 
	(
	VALUES 
	 ('HCC 1', 25)
	,('HCC 45', .73)
	,('HC 105', 3.7)
	) x (Suspect, Pct)

END