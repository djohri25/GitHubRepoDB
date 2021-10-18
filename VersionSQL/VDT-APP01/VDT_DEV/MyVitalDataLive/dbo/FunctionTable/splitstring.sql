/****** Object:  Function [dbo].[splitstring]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		PPetluri
-- Create date: 09/30/2015
-- =============================================
CREATE FUNCTION [dbo].[splitstring] ( @stringToSplit VARCHAR(MAX), @delimiter VARCHAR(1) )
RETURNS
 @returnList TABLE ([ID] [INT] IDENTITY(1,1), [Item] [nvarchar] (500), [Len] [Int])
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(@delimiter, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@delimiter, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList ([Item],[Len])
  SELECT @name, ISNULL(LEN(@name),0)

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList ([Item],[Len])
 SELECT @stringToSplit, ISNULL(LEN(@stringToSplit),0)

 RETURN
END