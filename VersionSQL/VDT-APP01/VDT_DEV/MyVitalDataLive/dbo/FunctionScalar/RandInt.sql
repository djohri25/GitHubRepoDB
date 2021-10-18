/****** Object:  Function [dbo].[RandInt]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION dbo.RandInt
	(
	@RAND	FLOAT,
	@MAX	INT
	)
RETURNS INT
AS
BEGIN
	SET @RAND = @RAND * POWER(10, 4)
	RETURN	CAST
			(
				FLOOR
				(
					(
						@RAND - FLOOR(@RAND)
					) * @MAX
				) AS INT
			)
END