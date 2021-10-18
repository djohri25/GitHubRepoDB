/****** Object:  Function [dbo].[IsNoteEditable]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsNoteEditable]
(
	@ModifiedBy varchar(50), @ModifiedByType varchar(50), @UserID varchar(50), @UserType varchar(50), @note varchar(max)
)
RETURNS int
AS
BEGIN
	declare @result int

	if( (@ModifiedBy + isnull(@ModifiedByType,'')) = (@UserID + @UserType) 
		AND @note not like '%Report Viewed.' 
		AND @note not like '%Record viewed.'
		AND @note not like '%Alert viewed.')
	begin
		set @result = 1
	end
	else
	begin
		set @result = 0
	end

	RETURN @result
END