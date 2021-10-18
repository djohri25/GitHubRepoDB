/****** Object:  Function [dbo].[GetPTDate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetPTDate]
	(
	)
RETURNS datetime
AS
BEGIN
	DECLARE @date datetime
	SET @date = DATEADD(hour, -8, GETUTCDATE())
	IF dbo.InDST(@date) = 1
		SET @date = DATEADD(hour, 1, @date)
	RETURN @date
END