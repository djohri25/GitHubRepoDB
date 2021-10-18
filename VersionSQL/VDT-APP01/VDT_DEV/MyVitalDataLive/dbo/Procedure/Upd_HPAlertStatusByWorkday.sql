/****** Object:  Procedure [dbo].[Upd_HPAlertStatusByWorkday]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPAlertStatusByWorkday]	
AS
BEGIN
	SET NOCOUNT ON;

	declare @newStatusID int, @OutreachNotAttemptedStatusID int, @amerigroupID int, @curDate datetime		
	
	select @newStatusID = ID
	from LookupHPAlertStatus
	where Name = 'New'
	
	select @OutreachNotAttemptedStatusID = ID
	from LookupHPAlertStatus
	where Name = 'Outreach not attempted'
	
	select @amerigroupID = Cust_ID
	from HPCustomer
	where Name = 'Amerigroup' and ParentID is null
		
	select @curDate = GETDATE()
			
	update HPAlert
		set StatusID = @OutreachNotAttemptedStatusID
	where StatusID = @newStatusID
		and AlertDate < dbo.DateAddWorkdays(-3, @curDate)
		and (RecipientCustID = @amerigroupID
			OR RecipientCustID in (select cust_id from HPCustomer where ParentID = @amerigroupID)
		)

END