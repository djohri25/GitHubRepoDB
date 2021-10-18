/****** Object:  Function [dbo].[Get_CCRFormatDateTime]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/17/2009
-- Description:	Returns XML formated date time node
--	according to CCR standard
-- =============================================
CREATE FUNCTION [dbo].[Get_CCRFormatDateTime]
(	@Type varchar(50), @Value datetime
)
RETURNS XML
AS
BEGIN
	-- Declare the return variable here
	DECLARE @XML xml

	set @XML =
	(select (select @Type for xml path('Text'),type,elements) as [Type],
		(left(CONVERT(VARCHAR(50),@Value,126),19) + 'Z') as ExactDateTime
	for xml path('DateTime'),type,elements)

	-- Return the result of the function
	RETURN @XML

END