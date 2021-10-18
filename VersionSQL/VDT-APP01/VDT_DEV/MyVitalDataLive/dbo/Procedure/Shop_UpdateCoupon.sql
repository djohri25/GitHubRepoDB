/****** Object:  Procedure [dbo].[Shop_UpdateCoupon]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Shop_UpdateCoupon]
	@CouponId varchar(15) OUT,
	@LicenseType varchar(3),
	@LicenseTotal int,	
	@ProductId int,
	@VariantId int,
	@OrderNum int,
	@Email varchar(50)
	
AS

SET NOCOUNT ON

DECLARE @CurrentCoupon varchar(15), @Count int

SELECT @CurrentCoupon = CouponId FROM MainLicenseCoupon WHERE
OrderNum = @OrderNum AND ProductId = @ProductId AND VariantId = @VariantId 
AND LicenseType = @LicenseType

IF @CurrentCoupon IS NULL
BEGIN
	SELECT @Count = COUNT(*) FROM MainLicenseCoupon WHERE CouponId = @CouponId
	IF @Count = 0
		INSERT INTO MainLicenseCoupon (CouponId, LicenseType, LicenseTotal, 
		Email, OrderNum, ProductId, VariantId, CreationDate, ModifyDate) VALUES 
		(@CouponId, @LicenseType, @LicenseTotal,
		@Email, @OrderNum, @ProductId, @VariantId,  GETUTCDATE(), GETUTCDATE())
	ELSE
		SET @CouponId = ''
END
ELSE
	SET @CouponId = @CurrentCoupon