/****** Object:  Procedure [API].[DeleteWeatherForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE API.DeleteWeatherForecast (
	@WeatherId Int, 
	@retVal int output
) AS 
BEGIN
	DELETE FROM API.Weather
	WHERE WeatherId = @WeatherId

	IF @@ROWCOUNT > 0
    BEGIN
		SET @retVal = 200
    END
    ELSE
    BEGIN
		SET @retVal = 500
    END
END