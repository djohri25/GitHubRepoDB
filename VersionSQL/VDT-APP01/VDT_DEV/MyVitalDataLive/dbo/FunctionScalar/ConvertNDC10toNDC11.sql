/****** Object:  Function [dbo].[ConvertNDC10toNDC11]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		DJS
-- Create date: 09/30/2015
-- Description:	Convert 10 Digit NDC to 11 Digit NDC
--   Data must formatted to include the two required hyphen characters:
--    1. between the labeler code (part 1) and the product code (part 2)
--    2  between the product code (part 2) and the package code (part 3)
-- =============================================
CREATE FUNCTION [dbo].[ConvertNDC10toNDC11]
(
	@NDC10 VARCHAR(12)
)
RETURNS VARCHAR(13)
AS
BEGIN
	/*

	http://phpa.dhmh.maryland.gov/OIDEOR/IMMUN/Shared%20Documents/Handout%203%20-%20NDC%20conversion%20to%2011%20digits.pdf


	National Drug Code (NDC)
	
	Conversion Table
	Converting NDCs from 10-digits to 11 digits.

	It should be noted that many National Drug Code (NDC) are displayed on drug packing
	in a 10-digit format. Proper billing of a National Drug Code (NDC) requires an 11-digit
	number in a 5-4-2 format. Converting National Drug Code (NDC) from a 10-digit to an
	11-digit format requires a strategically placed zero, dependent upon the 10-digit format.
	The following table shows common 10-digit National Drug Code (NDC) formats
	indicated on packaging and the associated conversion to an 11-digit format, using the
	proper placement of a zero. The correctly formatted, additional “0” is in a bold font and
	underlined in the following example. Note that hyphens indicated below are used solely
	to illustrate the various formatting examples for the National Drug Code (NDC).
	
	NOTE: Do not use hyphens when entering the actual data in your claim.
	Converting NDCs from 10-digits to 11-digits

	4-4-2 9999-9999-99 5-4-2 09999-9999-99 
	5-3-2 99999-999-99 5-4-2 99999-0999-99 
	5-4-1 99999-9999-9 5-4-2 99999-9999-09 

	*/

	DECLARE @returnList TABLE ([ID] [INT], [Item] [nvarchar] (500), [Len] [Int])
	INSERT INTO @returnList
		SELECT [ID],[Item],[Len] FROM dbo.splitstring(@NDC10,'-')

	DECLARE @Count INT
	SELECT @Count =  @@ROWCOUNT

	DECLARE @NDCCODE_11DIGIT VARCHAR(13)
	DECLARE @NDCCODE_PART1 VARCHAR(100), @NDCCODE_PART2 VARCHAR(100), @NDCCODE_PART3 VARCHAR(100)
	DECLARE @NDCCODE_PART1_LEN INT, @NDCCODE_PART2_LEN INT, @NDCCODE_PART3_LEN INT

	IF @Count = 3
	BEGIN
		SELECT @NDCCODE_PART1 = [Item], @NDCCODE_PART1_LEN = [Len] FROM @returnList WHERE [ID] = 1
		SELECT @NDCCODE_PART2 = [Item], @NDCCODE_PART2_LEN = [Len] FROM @returnList WHERE [ID] = 2
		SELECT @NDCCODE_PART3 = [Item], @NDCCODE_PART3_LEN = [Len] FROM @returnList WHERE [ID] = 3
	END

	-- NDCCODE_FORMAT = '4-4-2'
	IF (@NDCCODE_PART1_LEN = 4 AND @NDCCODE_PART2_LEN = 4 AND @NDCCODE_PART3_LEN = 2)
	BEGIN
		SELECT @NDCCODE_11DIGIT = '0' + @NDCCODE_PART1 + '-' + @NDCCODE_PART2 + '-' + @NDCCODE_PART3
	END
	-- NDCCODE_FORMAT = '5-3-2'
	IF (@NDCCODE_PART1_LEN = 5 AND @NDCCODE_PART2_LEN = 3 AND @NDCCODE_PART3_LEN = 2)
	BEGIN
		SELECT @NDCCODE_11DIGIT = @NDCCODE_PART1 + '-0' + @NDCCODE_PART2 + '-' + @NDCCODE_PART3
	END
	-- NDCCODE_FORMAT = '5-4-1'
	IF (@NDCCODE_PART1_LEN = 5 AND @NDCCODE_PART2_LEN = 4 AND @NDCCODE_PART3_LEN = 1)
	BEGIN
		SELECT @NDCCODE_11DIGIT = @NDCCODE_PART1 + '-' + @NDCCODE_PART2 + '-0' + @NDCCODE_PART3
	END

	RETURN @NDCCODE_11DIGIT

END