/****** Object:  Procedure [dbo].[spGetPromotionCodeStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Jan,Saqib>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--CREATE
CREATE 
PROCEDURE [dbo].[spGetPromotionCodeStatus] --''
	-- Add the parameters for the stored procedure here
	@Code varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS(SELECT 1 FROM [PromotionCode] WHERE [PromotionCode]=@Code)
		BEGIN
			IF EXISTS(SELECT 1 FROM [PromotionCode] WHERE [PromotionCode]=@Code)
				BEGIN
					SELECT [PromotionCode] , [DateActivated], 'ACTIVE' AS [STATUS] FROM [PromotionCode] WHERE [PromotionCode]=@Code
				END
--				BEGIN
--					--UPDATE [PromotionCode] SET [DateActivated]=GETUTCDATE() WHERE [PromotionCode]=@Code
--					SELECT [PromotionCode] , [DateActivated], 'ACTIVE' AS [STATUS] FROM [PromotionCode] WHERE [PromotionCode]=@Code
--				END
--			ELSE
--				BEGIN
--					SELECT [PromotionCode] , [DateActivated], 'PREVIOUSLY ACTIVATED' AS [STATUS] FROM [PromotionCode] WHERE [PromotionCode]=@Code
--				END
		END
	ELSE
		BEGIN
			SELECT 'NOT FOUND' AS [STATUS]
		END
END