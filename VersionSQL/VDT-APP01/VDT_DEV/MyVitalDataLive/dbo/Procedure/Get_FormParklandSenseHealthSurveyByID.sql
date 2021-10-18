/****** Object:  Procedure [dbo].[Get_FormParklandSenseHealthSurveyByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author:		BDW 
-- Create date: 6/15/2016
-- ========================================================
CREATE PROCEDURE [dbo].[Get_FormParklandSenseHealthSurveyByID]
@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

SELECT top 1[ID]
       ,[MVDID]
       ,[CustID]
       ,[StaffInterviewing]
       ,[FormDate]
       ,[DateOfBirth]
       ,[ProviderIDNumber]
       ,[Nurtur_CM_Name]
	   ,[Member_Name]
	   ,[PCCI_Risk_Score]
	   ,[Consent_Status]
	   ,[Consent_Date]
	   ,[Preferred_Language]
	   ,[Number_Of_Calls]
	   ,[Updated_Phone_Number]
       ,f.[Created]
       ,f.[CreatedBy]
       ,f.[ModifiedDate]
       ,f.[ModifiedBy]
	   ,d.FirstName
	   ,d.LastName
  FROM [dbo].[FormSenseHealthSurvey] F
  LEFT JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  WHERE F.ID = @ID
  order by f.ID desc
END