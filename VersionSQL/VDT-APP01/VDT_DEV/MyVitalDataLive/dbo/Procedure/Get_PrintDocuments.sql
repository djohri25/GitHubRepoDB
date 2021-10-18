/****** Object:  Procedure [dbo].[Get_PrintDocuments]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_PrintDocuments]
	@MVDID varchar(15),
	@Language BIT = 1
as
begin

	SET NOCOUNT ON

	declare @PromoCode varchar(10), 
			@GroupID varchar(15),
			@PrimaryOwnerMVDID varchar(15) -- Primary owner of the account

	-- Get owner ID
	if exists (select icenumber from MainICENUMBERGroups where icenumber = @MVDID and MainAccount = '1')
	begin
		-- The user is the primary owner of the account
		set @PrimaryOwnerMVDID = @MVDID
	end
	else
	begin
		-- The account is owned by other user
		select @GroupId = ICEGROUP from dbo.MainICENUMBERGroups where icenumber = @MVDID

		select @PrimaryOwnerMVDID = ICENUMBER from MainICENUMBERGroups where ICEGROUP = @GroupId and MainAccount = '1'
	end

	-- Get corresponding promo code if exists
	select @PromoCode = PromotionCode from PromotionCode where MyVitalDataID = @PrimaryOwnerMVDID

	if len(isnull(@PromoCode,'')) = 0 or not exists 
		(select PromoCode from dbo.Link_PromoCode_Document where PromoCode = @PromoCode)
	begin
		-- Return Default List
		select (
				SELECT TOP 1 
					CASE @Language
						WHEN  1 
							THEN [Description]
						WHEN 0 
							THEN DescriptionSpanish
					END  
				) [Description] , Link 
		from dbo.LookupPrintDocument a
			inner join Link_PromoCode_Document b on a.ID = b.PrintDocumentId
		where b.PromoCode = 'DEFAULT'
		order by OrderId
	end
	else
	begin
		-- Return Custom List
		select (
				SELECT TOP 1 
					CASE @Language
						WHEN  1 
							THEN [Description]
						WHEN 0 
							THEN DescriptionSpanish
					END  
				) [Description], Link 
		from dbo.LookupPrintDocument a
			inner join Link_PromoCode_Document b on a.ID = b.PrintDocumentId
		where b.PromoCode = @PromoCode
		order by OrderId		
	end	
end