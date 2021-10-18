/****** Object:  Procedure [dbo].[Get_MDPatientForms]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/11/2009
-- Description:	Returns doctor's forms for all patients
--	If @PatientMVDID is valued, return forms only for specific patient
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientForms] 
	@DoctorID varchar(20),
	@MVDID varchar(20) = null,
	@FormType varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	SELECT f.ID as recordID,'Cardiac Discharge' as FormType,DateCreated, ISNULL(dbo.FullName(e.lastName,e.firstName,''),'Unknown') as CreatedBy
	FROM Form_CardiacDischarge f
		inner join Link_MemberId_MVD_Ins li on f.MemberID = li.InsMemberId and f.Cust_ID = li.Cust_ID
		left join HospitalUser e on f.CreatedBy = e.Username
	where MVDId = @MVDID
	union
	SELECT f.ID as recordID,'DPET' as FormType,DateCreated, ISNULL(dbo.FullName(e.lastName,e.firstName,''),'Unknown')  as CreatedBy
	FROM Form_DPET f
		inner join Link_MemberId_MVD_Ins li on f.MemberID = li.InsMemberId and f.Cust_ID = li.Cust_ID
		left join HospitalUser e on f.CreatedBy = e.Username
	where MVDId = @MVDID
	
	
END