/****** Object:  Procedure [dbo].[Get_PageTitle]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_PageTitle] 
	@PageId int,
	@Language BIT = 1
AS

BEGIN
	SET NOCOUNT ON;
		IF(@Language = 1)
			BEGIN -- 1 = english
				SELECT MenuName FROM MainMenuTree
				WHERE ItemID = @PageId
			END
		ELSE
			BEGIN -- 0 = spanish
				SELECT MenuNameSpanish FROM MainMenuTree
					WHERE ItemID = @PageId
			END
END