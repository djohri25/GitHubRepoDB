/****** Object:  Procedure [dbo].[spGetDynamicLeftMenuByParentID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[spGetDynamicLeftMenuByParentID] 
	@ParentID int,
	@MVDID varchar(15) = null,
	@Language BIT = 1
AS

BEGIN
	SET NOCOUNT ON;

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

	-- Note: currently we customize the menu only for Microsoft users with promo code MS2008
	if (@PromoCode = 'MS2008')
	begin
		-- Hide Change PIN item from Microsoft users
		-- Note: menuLink is less likely to change than displayed item name
		IF(@Language = 1)
			BEGIN -- 1 = english
				SELECT IdParent,MenuName, MenuLink FROM MainMenuTree 
				WHERE IDPARENT = @ParentID
					and menuLink not like '%ChangePassword.aspx'
				ORDER BY IdSort;
			END
		ELSE
			BEGIN -- 0 = spanish
				SELECT IdParent,MenuNameSpanish [MenuName], MenuLink FROM MainMenuTree 
				WHERE IDPARENT = @ParentID
					and menuLink not like '%ChangePassword.aspx' AND MenuNameSpanish IS NOT NULL
				ORDER BY IdSort;
		END	
	end
	else
	begin
		IF(@Language = 1)
			BEGIN -- 1 = english
				SELECT IdParent,MenuName, MenuLink FROM MainMenuTree 
				WHERE IDPARENT = @ParentID
				ORDER BY IdSort;
			END
		ELSE
			BEGIN -- 0 = spanish
				SELECT IdParent,MenuNameSpanish[MenuName], MenuLink FROM MainMenuTree 
				WHERE IDPARENT = @ParentID AND MenuNameSpanish IS NOT NULL
				ORDER BY IdSort;
			END
	end
END