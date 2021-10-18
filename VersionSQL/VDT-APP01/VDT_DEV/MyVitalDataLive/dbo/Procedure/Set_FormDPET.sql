/****** Object:  Procedure [dbo].[Set_FormDPET]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/1/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Set_FormDPET]
	@RecordID int = null,
	@MemberID varchar(15),
	@ModifiedBy varchar(50),
	@Cust_ID int,
	@AdmissionDate datetime,
	@DischargeDate datetime,
	@DaysInHospital varchar(50),
	@PCP varchar(50),
	@PCPPhone varchar(50),
	@HospDoctor varchar(50),
	@HospDoctorPhone varchar(50),
	@OtherDoc1 varchar(50),
	@OtherDocSpecialty1 varchar(50),
	@OtherDoc2 varchar(50),
	@OtherDocSpecialty2 varchar(50),
	@OtherDoc3 varchar(50),
	@OtherDocSpecialty3 varchar(50),
	@DiagStayInHosp varchar(50),
	@DiagMedicalWord varchar(50),
	@DiagOtherConditions varchar(50),
	@TestInHosp1 varchar(50),
	@TestInHospResult1 varchar(50),
	@TestInHosp2 varchar(50),
	@TestInHospResult2 varchar(50),
	@TestInHosp3 varchar(50),
	@TestInHospResult3 varchar(50),
	@TestInHosp4 varchar(50),
	@TestInHospResult4 varchar(50),
	@TreatedFor1 varchar(50),
	@TreatedForPurpose1 varchar(50),
	@TreatedFor2 varchar(50),
	@TreatedForPurpose2 varchar(50),
	@TreatedFor3 varchar(50),
	@TreatedForPurpose3 varchar(50),
	@TreatedFor4 varchar(50),
	@TreatedForPurpose4 varchar(50),

	@FollowupPCP varchar(100),
	@FollowupPCPPhone varchar(50),
	@FollowupPCPDate datetime,
	@FollowupPCPTime varchar(50),
	@FollowupSpecialist varchar(100),
	@FollowupSpecialistPhone varchar(50),
	@FollowupSpecialistDate varchar(50),
	@FollowupSpecialistTime varchar(50),

	@FollowupTest1 varchar(50),
	@FollowupTestLocation1 varchar(50),
	@FollowupTestDate1 datetime,
	@FollowupTestTime1 varchar(50),
	@FollowupTest2 varchar(50),
	@FollowupTestLocation2 varchar(50),
	@FollowupTestDate2 datetime,
	@FollowupTestTime2 varchar(50),
	@FollowupTest3 varchar(50),
	@FollowupTestLocation3 varchar(50),
	@FollowupTestDate3 datetime,
	@FollowupTestTime3 varchar(50),
	@WarningSign1 varchar(50),
	@WarningSign2 varchar(50),
	@WarningSign3 varchar(50),
	@WarningSign4 varchar(50),
	@WarningSign5 varchar(50),
	@WarningSign6 varchar(50),

	@LifeStyleChangesActivity varchar(50),
	@LifeStyleChangesActivityBecause varchar(50),
	@LifeStyleChangesDiet varchar(50),
	@LifeStyleChangesDietBecause varchar(50),

	@LifeStyleFollowupCallDate datetime,
	@LifeStyleFollowupCallTime varchar(50),

	@WillFollowup bit,
	@FollowupTest bit,
	@LifeStyleChanges bit,
	@NonSmoker bit,
	@SmokerQuitting bit,
	@MedicationStop bit,
	@MedicationContinue bit,
	@MedicationWhen bit,
	@MedicationSideEffects bit
	
AS
BEGIN

	SET NOCOUNT ON;

--	declare 




	if(@RecordID is not null AND @RecordID <> 0)
	begin
		delete from Form_DPET where ID = @RecordID
	end
	
INSERT INTO Form_DPET
           (MemberID
           ,Cust_ID
           ,AdmissionDate
           ,DischargeDate
		   ,DaysInHospital           
		   ,PCP
           ,PCPPhone
           ,HospDoctor
           ,HospDoctorPhone
           ,OtherDoc1
           ,OtherDocSpecialty1
           ,OtherDoc2
           ,OtherDocSpecialty2
           ,OtherDoc3
           ,OtherDocSpecialty3
           
           ,DiagStayInHosp
           ,DiagMedicalWord
           ,DiagOtherConditions
           ,TestInHosp1
           ,TestInHospResult1
           ,TestInHosp2
           ,TestInHospResult2
           ,TestInHosp3
           ,TestInHospResult3
           ,TestInHosp4
           ,TestInHospResult4
           ,TreatedFor1
           ,TreatedForPurpose1
           ,TreatedFor2
           ,TreatedForPurpose2
           ,TreatedFor3
           ,TreatedForPurpose3
           ,TreatedFor4
           ,TreatedForPurpose4          
           
           ,WillFollowup
           
           ,FollowupPCP
           ,FollowupPCPPhone
           ,FollowupPCPDate
           ,FollowupPCPTime
           ,FollowupSpecialist
           ,FollowupSpecialistPhone
           ,FollowupSpecialistDate
           ,FollowupSpecialistTime
           ,FollowupTest
           ,FollowupTest1
           ,FollowupTestLocation1
           ,FollowupTestDate1
           ,FollowupTestTime1
           ,FollowupTest2
           ,FollowupTestLocation2
           ,FollowupTestDate2
           ,FollowupTestTime2
           ,FollowupTest3
           ,FollowupTestLocation3
           ,FollowupTestDate3
           ,FollowupTestTime3
                
           ,WarningSign1
           ,WarningSign2
           ,WarningSign3
           ,WarningSign4
           ,WarningSign5
           ,WarningSign6
           
           ,LifeStyleChanges
           ,LifeStyleChangesActivity
           ,LifeStyleChangesActivityBecause
           ,LifeStyleChangesDiet
           ,LifeStyleChangesDietBecause

           ,NonSmoker
           ,SmokerQuitting
           ,LifeStyleFollowupCallDate
           ,LifeStyleFollowupCallTime
           ,MedicationStop
           ,MedicationContinue
           ,MedicationWhen
           ,MedicationSideEffects
     
           ,CreatedBy
           ,DateCreated
           ,ModifiedBy
           ,DateModified)
     VALUES
           (@MemberID,
            @Cust_ID,
 			@AdmissionDate,
			@DischargeDate,
			@DaysInHospital,			
			@PCP,
			@PCPPhone,
			@HospDoctor,
			@HospDoctorPhone,
			@OtherDoc1,
			@OtherDocSpecialty1,
			@OtherDoc2,
			@OtherDocSpecialty2,
			@OtherDoc3,
			@OtherDocSpecialty3,

			@DiagStayInHosp,
			@DiagMedicalWord,
			@DiagOtherConditions,
			@TestInHosp1,
			@TestInHospResult1,
			@TestInHosp2,
			@TestInHospResult2,
			@TestInHosp3,
			@TestInHospResult3,
			@TestInHosp4,
			@TestInHospResult4,
			@TreatedFor1,
			@TreatedForPurpose1,
			@TreatedFor2,
			@TreatedForPurpose2,
			@TreatedFor3,
			@TreatedForPurpose3,
			@TreatedFor4,
			@TreatedForPurpose4,

			@WillFollowup,
			
			@FollowupPCP,
			@FollowupPCPPhone,
			@FollowupPCPDate,
			@FollowupPCPTime,
			@FollowupSpecialist,
			@FollowupSpecialistPhone,
			@FollowupSpecialistDate,
			@FollowupSpecialistTime,
			@FollowupTest,
			@FollowupTest1,
			@FollowupTestLocation1,
			@FollowupTestDate1,
			@FollowupTestTime1,
			@FollowupTest2,
			@FollowupTestLocation2,
			@FollowupTestDate2,
			@FollowupTestTime2,
			@FollowupTest3,
			@FollowupTestLocation3,
			@FollowupTestDate3,
			@FollowupTestTime3,
			
			@WarningSign1,
			@WarningSign2,
			@WarningSign3,
			@WarningSign4,
			@WarningSign5,
			@WarningSign6,
			
			@LifeStyleChanges,
			@LifeStyleChangesActivity,
			@LifeStyleChangesActivityBecause,
			@LifeStyleChangesDiet,
			@LifeStyleChangesDietBecause,

			@NonSmoker,
			@SmokerQuitting,
			@LifeStyleFollowupCallDate,
			@LifeStyleFollowupCallTime,
			@MedicationStop,
			@MedicationContinue,
			@MedicationWhen,
			@MedicationSideEffects,
			
           @ModifiedBy
           ,GETUTCDATE()
           ,@ModifiedBy
           ,GETUTCDATE())

END