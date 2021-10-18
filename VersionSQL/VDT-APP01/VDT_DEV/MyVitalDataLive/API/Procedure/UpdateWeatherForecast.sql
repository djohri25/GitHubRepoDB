/****** Object:  Procedure [API].[UpdateWeatherForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE API.UpdateWeatherForecast (
	@WeatherId Int,
	@Date DATE,
	@TemperatureC Int,
	@TemperatureF Int,
	@Summary Varchar(50), 
	@retVal int output
) AS 
BEGIN
	UPDATE API.Weather
	SET [Date]=@Date, 
		[TemperatureC]=@TemperatureC, 
		[TemperatureF]=@TemperatureF, 
		[Summary]=@Summary
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