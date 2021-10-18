/****** Object:  Function [dbo].[Split]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 09/29/2008
-- Description:	 Parses string of elements separated by @delimiter and
--		returns a table with one row for each element
-- =============================================
CREATE FUNCTION [dbo].[Split](@data NVARCHAR(MAX), @delimiter NVARCHAR(5))
RETURNS @t TABLE (data NVARCHAR(max))
AS
BEGIN
    
    DECLARE @textXML XML;
    SELECT    @textXML = CAST('<d>' + REPLACE(@data, @delimiter, '</d><d>') + '</d>' AS XML);

    INSERT INTO @t(data)
    SELECT  T.split.value('.', 'nvarchar(max)') AS data
    FROM    @textXML.nodes('/d') T(split)
    
    RETURN
END