/****** Object:  Procedure [dbo].[spGetAllRaces]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetAllRaces]
AS
SELECT [RACEID],[RACENAME] FROM dbo.LookupRace