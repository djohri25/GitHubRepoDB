/****** Object:  Function [dbo].[ConcatenateHealthMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE 
FUNCTION dbo.ConcatenateHealthMonitoring(@ICeNumber varchar(15), @MonitoringID int)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @Output VARCHAR(8000)
	SELECT @Output = COALESCE(@Output+', ', '') + CONVERT(varchar(10), SM.MonitoringDate, 101) + CASE WHEN (SM.MonitoringResult IS NOT NULL AND LEN(CONVERT(varchar(50),SM.MonitoringResult)) > 0 ) THEN ' - ' + CONVERT(varchar(50), SM.MonitoringResult) 
																									  WHEN (LEN(CONVERT(varchar(50),SM.MonitoringResult)) <= 0 ) THEN ' ' END
	FROM	dbo.MainMonitoring MM
	JOIN dbo.SubMonitoring SM
	ON MM.MonitoringId = SM.MonitoringId
	AND MM.ICENUMBER = SM.ICENUMBER
	WHERE	MM.ICENUMBER = @ICeNumber
	AND SM.MonitoringID = @MonitoringID
	RETURN @Output
END