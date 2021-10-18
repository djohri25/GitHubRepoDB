/****** Object:  Procedure [dbo].[GetHedisIncentiveYear]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	
-- Example: EXEC dbo.GetHedisIncentiveYear @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[GetHedisIncentiveYear]
	@CustID INT,
	@Year int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @Year = TRY_CAST(Label AS INT)
	FROM [dbo].[Lookup_Generic_Code]
	WHERE CodeTypeID = 11
	AND Cust_ID = @CustID
END