/****** Object:  Procedure [dbo].[Get_PatientInfoHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 9/11/2009
-- Description:	Gets basic information about the patient identified by MVD ID or other ID
--	assigned to her/him by third party
--  IDType represents the customer ID (or id of the other criteria implemented in the future, e.g. SSN)
--  If IDType = 0 (Default) it means MVD ID was provided
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientInfoHeader]
	@ID varchar(30),
	@IDType int
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdid varchar(30),
		@hpMemberID varchar(20),
		@Membername varchar(200),
		@hpCustomerID int,
		@hpname varchar(50)

	if(@IDType = 0 OR @IDType is null)
	begin
		-- MyVitalData ID
		set @mvdid = @ID
	end
	else if exists (select id from dbo.LookupPatientIDType where id = @IDType )
	begin
		-- None of the customers (e.g. health plan) should have same ID as 
		-- one of the ID's of Patient ID types
		-- Assuming that, we can be sure there is no mismatch
		declare @IDTypeName varchar(50)
		select @IDTypeName = Name from dbo.LookupPatientIDType where id = @idType
		if( @IDTypeName = 'SSN' or @IDTypeName = 'Social Security Number')
		begin
			select @mvdid = ICENUMBER from mainpersonaldetails where SSN = @ID
		end
	end
	else 
	begin
		select @ID = REPLACE(LTRIM(REPLACE(@ID, '0', ' ')), ' ', '0')
		select @mvdid = MVDId from Link_MemberId_MVD_Ins 
		where cust_ID is not null and cust_ID = @IDType and REPLACE(LTRIM(REPLACE(InsMemberID, '0', ' ')), ' ', '0') = @ID
	end

	if( len(isnull(@mvdid,'')) > 0)
	begin
		/*
			Format:
				Name: John Doe
				HP Name: Health Plan of Michigan
				ID: 333444555
		*/	

		if exists (select mvdid from Link_MemberId_MVD_Ins where mvdid = @mvdid)
		begin
			select isnull(p.firstName + ' ','') + isnull(p.lastname,'') as memberName,
				li.insMemberID as hpmemberID,
				c.name as hpName
			from mainpersonaldetails p
				inner join dbo.Link_MVDID_CustID li on p.icenumber = li.mvdid
				inner join hpcustomer c on li.cust_id = c.cust_id
			where p.icenumber = @mvdid
		end
		else
		begin
			-- Member doesn't belong to any health plan
			select isnull(firstName + ' ','') + isnull(lastname,'') as memberName,
				@mvdid as hpmemberID,
				'MyVitalData' as hpName
			from mainpersonaldetails
			where icenumber = @mvdid
		end
	end	
END