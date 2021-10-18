/****** Object:  Procedure [dbo].[Import_ImmTracVaccine_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 8/31/2013
-- Description:	Import single Vaccine record
-- =============================================
CREATE PROCEDURE [dbo].[Import_ImmTracVaccine_Single]
	@RecordId int,
	@ImmTracClientID varchar(10),
	@RequestorClientID varchar(16),
	@StatusCode varchar(1),
	@VaccineCode varchar(10),
	@ImmunizationDate varchar(8),
	@ImmTracProviderID varchar(10),
	@VaccineLotNumber varchar(10),
	@ManufacturerCode varchar(3),
	@HPCustomerID int,
	@Customer varchar(50),
	@ImportResult int output
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		-- mvd data
		@MVDId varchar(15), 
		-- History
		@MVDUpdatedRecordId varchar(50),
		@SourceName varchar(50)

	declare @tempIDs table(mvdid varchar(50))

	Select @ImportResult = 0,
		@SourceName = 'ImmTrac'
	
	-- TODO: DECIDE WHAT TO DO WITH CASES WHERE SAME INS MEMBER ID IS ASSIGNED TO 2 DIFFERENT MVDIDs

	BEGIN TRY
		BEGIN TRAN

		-- There is a chance same member has 2 different MVDIDs because 2 different Insurance IDs were provided by health plan
		insert into @tempIDs(mvdid)
		SELECT MVDId 
		FROM Link_MemberId_MVD_Ins 
		WHERE System_Memid = @RequestorClientID 
			and cust_id = @HPCustomerID
			and IsPrimary = 1
		
		if not exists(select top 1 * from @tempIDs)
		begin
			set @ImportResult = -2 -- Member not found
		end
		else
		begin

			while exists (select top 1 * from @tempIDs)
			begin
				select top 1 @MVDId = mvdid
				from @tempIDs

				if not exists(select top 1 * from MainImmunization 
					where icenumber = @mvdid and ImmunizationCode = @VaccineCode and DateDone = CONVERT(datetime, @ImmunizationDate))
				begin
					insert into MainImmunization(ICENUMBER,DateDone,ImmunizationCode,CreatedByOrganization,UpdatedByOrganization)
					values(@MVDId,CONVERT(datetime, @ImmunizationDate), @VaccineCode, @SourceName, @SourceName)

					select @MVDUpdatedRecordId = (SCOPE_IDENTITY()) 
				end				

				IF @ImportResult = 0
				BEGIN
					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @RecordId,
						@HPAssignedID = '',
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = 'A',
						@RecordType = 'Vaccine',
						@Customer = @Customer,
						@SourceName = @SourceName
				END

				delete from @tempIDs where mvdid = @MVDId
			END
		end
		
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @addInfo nvarchar(MAX)
	
		SELECT	@ImportResult = -1,
				@addInfo = 
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', RequestorClientID=' + ISNULL(@RequestorClientID, 'NULL') + ', VaccineCode=' + ISNULL(@VaccineCode, 'NULL') + 
					', ImmunizationDate=' + ISNULL(@ImmunizationDate, 'NULL') + ', HPCustomerID=' + ISNULL(@HPCustomerID, 'NULL') + ', Customer=' + ISNULL(@Customer, 'NULL')     
		EXEC ImportCatchError @addInfo
	END CATCH

END