/****** Object:  Procedure [API].[AddWeatherForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE API.AddWeatherForecast (
	@Date DATE,
	@TemperatureC Int,
	@TemperatureF Int,
	@Summary Varchar(50), 
	@retVal int output
) AS 
BEGIN
	INSERT INTO API.Weather
	([Date], [TemperatureC], [TemperatureF], [Summary])
	VALUES
	(@Date, @TemperatureC, @TemperatureF, @Summary)
	IF @@ROWCOUNT > 0
    BEGIN
		SET @retVal = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
		SET @retVal = -500
    END
END