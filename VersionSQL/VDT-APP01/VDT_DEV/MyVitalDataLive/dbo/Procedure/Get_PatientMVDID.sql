/****** Object:  Procedure [dbo].[Get_PatientMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/10/2009
-- Description:	Gets MyVitalData ID of the patient identified by ID
--	assigned to her/him by third party
--  IDType represents the customer ID (or id of the other criteria introduced in the future, e.g. SSN)
--  If IDType = 0 it means MVD ID was provided and the same value is returned without validation
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientMVDID]
	@ID varchar(30),
	@IDType int,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Cust_ID varchar(10) = null
AS
BEGIN
	SET NOCOUNT ON;
		
	declare @mvdid varchar(30),@hpCustomerID int, @CustID int

	IF @Cust_ID IS NULL
	BEGIN
		Select @CustID = Cust_ID from [dbo].[Link_MemberId_MVD_Ins]
		where insMemberid = @ID
	END
	ELSE
	BEGIN
		Select @CustID = @Cust_ID
	END
	
	select @ID = REPLACE(@ID,' ','')

	if(@IDType = 0)
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
		--	if( isnull(@ID,'') <> '' AND (@IDTypeName = 'SSN' or @IDTypeName = 'Social Security Number'))
		--	begin
		--		select @mvdid = ICENUMBER from mainpersonaldetails where SSN = @ID
		--	end
		--	else if(isnull(@ID,'') <> '' AND @IDTypeName = 'Medicaid ID')
		--	if @ID = 10003
			begin

			If @CustID = 11
			BEGIN
				--select @mvdid = a.ICENUMBER from maininsurance a
				--join mainspecialist b on a.IceNUMBER = b.ICENUMBER
				--join [Link_MemberId_MVD_Ins] c on a.IceNumber = c.MVDID 
				--where a.medicaid = @ID
				--and Tin = @EMS
				--and RoleID = 1
				--and Cust_ID = @CustID
			
			

			    select @mvdid = a.MVDID from [Link_MemberId_MVD_Ins] a
				--join [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_ALLMember] b
				join [dbo].[Final_ALLMember] b
				on a.MVDID = b.MVDID
				where a.insMemberid =  @ID
				--9/8/2015 -Misha removed tin due to Break the glass feature in place 
				--and Tin = @EMS
				--and RoleID = 1
				and a.Cust_ID = @CustID

		
			
			END
			ELSE
			BEGIN
			
				select @mvdid = a.MVDID from [Link_MemberId_MVD_Ins] a
				--join [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_ALLMember] b
				join [dbo].[Final_ALLMember] b
				on a.MVDID = b.MVDID
				where a.insMemberid =  @ID
			--	where a.medicaid = @ID
				--and Tin = @EMS
				--and RoleID = 1
				and Cust_ID = @CustID
			
			END	
				--select * from mainspecialist



			end
			--else if(isnull(@ID,'') <> '' AND @IDTypeName = 'Member ID')
			--begin
			--	select @mvdid = MVDId from Link_MemberId_MVD_Ins where InsMemberId = @ID
			--end			
		end
	END

	if(len(isnull(@mvdid,'')) = 0)
	begin
		
	    if (isnull(@CustID,'') = '') 
		Begin
				set @mvdid = ''
		End
		Else
		BEGIN
				set @mvdid = '999999999'
		END

	
	end

	select @mvdid
	
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = '@ID=' + ISNULL(@ID, 'null') + ';' +
				  '@IDType=' + CONVERT(varchar(50), @IDType) + ';'
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_PatientMVDID]', @EMS, @UserID_SSO, @params