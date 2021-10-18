/****** Object:  Procedure [API].[GetAllWeatherForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE API.GetAllWeatherForecast AS
BEGIN
	SELECT	WeatherId,
			Date,
			TemperatureC,
			TemperatureF,
			Summary
	FROM	API.Weather
END