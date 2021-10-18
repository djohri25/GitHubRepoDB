/****** Object:  Procedure [dbo].[Get_EdVisitHistoryList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 8/4/2008
-- Description:	Returns the list of ED Visit Records.
-- Parameters: 
--		@Limit - if > 0 sets the limit of returned newest records.
--			Otherwise retuns the full list
-- NOTE: don't return records for which the notification was canceled
-- =============================================
CREATE PROCEDURE [dbo].[Get_EdVisitHistoryList]
	@ICENUMBER VARCHAR(15),
	@Limit int -- number of records returned
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- convert access time to Eastern Standard		

    if @Limit > 0
	begin
		SELECT top (@Limit)
		   dbo.ConvertUTCtoEST(VisitDate) as VisitDate
		  ,FacilityName
		  ,PhysicianFirstName
		  ,PhysicianLastName
		  ,isNull(PhysicianFirstName+' ', '') + isNull(PhysicianLastName,'') as PhysicianFullName
		  ,dbo.FormatPhone(PhysicianPhone) As PhysicianPhone
		  ,Source
		  ,SourceRecordID
		FROM EDVisitHistory
		where ICENUMBER = @ICENUMBER
			and (CancelNotification is null OR CancelNotification = '0')
		order by Created desc
	end
	else
	begin
		SELECT 
		   dbo.ConvertUTCtoEST(VisitDate) as VisitDate
		  ,FacilityName
		  ,PhysicianFirstName
		  ,PhysicianLastName
		  ,isNull(PhysicianFirstName+' ', '') + isNull(PhysicianLastName,'') as PhysicianFullName
		  ,dbo.FormatPhone(PhysicianPhone) As PhysicianPhone
		  ,Source
		  ,SourceRecordID
		FROM EDVisitHistory
		where ICENUMBER = @ICENUMBER
			and (CancelNotification is null OR CancelNotification = '0')
		order by Created desc
	end
END