/****** Object:  Procedure [dbo].[Get_RequestedPatientMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/10/2009
-- Description:	Returns the MyVitalDataID of the member account
--	which will be looked up based on provided ID and XML formated 
--	access reasons. Example:
--	<ACCESSREASON>
--		<IDTYPE>7</IDTYPE>
--		<CHIEFCOMPLAINT></CHIEFCOMPLAINT>
--		<EMSNOTE></EMSNOTE>
--	</ACCESSREASON>
-- =============================================
CREATE procedure [dbo].[Get_RequestedPatientMVDID]
(
	@ID VARCHAR(30),
	@AccessReason varchar(2000),
	@resultMVDID varchar(20) output
)
AS
BEGIN
	declare @IDoc int				-- handle to XML
	declare @idType varchar(50), @customerId int

	set @resultMVDID = ''

	BEGIN TRY
		EXEC sp_xml_preparedocument @IDoc OUTPUT, @AccessReason

		SELECT @idType = IDTYPE
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (IDTYPE varchar(50))

		if( len(isnull(@idType,'')) > 0)
		begin
			if(@idType = '0')
			begin
				-- MyVitalDataID
				set @resultMVDID = @ID
			end
			else if exists (select id from dbo.LookupPatientIDType where id = @idType )
			begin
				-- None of the customers (e.g. health plan) should have same ID as 
				-- one of the ID's of Patient ID types
				-- Assuming that, we can be sure there is no mismatch
				declare @IDTypeName varchar(50)
				select @IDTypeName = Name from dbo.LookupPatientIDType where id = @idType
				if( isnull(@ID,'') <> '' AND (@IDTypeName = 'SSN' or @IDTypeName = 'Social Security Number'))
				begin
					select @resultMVDID = ICENUMBER from mainpersonaldetails where SSN = @ID
				end
				else if( isnull(@ID,'') <> '' AND @IDTypeName = 'Medicaid ID')
				begin
					select @resultMVDID = ICENUMBER from maininsurance where medicaid = @ID
				end
				else if( isnull(@ID,'') <> '' AND @IDTypeName = 'Member ID')
				begin
					select @resultMVDID = MVDId from Link_MemberId_MVD_Ins where InsMemberId = @ID
				end				
			end
			else
			begin
				-- check if ID matches health plan ID provided by health plan identified by @IDType
				select @ID = REPLACE(LTRIM(REPLACE(@ID, '0', ' ')), ' ', '0')

				if exists(select cust_id from hpCustomer where cust_id = @IDType and name = 'Amerigroup')
				begin
					-- Check if the ID matches Medicaid Id before searching by Insurance member ID
					select @resultMVDID = ICENUMBER from maininsurance where medicaid = @ID

					if(isnull(@resultMVDID,'') = '')
					begin
						select @resultMVDID = MVDId from dbo.Link_MemberId_MVD_Ins 
						where cust_ID is not null and cust_ID = @IDType and InsMemberID = @ID

						--select @resultMVDID = MVDId from dbo.Link_MemberId_MVD_Ins 
						--where cust_ID is not null and cust_ID = @IDType and REPLACE(LTRIM(REPLACE(InsMemberID, '0', ' ')), ' ', '0') = @ID

					end
				end
				else
				begin
					select @resultMVDID = MVDId from dbo.Link_MemberId_MVD_Ins 
					where cust_ID is not null and cust_ID = @idType and InsMemberID = @ID

					--select @resultMVDID = MVDId from dbo.Link_MemberId_MVD_Ins 
					--where cust_ID is not null and cust_ID = @idType and REPLACE(LTRIM(REPLACE(InsMemberID, '0', ' ')), ' ', '0') = @ID
				end

				--select @resultMVDID = MVDId from dbo.Link_MemberId_MVD_Ins 
				--where cust_ID is not null and cust_ID = @idType and REPLACE(LTRIM(REPLACE(InsMemberID, '0', ' ')), ' ', '0') = @ID
			end
		end
		else
		begin
			-- Default ID type is MyVitalData ID
			set @resultMVDID = @ID
		end


		EXEC sp_xml_removedocument @IDoc

	END TRY
	BEGIN CATCH
		-- Consider it MVD ID
		set @resultMVDID = @ID
	END CATCH
END