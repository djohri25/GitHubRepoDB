/****** Object:  Procedure [dbo].[Get_AccountCoupon]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_AccountCoupon] 

	@Coupon varchar(15),
	@Result int OUT
As

SET NOCOUNT ON

DECLARE @Count int

SELECT @Count = COUNT(*) FROM MainLicenseCoupon
WHERE CONVERT(VARBINARY, CouponId) = CONVERT(VARBINARY, @Coupon) 
AND LicenseType = 'NEW'


IF @Count = 0
	SET @Result = 0
ELSE
BEGIN
	SELECT @Result = LicenseTotal - IsUsed FROM MainLicenseCoupon
	WHERE CONVERT(VARBINARY, CouponId) = CONVERT(VARBINARY, @Coupon) 
	AND LicenseType = 'NEW'
	IF @Result = 0
		SET @Result = -1
END