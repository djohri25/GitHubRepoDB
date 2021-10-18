/****** Object:  Procedure [dbo].[spCreatePromotionCodeStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE
CREATE 
PROCEDURE [dbo].[spCreatePromotionCodeStatus] --''
	-- Add the parameters for the stored procedure here
	@Code varchar(20),
	@Result int =0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS(SELECT 1 FROM [PromotionCode] WHERE [PromotionCode]=@Code)
		BEGIN
			SET @Result =0
		END
	ELSE
		BEGIN
			-- This is the primary table with promo code info
			INSERT INTO [PromotionCodeInfo](PromotionCode) VALUES(@Code)

			-- This talbe contains relations: promo code to MVD ID
			INSERT INTO [PromotionCode](PromotionCode,DateCreated) VALUES(@Code,GETUTCDATE())


			SET @Result = 1
		END
END