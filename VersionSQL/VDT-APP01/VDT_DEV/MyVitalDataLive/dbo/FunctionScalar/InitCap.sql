/****** Object:  Function [dbo].[InitCap]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 05/13/2010
-- Description:	Function capitalizes the first letter of every word in the input string
--              and lowers the case on the rest of the string.  Exceptions are provided
--              to properly capitalize names with II or III.
-- =============================================
CREATE FUNCTION [dbo].[InitCap] 
(
	@input nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	RETURN dbo.InitCapRoot(@input, ' ii iii ', '')
END