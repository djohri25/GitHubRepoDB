/****** Object:  Procedure [dbo].[Get_MDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/11/2009
-- Description:	Returns patient status viewed by specific doctor
-- 1 - Patient record not changed
-- 2 - Test needed (patient is recommened to perform some test)
-- 3 - Data updated
-- 4 - Visited ER
-- -1 - Error
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientStatus]
	@MvdID varchar(15),
	@DoctorID varchar(15),
	@StatusIDList varchar(50) out
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @tempUpdatedSections table(SectionName varchar(50), LastUpdate datetime)
	declare @LastViewedDate datetime, -- date when doctor last time viewed patient's record
		@insMemberID varchar(20)	

	select @LastViewedDate = max(created) 
	from dbo.MVD_AppRecord_MD 
	where username = @DoctorID and mvdid = @MvdID

	select @insMemberID = insMemberId
	from Link_MVDID_CustID
	where mvdid = @mvdid

	if(@LastViewedDate is null)
	begin
		set @LastViewedDate = '1/1/1900'
	end

	insert into @tempUpdatedSections (SectionName, LastUpdate)
	EXEC Get_UpdatedPatientRecordSections
		@MvdID = @MvdID,
		@TimeStamp = @LastViewedDate

	set @StatusIDList = ''

	if exists (select recordid from mvd_appRecord 
		where mvdid = @MvdID and Action = 'LOOKUP' AND ResultStatus = 'SUCCESS' 
			AND ResultCount='1' and created > @LastViewedDate)
	begin
		set @StatusIDList = '4,' -- Visited ED
	end

	if exists (select sectionName from @tempUpdatedSections)
	begin
		set @StatusIDList = @StatusIDList + '3,' -- Data Updated
	end

	if len(isnull(@insMemberID,'')) > 0 and exists (select memberID from dbo.MainToDoHEDIS where memberID = @insMemberID)
	begin
		set @StatusIDList = @StatusIDList + '2,' -- Test needed
	end

	if(len(@StatusIDList) = 0)
	begin
		set @StatusIDList = '1' -- No change
	end
	else
	begin
		set @StatusIDList = substring(@StatusIDList,0,len(@StatusIDList))
	end
END