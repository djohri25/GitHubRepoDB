/****** Object:  Procedure [dbo].[Rpt_LabData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Rpt_LabData
(
	@IceNumber VARCHAR (20),
	@ReportType VARCHAR (15) = NULL 
)
AS  
BEGIN
	SET NOCOUNT ON  
  
	DECLARE @v_limit_date date;

	IF ( ISNULL( @ReportType, '' ) != '' AND @ReportType = '21' )  
	BEGIN
		 SET @v_limit_date = DATEADD( YEAR, -1, GetDate() );
	END
	ELSE
	BEGIN
		SET @v_limit_date = '1/1/1900';
	END;
  
	;
	WITH cte AS
	(
		SELECT DISTINCT 
		CAST( RecordID AS varchar(20) ) OrderID,
		ISNULL( OrderName,'' ) Request,
		OrderingPhysicianName RequestingPhysician,
		OrderDate RequestDate,
		MVDID IceNumber,
		ISNULL( OrderingPhysicianName, '' ) CreatedBy,
		ISNULL( OrderingPhysicianName, '' ) CreatedByOrganization,
		'' UpdatedBy, --not provided
		'' UpdatedByOrganization, --not provided
		'' UpdatedByContact, -- not sure which field
		LabDataSource SourceName,
		ROW_NUMBER() OVER ( PARTITION BY OrderName, OrderingPhysicianName, OrderDate, MVDID, LabDataSource ORDER BY OrderName ) ID
		FROM
		FinalLab
		WHERE
		MVDID = @IceNumber
		AND OrderDate >= @v_limit_date
	)
	SELECT DISTINCT
	cte.*
	FROM
	cte
	WHERE
	ID = 1
	ORDER BY
	RequestDate DESC;
END;