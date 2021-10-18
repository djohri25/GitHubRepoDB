/****** Object:  Function [dbo].[Get_ListofColumns]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[Get_ListofColumns] 
(
	@TableName varchar(150), @Cols_Exclude	varchar(1000)
)
RETURNS Varchar(8000)
-- =============================================
-- Author:		PPetluri
-- Create date: 05/31/2017
-- Description:	Gets all the columns of the table excpet the onles which are mentioned in exclude pram
-- =============================================
AS
BEGIN
	declare @colList varchar(max);

	SELECT  @colList = STUFF
    (
        ( 
            SELECT '], [' + Column_name
            FROM INFORMATION_SCHEMA.columns
            where table_name = @TableName 
			AND column_name not in (Select Item from [dbo].[splitstring](@Cols_Exclude,',')) ORDER BY ORDINAL_POSITION
            FOR XML PATH('')
        ), 1, 2, ''
    ) + ']';

	-- Return the result of the function
	RETURN @colList

END