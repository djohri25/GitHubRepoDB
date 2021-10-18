/****** Object:  Function [dbo].[GetAgeInYears]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[GetAgeInYears]
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

    SET @vAge = DATEDIFF(YY, @pDateOfBirth, @pAsOfDate)

    IF MONTH(@pDateOfBirth) > MONTH(@pAsOfDate) OR
      (MONTH(@pDateOfBirth) = MONTH(@pAsOfDate) AND
       DAY(@pDateOfBirth)   > DAY(@pAsOfDate))
        SET @vAge = @vAge - 1

    RETURN @vAge
END