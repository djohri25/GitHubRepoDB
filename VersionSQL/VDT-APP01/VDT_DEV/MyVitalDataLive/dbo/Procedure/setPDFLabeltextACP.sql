/****** Object:  Procedure [dbo].[setPDFLabeltextACP]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:			<Author,,Name> 
-- Create date:		5/14/2014
-- Description:		<Description,,>
-- Modified Date:	12/22/2015
-- =============================================

-- exec [setPDFLabeltextACP] '1028', 'Long Term Goals'			

CREATE PROCEDURE [dbo].[setPDFLabeltextACP]
@Id varchar(20),@casename varchar(500)	
 
as

BEGIN
	SET NOCOUNT ON
		
		if(@casename ='Long Term Goals')
		BEGIN
		SELECT * FROM ( 
		SELECT increaseknowledge AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increaseknowledge != '' AND id = @Id										
		UNION
		SELECT CONVERT(varchar(10), increaseknowledgedate, 20) AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increaseknowledgedate != '' AND id = @Id	
		UNION
		SELECT improveMgmt AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.improveMgmt != '' AND id = @Id													
		UNION
		SELECT CONVERT(varchar(10), improveMgmtDate, 20)  AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.improveMgmtDate != '' AND id = @Id				
		UNION
		SELECT PreventERUtil AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.PreventERUtil != '' AND id = @Id												
		UNION
		SELECT CONVERT(varchar(10), PreventERUtildate, 20)  AS condition,'F' orderkey FROM FormAsthmaCarePlan fa WHERE fa.PreventERUtildate != '' AND id = @Id			
		UNION
		SELECT increasecomp AS condition,'G' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increasecomp != '' AND id = @Id												
		UNION
		SELECT CONVERT(varchar(10), increasecompdate, 20)  AS condition,'H' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increasecompdate != ''  AND id = @Id			

		) x ORDER BY orderkey
		END	

		ELSE

		if(@casename = 'Short Term Goals')
		BEGIN
		SELECT * FROM (
		SELECT MemberVerbAsthmaPlan AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberVerbAsthmaPlan != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemberVerbAsthmaPlanDate, 20)  AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberVerbAsthmaPlanDate != '' AND id = @Id
		UNION
		SELECT MemberIncreaseKnowledge AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberIncreaseKnowledge != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemberIncreaseKnowledgeDate, 20)  AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberIncreaseKnowledgeDate != '' AND id = @Id
		UNION
		SELECT MemberAsthmaEdu AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAsthmaEdu != '' AND id = @Id
		UNION

		SELECT CONVERT(varchar(10), MemberAsthmaEduDate, 20)  AS condition,'F' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAsthmaEduDate != '' AND id = @Id
		UNION
		SELECT MemberVerb AS condition,'G' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberVerb != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemberVerbDate, 20)  AS condition,'H' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberVerbDate != '' AND id = @Id
		UNION
		SELECT MeteredDose AS condition,'I' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MeteredDose != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MeteredDoseDate, 20)  AS condition,'J' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MeteredDoseDate != '' AND id = @Id
		UNION

		SELECT Nebulizer AS condition,'K' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Nebulizer != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), NebulizerDate , 20) AS condition,'L' orderkey FROM FormAsthmaCarePlan fa WHERE fa.NebulizerDate != '' AND id = @Id
		UNION
		SELECT Inhaler AS condition,'M' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Inhaler != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), InhalerDate , 20)  AS condition,'N' orderkey FROM FormAsthmaCarePlan fa WHERE fa.InhalerDate != '' AND id = @Id
		UNION
		SELECT Drugs AS condition,'O' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Drugs != '' AND id = @Id

		UNION

		SELECT CONVERT(varchar(10), DrugsDate , 20)  AS condition,'P' orderkey FROM FormAsthmaCarePlan fa WHERE fa.DrugsDate != '' AND id = @Id
		UNION
		SELECT Other AS condition,'Q' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Other != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), OtherDate , 20)  AS condition,'R' orderkey FROM FormAsthmaCarePlan fa WHERE fa.OtherDate != '' AND id = @Id
		UNION
		SELECT MemVerbSelfCare AS condition,'S' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbSelfCare != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemVerbSelfCareDate , 20)  AS condition,'T' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbSelfCareDate != '' AND id = @Id

		UNION

		SELECT MemVerbCommRes AS condition,'U' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbCommRes != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemVerbCommResDate , 20)  AS condition,'V' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbCommResDate != '' AND id = @Id
		UNION
		SELECT MemVerbCare AS condition,'W' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbCare != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemVerbCareDate , 20)  AS condition,'X' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemVerbCareDate != '' AND id = @Id
		UNION
		SELECT MemberPeakFlow AS condition,'Y' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberPeakFlow != '' AND id = @Id

		UNION
		SELECT CONVERT(varchar(10), MemberPeakFlowDate , 20)  AS condition,'Z' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberPeakFlowDate != '' AND id = @Id
		UNION
		SELECT MemberAnnualFlu AS condition,'AB' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAnnualFlu != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemberAnnualFluDate , 20)  AS condition,'BC' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAnnualFluDate != '' AND id = @Id
		UNION
		SELECT MemberAvoidTobacco AS condition,'CD' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAvoidTobacco != '' AND id = @Id
		UNION
		SELECT CONVERT(varchar(10), MemberAvoidTobaccoDate , 20)  AS condition,'DE' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemberAvoidTobaccoDate != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Actions or Interventions')
		BEGIN
		SELECT * FROM (
		SELECT AssessMemKnowledge AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessMemKnowledge != '' AND id = @Id
		UNION
		SELECT AssessMemUnderstanding AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessMemUnderstanding != '' AND id = @Id
		UNION
		--SELECT PCPFollowup AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.PCPFollowup != '' AND id = @Id
		--UNION
		--SELECT AfterHours AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AfterHours != '' AND id = @Id
		--UNION
		--SELECT ConvinientCare AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ConvinientCare != '' AND id = @Id
		--UNION
		--SELECT ER AS condition,'F' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ER != '' AND id = @Id
		--UNION
		SELECT AssessPast AS condition,'G' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessPast != '' AND id = @Id
		UNION
		SELECT AssessMemAsthmaTrigger AS condition,'H' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessMemAsthmaTrigger != '' AND id = @Id
		UNION
		SELECT AssessSelfCare AS condition,'I' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessSelfCare != '' AND id = @Id
		UNION
		SELECT AssessMedication AS condition,'J' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessMedication != '' AND id = @Id
		UNION
		SELECT AssessPeakFlow AS condition,'K' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessPeakFlow != '' AND id = @Id
		UNION
		SELECT AssessImmunization AS condition,'L' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessImmunization != '' AND id = @Id
		UNION
		SELECT AssessTobacco AS condition,'M' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AssessTobacco != '' AND id = @Id
		UNION
		SELECT MemHealthCare AS condition,'N' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MemHealthCare != '' AND id = @Id
		UNION
		SELECT CommWithMemFamily AS condition,'O' orderkey FROM FormAsthmaCarePlan fa WHERE fa.CommWithMemFamily != '' AND id = @Id
		UNION
		SELECT CommToProvider AS condition,'P' orderkey FROM FormAsthmaCarePlan fa WHERE fa.CommToProvider != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Decrease risks of asthma attacks by')
		BEGIN
		SELECT * FROM (
		SELECT RemainIndoors AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.RemainIndoors != '' AND id = @Id
		UNION
		SELECT WearingMask AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.WearingMask != '' AND id = @Id
		UNION
		SELECT DecreaseDustInHome AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.DecreaseDustInHome != '' AND id = @Id
		UNION
		SELECT MaintainProgram AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MaintainProgram != '' AND id = @Id
		UNION
		SELECT AvoidPersonRTI AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AvoidPersonRTI != '' AND id = @Id
		UNION
		SELECT ControlStress AS condition,'F' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ControlStress != '' AND id = @Id
		UNION
		SELECT AvoidDehydration AS condition,'G' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AvoidDehydration != '' AND id = @Id
		UNION
		SELECT AvoidCold AS condition,'H' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AvoidCold != '' AND id = @Id
		UNION
		SELECT Receiveimmunization AS condition,'I' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Receiveimmunization != '' AND id = @Id
		UNION
		SELECT Takemedication AS condition,'J' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Takemedication != '' AND id = @Id
		UNION
		SELECT StopSmoking AS condition,'K' orderkey FROM FormAsthmaCarePlan fa WHERE fa.StopSmoking != '' AND id = @Id
		UNION
		SELECT HaveAsthmaActionPlan AS condition,'L' orderkey FROM FormAsthmaCarePlan fa WHERE fa.HaveAsthmaActionPlan != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Call your PCP')
		BEGIN
		SELECT * FROM (
		SELECT decreasepeakflow AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.decreasepeakflow != '' AND id = @Id
		UNION
		SELECT increaseagitation AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increaseagitation != '' AND id = @Id
		UNION
		SELECT asthmaattack AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AsthmaAttack != '' AND id = @Id
		UNION
		SELECT increasemed AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increasemed != '' AND id = @Id
		UNION
		SELECT increaseasthma AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.increaseasthma != '' AND id = @Id
		UNION
		SELECT decreaseactivity AS condition,'F' orderkey FROM FormAsthmaCarePlan fa WHERE fa.decreaseactivity != '' AND id = @Id
		UNION
		SELECT elevatedtemp AS condition,'G' orderkey FROM FormAsthmaCarePlan fa WHERE fa.elevatedtemp != '' AND id = @Id
		UNION
		SELECT coughprod AS condition,'H' orderkey FROM FormAsthmaCarePlan fa WHERE fa.coughprod != '' AND id = @Id
		--UNION

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Evaluation/Re-evaluation')
		BEGIN
		SELECT * FROM (

		SELECT continuecare AS condition,'I' orderkey FROM FormAsthmaCarePlan fa WHERE fa.continuecare != '' AND id = @Id
		UNION
		SELECT establishfreq AS condition,'J' orderkey FROM FormAsthmaCarePlan fa WHERE fa.establishfreq != '' AND id = @Id
		UNION
		SELECT memdischarged AS condition,'K' orderkey FROM FormAsthmaCarePlan fa WHERE fa.memdischarged != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='AssessMemUnderstanding')
		BEGIN
		SELECT * FROM (
		SELECT PCPFollowup AS condition,'A' orderkey FROM FormAsthmaCarePlan fa WHERE fa.PCPFollowup != '' AND id = @Id
		UNION
		SELECT AfterHours AS condition,'B' orderkey FROM FormAsthmaCarePlan fa WHERE fa.AfterHours != '' AND id = @Id
		UNION
		SELECT ConvinientCare AS condition,'C' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ConvinientCare != '' AND id = @Id
		UNION
		SELECT UrgentCare AS condition,'D' orderkey FROM FormAsthmaCarePlan fa WHERE fa.UrgentCare != '' AND id = @Id
		UNION
		SELECT ER AS condition,'E' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ER != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Assess tobacco use')
		BEGIN
		SELECT * FROM (
		SELECT ReferProvider AS condition,'N' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ReferProvider != '' AND id = @Id
		UNION
		SELECT ReferTobacco AS condition,'O' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ReferTobacco != '' AND id = @Id
		UNION
		SELECT ReferCardiovascular AS condition,'P' orderkey FROM FormAsthmaCarePlan fa WHERE fa.ReferCardiovascular != '' AND id = @Id

		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='Asthma Medications')
		BEGIN
		SELECT * FROM (
		SELECT MeteredDose AS condition,'I' orderkey FROM FormAsthmaCarePlan fa WHERE fa.MeteredDose != '' AND id = @Id
		UNION
		SELECT Nebulizer AS condition,'K' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Nebulizer != '' AND id = @Id
		UNION
		SELECT Inhaler AS condition,'M' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Inhaler != '' AND id = @Id
		UNION
		SELECT Drugs AS condition,'O' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Drugs != '' AND id = @Id
		UNION
		SELECT Other AS condition,'Q' orderkey FROM FormAsthmaCarePlan fa WHERE fa.Other != '' AND id = @Id
		) x ORDER BY orderkey
		END

		ELSE

		if(@casename ='discharge reason')
		BEGIN
		SELECT * FROM (

		SELECT memdischargedreason AS condition,'L' orderkey FROM FormAsthmaCarePlan fa WHERE fa.memdischargedreason != '' AND id = @Id
		) x ORDER BY orderkey
		END		
	END