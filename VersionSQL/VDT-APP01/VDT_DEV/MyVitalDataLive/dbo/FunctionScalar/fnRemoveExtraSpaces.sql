/****** Object:  Function [dbo].[fnRemoveExtraSpaces]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[fnRemoveExtraSpaces](@Text varchar(1000))
RETURNS varchar(1000)
AS
BEGIN

While CharIndex('  ',@Text  ) > 0
Begin
   set @Text = Replace(@Text, '  ', ' ')
End

RETURN @Text

END