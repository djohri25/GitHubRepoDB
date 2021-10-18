/****** Object:  Function [dbo].[GetAgeInMonths]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetAgeInMonths]
(
	@pDateOfBirth    DATETIME, 
	@pAsOfDate       DATETIME
)
RETURNS int
AS
BEGIN
    DECLARE @vAge         INT
    
    IF @pDateOfBirth >= @pAsOfDate
        RETURN 0

    SET @vAge = DATEDIFF(MM, @pDateOfBirth, @pAsOfDate)

    IF DAY(@pDateOfBirth)   > DAY(@pAsOfDate)
        SET @vAge = @vAge - 1

    RETURN @vAge
END