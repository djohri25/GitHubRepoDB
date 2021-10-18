/****** Object:  Function [dbo].[Random]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION Random()
 RETURNS DECIMAL(10,10)
 AS
 BEGIN
 RETURN (SELECT MyRAND FROM Get_RAND)
 END