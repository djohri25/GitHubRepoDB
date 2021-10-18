/****** Object:  Procedure [dbo].[spGetPromotionCodeDetails]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE
CREATE 
PROCEDURE [dbo].[spGetPromotionCodeDetails]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT [PromotionCode],[DateCreated],[DateActivated] FROM [PromotionCode]
	ORDER BY [DateCreated]
END