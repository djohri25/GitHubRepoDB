/****** Object:  Procedure [dbo].[Create_RootMenu]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Create_RootMenu]

AS

BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TEMPVALUES (ID INT, IDSORT INT, IDPARENT INT,MENUNAME VARCHAR(30), MENULINK VARCHAR(50))

	Declare @ParentID as int
	Select @ParentID = min(IdParent) FROM MainMenuTree
	
	Declare @SortID as int
	Select @SortID = min(IdSort) FROM MainMenuTree

	WHILE (@ParentID <= (select COUNT(IdParent) FROM MainMenuTree WHERE IdParent = 0))
	Begin

	INSERT #TEMPVALUES
	SELECT Id, IdSort, IdParent, MenuName, MenuLink FROM MainMenuTree
	where IdParent = 0 and IdSort = @SortId
	ORDER BY IdParent, IdSort 
	
	Select @SortID = @SortID + 1
	Select @ParentID = @ParentID + 1

		INSERT #TEMPVALUES
		SELECT Id, IdSort, IdParent, MenuName, MenuLink FROM MainMenuTree
		where IdParent = @ParentID 
		ORDER BY IdParent, IdSort 
		

	End

	SELECT * FROM #TEMPVALUES

END