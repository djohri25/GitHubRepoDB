/****** Object:  Procedure [dbo].[Get_PromoCodeInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/17/2008
-- Description:	Returns info about promotion code
-- =============================================
CREATE PROCEDURE [dbo].[Get_PromoCodeInfo]
	@PromotionCode varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	select IsSendWelcomeEmail from PromotionCodeInfo where PromotionCode = @PromotionCode
END