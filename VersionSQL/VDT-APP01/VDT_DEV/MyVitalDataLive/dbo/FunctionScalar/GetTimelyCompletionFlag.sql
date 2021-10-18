/****** Object:  Function [dbo].[GetTimelyCompletionFlag]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bhupinder Singh
-- Create date: 05/13/2021
-- Description:	Common function to determine the TimelyCompletion flag
--				for multiple ABCBS reports - 
--				Assessment Turnaround Report
--				Med Rec Turnaround Report
--select dbo.GetTimelyCompletionFlag('05/03/2021',null,'05/01/2021',7)
-- =============================================

CREATE FUNCTION [dbo].[GetTimelyCompletionFlag] 
(
	-- Add the parameters for the function here
	@completionDate Date,
	@consentDate Date,
	@defaultConsent Date,
	@dueDays int
)
RETURNS char
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result char(1)
	IF @consentDate IS NULL
	BEGIN
		SET @consentDate = @defaultConsent
	END
	
	--If the Reconcilitation was done in the past for a different case then return N
	IF (@completionDate < @consentDate)
	BEGIN
		SET @Result = 'N'
	END
	--N = if 7 business days have passed and the Initial OR Maternity Enrollment is not saved, and/or if the save date is > 7 days. 
	ELSE If (@completionDate IS NULL AND DATEDIFF(DAY, @consentDate, GETDATE()) > 7)
	BEGIN
		SET @Result = 'N'
	END
	ELSE IF DATEDIFF(DAY, @consentDate, @completionDate) > 7
	BEGIN
		SET @Result = 'N'
	END
	--No value should display if the 7 business days have not elapsed
	ELSE IF (@completionDate IS NULL AND DATEDIFF(DAY, @consentDate, GETDATE()) <= 7)
	BEGIN
		SET @Result = ''
	END
	--Y = Initial OR Maternity Enrollment Assessment is saved on or before 7 business days from the Consent Date. 
	ELSE IF DATEDIFF(DAY, @completionDate, @consentDate) <= 7
	BEGIN
		SET @Result = 'Y'
	END
	-- Return the result of the function
	RETURN @Result

END