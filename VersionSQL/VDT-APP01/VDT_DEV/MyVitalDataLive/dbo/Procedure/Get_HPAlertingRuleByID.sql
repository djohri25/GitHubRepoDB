/****** Object:  Procedure [dbo].[Get_HPAlertingRuleByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/23/2008
-- Description:	 Retrieves the Alerting Rule identified by ID
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPAlertingRuleByID]
	@RuleId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select Rule_ID,Name, Description, Cust_ID,
		(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
		Active,
		AnyFacility,
		AnyDisease,
		AnyEmployer,
		AnyHealthPlan,
		AnyHealthPlanType,
		AnyCounty,
		isnull(AnyChiefComplaint,0) as AnyChiefComplaint,
		isnull(AnyDiseaseManagement,0) as AnyDM,
		isnull(AnyDiagnosis,0) as AnyDiagnosis,
		isnull(AllOtherDiagnosis,0) as AllOtherDiagnosis,
		isnull(inCaseManagement,0) as inCM,
		isnull(inNarcoticLockdown,0) as inNarcoticLockdown,
		isnull(AnyCOPC,0) as AnyCOPC
	from HPAlertRule a 
	where Rule_ID = @RuleId
END