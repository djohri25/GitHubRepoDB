/****** Object:  Function [dbo].[Get_PPD]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION
Get_PPD
(
	@p_PPDTotalWt float
)
RETURNS float
AS
BEGIN

	RETURN EXP( @p_PPDTotalWt ) / ( 1 + EXP( @p_PPDTotalWt ) );
END;