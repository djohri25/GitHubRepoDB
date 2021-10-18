/****** Object:  Procedure [dbo].[Set_DoctorAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/11/2009
-- Description:	Create alert record for all doctors
--	who are associated with the patient.
-- =============================================
CREATE PROCEDURE [dbo].[Set_DoctorAlert]
	@RecordAccessId int,
	@MVDId varchar(20),
	@MemberFName varchar(50),
	@MemberLName varchar(50),
	@DateTime datetime,
	@Facility varchar(50),
	@ChiefComplaint varchar(100),
	@EMSNote varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO MD_Alert
		(MVDID
           ,DoctorID
           ,AlertDate
           ,Facility
           ,RecordAccessID
           ,ChiefComplaint
           ,EMSNote
           ,Created)
	select @mvdid,
		md.doctor_id,
		@DateTime,
		@Facility,
		@RecordAccessId,
		@ChiefComplaint,
		@EMSNote,
		getutcdate()
	from dbo.Link_HPMember_Doctor md
	where md.mvdid = @mvdid

END