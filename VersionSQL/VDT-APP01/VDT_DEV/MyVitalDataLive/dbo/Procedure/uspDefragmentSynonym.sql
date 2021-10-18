/****** Object:  Procedure [dbo].[uspDefragmentSynonym]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspDefragmentSynonym
(
	@p_SynonymName nvarchar(255),
	@p_FragmentationThreshold float = 10
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_table_name varchar(255);

	SELECT
	@v_table_name = REPLACE( REPLACE( REPLACE( base_object_name, '[dbo]', '' ), '[', '' ), ']', '' )
	FROM
	sys.synonyms
	WHERE
	Name = @p_SynonymName;

	EXEC uspDefragmentTable @v_table_name, @p_FragmentationThreshold;

END;