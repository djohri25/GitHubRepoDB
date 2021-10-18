/****** Object:  Procedure [dbo].[Get_MDUserMessages]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/3/2014
-- Description:	Returns MD user messages. EXEC dbo.Get_MDUserMessages @DoctorID  = '756004221'
-- Change History
-- Date         Developer           Issue# - Description
--------------- ------------------- --------------------
-- 10/27/2016	Marc De Luca		Added back the filter for RecipientDoctorID = @DoctorID
-- 05/31/2018	dpatel				Added additional columns of MDMessage table. Get all messages for PCP.
-- 10/30/2018	dpatel				Added and condition to filter CareSpace Engagement Note from result set.
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDUserMessages]
	 @DoctorID VARCHAR(20)
	,@ExpirationDate DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT TOP (5) 
	SELECT
	 ID
	,RecipientDoctorID
	,Subject
	,MessageText
	,Sender
	,CONVERT(VARCHAR(10),Created ,101) AS MessageDate
	,ExpirationDate
	FROM dbo.MDMessage
	WHERE (RecipientDoctorID = @DoctorID OR RecipientDoctorID = 'all')
	AND (ExpirationDate >= @ExpirationDate OR ExpirationDate IS NULL)
	AND ([Subject] <> 'CareSpace Engagement Note')
	ORDER BY Created DESC

	--		-- Record SP Log
	--DECLARE @params NVARCHAR(1000) = NULL
	--SET @params = LEFT(
	-- '@DoctorID=' + ISNULL(CAST(@DoctorID AS VARCHAR(100)), 'null') + ';' 
	--+'@ExpirationDate=' + ISNULL(CAST(@ExpirationDate AS VARCHAR(100)), 'null') + ';' 
	--, 1000);
	
	--EXEC dbo.Set_StoredProcedures_Log '[dbo].[Get_MDUserMessages]', @DoctorID, NULL, @params

END