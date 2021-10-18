/****** Object:  Procedure [dbo].[Set_OutgoingHPMAgentAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/17/2009
-- Description:	Create Outgoing Alert which will be sent to Health Plan of Michigan agents 
--		to notify that member record was accessed in
--		a health care facility
-- =============================================
create PROCEDURE [dbo].[Set_OutgoingHPMAgentAlert]
	@RecordAccessID int,
	@CustomerID int,
	@RecipientEmail varchar(50),
	@InsMemberId varchar(30),
	@MemberFName varchar(50),
	@MemberLName varchar(50),
	@Date varchar(50),
	@NPI varchar(50),
	@Facility varchar(50),	-- Name of the facility where the record was accessed
	@ChiefComplaint varchar(100),
	@EMSNote varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert into pending/outgoing notifications table
	insert into SendHP_Alert
	(	RecordAccessID
		,CustomerID
		,RecipientEmail
		,InsMemberId
		,InsMemberFName
		,InsMemberLName
		,AccessDate
		,NPI
		,FacilityName
		,ChiefComplaint
		,EMSNote
		,Status
	)
	values
	(	
		@RecordAccessID,
		@CustomerID,
		@RecipientEmail,
		@InsMemberId,
		@MemberFName,
		@MemberLName,
		@Date,
		@NPI,
		@Facility,
		@ChiefComplaint,
		@EMSNote,
		'PENDING'
	)

END