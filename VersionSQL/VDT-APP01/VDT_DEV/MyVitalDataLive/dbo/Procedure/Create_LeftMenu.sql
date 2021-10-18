/****** Object:  Procedure [dbo].[Create_LeftMenu]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Create_LeftMenu] 
	@CategoryId int,
	@Language BIT = 1

AS

BEGIN
	SET NOCOUNT ON;

	create table #tempResult (idparent int, menuname varchar(50),MenuNameSpanish varchar(50), menulink varchar(200), ItemId  int, idSort int, isContentDynamic bit)

	IF(@Language = 1)
		BEGIN -- 1 = english
			insert into #tempResult(idparent, menuname, menulink, ItemId, idSort,isContentDynamic)
			SELECT IdParent,MenuName, MenuLink,ItemId,idsort,isContentDynamic FROM MainMenuTree
			WHERE IDPARENT = @CategoryId
			ORDER BY IdSort
		END
	ELSE
		BEGIN -- 0 = spanish
			insert into #tempResult(idparent, MenuName, menulink, ItemId, idSort,isContentDynamic)
			SELECT IdParent,MenuNameSpanish, MenuLink,ItemId,idsort,isContentDynamic FROM MainMenuTree
			WHERE IDPARENT = @CategoryId AND MenuNameSpanish IS NOT NULL
			ORDER BY IdSort
		END
	-- update only links which don't have argument list and the "dynamic content" flag is set
	update #tempResult set menulink = MenuLink + '?cID=' + convert(varchar(20), IdParent) + 
		'&subID=' + convert(varchar(20), ItemId)
	where len(MenuLink) = len(replace(MenuLink,'?cId','')) and len(MenuLink) > 0
		and isContentDynamic = '1'

	select IdParent,MenuName, MenuLink from #tempResult

--	SELECT IdParent,MenuName, MenuLink + '?cID=' + convert(varchar(20), IdParent) + 
--		'&subID=' + convert(varchar(20), ItemId) as MenuLink FROM MainMenuTree
--	WHERE IDPARENT = @CategoryId
--	ORDER BY IdSort

	drop table #tempResult
END