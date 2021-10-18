/****** Object:  Procedure [dbo].[DriscollExcelReport1Archive]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Misha Grigoriev
-- Create date: 07/08/2014
-- Description:	
-- 06/16/2017	Marc De Luca	Changed the last Reason2 to Reason3. LTRIM(isnull(s.Reason1, '') + ' ' + isnull(s.Reason2, '')) + ' ' + isnull(s.Reason3, ''),
-- 03/14/2018	Marc De Luca	Limited the Reasons concatenation to 100 characters
-- =============================================
CREATE PROCEDURE [dbo].[DriscollExcelReport1Archive]

AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[DISCHARGE_DATA_History]
			(GUID,
			MRN,
			PATIENT_NAME,
			DOB,
			ADMIT_DATE,
			MEDICAIDE_NUMBER,
			VISIT_REASON,
			DISCHARGE_DISPOSITION,
			PatientPhone,
			[Type],
			Gender,
			AdmitPlace,
			HealthPlan,
			[Source])
	SELECT
			s.[ACCOUNT NUMBER],
			s.MRN,
			LTRIM(isnull(s.[PATIENT FIRST NAME], '') + ' ' + isnull(s.[PATIENT LAST NAME], '')),
			s.DOB,
			s.[ADMIT DATE],
			s.[MEMBER NUMBER],
			LEFT(LTRIM(isnull(s.Reason1, '')) + ' ' + LTRIM(isnull(s.Reason2, '')) + ' ' + LTRIM(isnull(s.Reason3, '')), 100),
			s.[DISCHARGE DESTINATION],
			s.[HOME PHONE],
			s.[PATIENT TYPE],
			s.GENDER,
			s.[ADMISSION SOURCE],
			s.[INSURANCE CO NAME],
			'Driscoll Excel Report 1'
	FROM [dbo].[DriscollExcelReport1] AS s
		LEFT OUTER JOIN
		[dbo].[DISCHARGE_DATA_History] AS t
		on s.[ADMIT DATE] = t.ADMIT_DATE AND s.[MEMBER NUMBER] = t.MEDICAIDE_NUMBER
	WHERE t.ID IS NULL
	
	DELETE FROM [dbo].[DriscollExcelReport1]
	
END