/****** Object:  Function [dbo].[FormatString]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[FormatString](
	@format varchar(6000), 
    @arg1 sql_variant, 
    @arg2 sql_variant='', 
    @arg3 sql_variant='',
	@arg4 sql_variant=''
)
RETURNS varchar(8000)
AS
BEGIN
	RETURN	REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(@format, '{0}', CAST(@arg1 as varchar(1000))), 
						'{1}', CAST(@arg2 as varchar(1000))),
					'{2}', CAST(@arg3 as varchar(1000))),
				'{3}', CAST(@arg4 as varchar(1000)))
END