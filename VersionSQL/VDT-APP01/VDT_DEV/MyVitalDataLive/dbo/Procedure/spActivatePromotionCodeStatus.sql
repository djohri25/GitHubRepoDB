/****** Object:  Procedure [dbo].[spActivatePromotionCodeStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE
CREATE 
PROCEDURE [dbo].[spActivatePromotionCodeStatus] --''
	-- Add the parameters for the stored procedure here
	@Code varchar(20),
	@MyVitalDataID varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS(SELECT 1 FROM [PromotionCode] WHERE [PromotionCode]=@Code)
		BEGIN
			IF EXISTS(SELECT 1 FROM [PromotionCode] WHERE [PromotionCode]=@Code AND [MyVitalDataID] IS NULL)
				BEGIN
					UPDATE [PromotionCode] SET [DateActivated]=GETUTCDATE(),MyVitalDataID=@MyVitalDataID WHERE [PromotionCode]=@Code AND [MyVitalDataID] IS NULL
					SELECT [PromotionCode] , [DateActivated], 'ACTIVATED' AS [STATUS] FROM [PromotionCode] WHERE [PromotionCode]=@Code AND [MyVitalDataID] = @MyVitalDataID
				END
			ELSE
				BEGIN
					INSERT INTO [PromotionCode] (PromotionCode,MyVitalDataID,DateCreated,DateActivated) VALUES(@Code,@MyVitalDataID,GETUTCDATE(),GETUTCDATE()) 
					SELECT [PromotionCode] , [DateActivated], 'ACTIVATED' AS [STATUS] FROM [PromotionCode] WHERE [PromotionCode]=@Code AND [MyVitalDataID] = @MyVitalDataID
				END
		END
	ELSE
		BEGIN
			SELECT 'NOT FOUND' AS [STATUS]
		END
END