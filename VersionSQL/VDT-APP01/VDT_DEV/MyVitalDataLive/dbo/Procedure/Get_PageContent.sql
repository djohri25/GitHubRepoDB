/****** Object:  Procedure [dbo].[Get_PageContent]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_PageContent] 
	@PageId varchar(50),
	@Language BIT = 1
As

SET NOCOUNT ON

IF(@Language = 1)
	BEGIN -- 1 = english
		select TextEnglish from WebPageContentText where Pageid = @PageId
	END
ELSE
	BEGIN -- 0 = spanish
		select TextSpanish from WebPageContentText where Pageid = @PageId
	END