/****** Object:  Procedure [dbo].[Get_SecQuestion]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SecQuestion]
	@Language BIT = 1,
	@Active BIT = 1
AS

SET NOCOUNT ON
IF @Language = 1
	-- 1 = english
	Select	*
	FROM	LookupSecurityQuestion
	WHERE	Active = @Active OR @Active IS NULL
	ORDER BY Question
ELSE
	-- 0 = spanish
	SELECT	QuestionID, QuestionSpanish [Question]
	FROM	LookupSecurityQuestion
	WHERE	QuestionSpanish IS NOT NULL AND (Active = @Active OR @Active IS NULL)
	ORDER BY Question