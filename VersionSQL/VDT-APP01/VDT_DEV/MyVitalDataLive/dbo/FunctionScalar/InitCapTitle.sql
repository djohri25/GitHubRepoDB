/****** Object:  Function [dbo].[InitCapTitle]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 05/13/2010
-- Description:	Function capitalizes the first letter of every word in the input string
--              and lowers the case on the rest of the string.  Exceptions are provided
--              for properly capitalizing titles.
-- =============================================
CREATE FUNCTION [dbo].[InitCapTitle]
(
	@input nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	RETURN dbo.InitCapRoot(@input, ' cd dvd ii iii ', ' a an the and or by in of ')
END