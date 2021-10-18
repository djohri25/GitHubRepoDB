/****** Object:  Procedure [dbo].[Get_HPAlertingRuleList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/02/2008
-- Description:	 Retrieves the list of Alerting Rules for particular customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPAlertingRuleList]
	@CustomerId varchar(50),
	@IsNoteAlertRule bit = 0
AS
BEGIN
	SET NOCOUNT ON;

--select @CustomerId = 10

	select Rule_ID, Name, Description, Cust_ID,
		(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
		Active,
		AnyFacility,
		AnyDisease,
		AnyEmployer,
		AnyHealthPlan,
		AnyHealthPlanType,
		isnull(AnyCounty,0) as AnyCounty,
		isnull(AnyDiseaseManagement,0) as AnyDM,
		isnull(AnyChiefComplaint,0) as AnyChiefComplaint,
		isnull(inCaseManagement,0) as inCM,
		isnull(inNarcoticLockdown,0) as inNarcoticLockdown,
		isnull(AnyDiagnosis,0) as AnyDiagnosis,
		isnull(AllOtherDiagnosis,0) as AllOtherDiagnosis,
		isnull(AnyCOPC,0) as AnyCOPC
	from HPAlertRule a 
	where Cust_ID = @CustomerId
		and IsNoteAlertRule = @IsNoteAlertRule		
END