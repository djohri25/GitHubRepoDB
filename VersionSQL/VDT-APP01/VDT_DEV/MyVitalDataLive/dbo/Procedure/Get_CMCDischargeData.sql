/****** Object:  Procedure [dbo].[Get_CMCDischargeData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/16/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_CMCDischargeData]
AS
BEGIN
	SET NOCOUNT ON;

	declare @totalUniqueVisits int, @totalVDTLookups int

	declare @temp table(
		MRN varchar(100)
		,CSN varchar(100)
		,PATIENT_NAME varchar(100)
		,DOB varchar(100)
		,ADMIT_DATE datetime
		,CLASS varchar(100)
		,SubscriberNumber varchar(100)
		,VISIT_REASON varchar(100)
		,PCP varchar(100)
		,DISCHARGE_DISPOSITION varchar(100)
		,PATIENTS_HOME_NUMBER varchar(100)
		,lookedUpBy varchar(max)
	)

	insert into @temp(MRN,CSN,PATIENT_NAME,DOB,ADMIT_DATE,CLASS,SubscriberNumber,
		VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,lookedUpBy)
	SELECT MRN
      ,CSN
      ,PATIENT_NAME
      ,CONVERT(varchar,DOB,101)
      ,ADMIT_DATE
      ,CLASS
      ,MEDICAIDE_NUMBER as SubscriberNumber
      ,VISIT_REASON
      ,PCP
      ,DISCHARGE_DISPOSITION
      ,PATIENTS_HOME_NUMBER
      ,dbo.GetUsersLookingUp(MEDICAIDE_NUMBER,ADMIT_DATE) as lookedUpBy
   from dbo.CMCD_DISCHARGE_DATA   
   
   select @totalUniqueVisits = COUNT(*) from 
   (
		select distinct SubscriberNumber,convert(varchar,ADMIT_DATE,1) as ADMIT_DATE
		from @temp
   ) a
   
   select @totalVDTLookups = COUNT(*)
   from 
	(select distinct SubscriberNumber,convert(varchar,ADMIT_DATE,1) as ADMIT_DATE
		from @temp
		where ISNULL(lookedUpBy,'') <> ''    
	) b
   
   SELECT MRN
      ,CSN
      ,PATIENT_NAME
      ,DOB
      ,ADMIT_DATE
      ,CLASS
      ,SubscriberNumber
      ,VISIT_REASON
      ,PCP
      ,DISCHARGE_DISPOSITION
      ,PATIENTS_HOME_NUMBER
      ,lookedUpBy      
      ,@totalUniqueVisits as totalUniqueVisits
      ,@totalVDTLookups as totalVDTLookups
   from @temp
END