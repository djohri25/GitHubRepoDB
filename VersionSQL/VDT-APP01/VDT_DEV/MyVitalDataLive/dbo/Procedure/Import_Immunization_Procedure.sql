/****** Object:  Procedure [dbo].[Import_Immunization_Procedure]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		DJS
-- Create date: 10/13/2015
-- Description:	Import Immunization record from Claims Procedure data
-- =============================================
CREATE PROCEDURE [dbo].[Import_Immunization_Procedure]
	@ClaimRecordID INT,
	@MVDId varchar(15),
	@ProcedureCode varchar(50),
	@ProcedureDate varchar(50),
	@Customer varchar(50),
	@UpdatedBy varchar(250),			-- Only set when Individual updates a record
	@UpdatedByContact varchar(50),		-- Common field for UpdatedBy and Organization
	@Organization varchar(250),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ImportResult int,			-- 0 - success, -1 - failure
		@ToUpdateProcDate datetime,		-- Procedure/Test date of the already existing item
		@ImmunizationName varchar(50),
		-- History
		@Action char(1),
		@MVDUpdatedRecordId int

	set @ImportResult = 0

	IF ISNULL(@ProcedureCode,'') != ''
	begin
		BEGIN TRY

			SELECT @ImmunizationName = NULL
			SELECT @ImmunizationName = [ImmunName] FROM	LookupImmunizationCPT WHERE CPTCode = @ProcedureCode

			-- Not all procedures are for immunizations, no problem just skip them
			IF @ImmunizationName IS NOT NULL
			BEGIN

				-- Check if immunization already exists on record
				SET @MVDUpdatedRecordId = NULL
				
				SELECT	TOP 1 @MVDUpdatedRecordId = RecordNumber, @ToUpdateProcDate = DateDone
				FROM	[dbo].[MainImmunization]
				WHERE	[ICENUMBER] = @MVDId AND [ImmunizationCode] = @ProcedureCode
				ORDER BY DateDone DESC
	
				
				IF @MVDUpdatedRecordId IS NULL
				begin				
					insert into [dbo].[MainImmunization] (	[ICENUMBER],	[ImmunizationName],	[DateDone],		[DateApproximate],	[CreationDate],	[ModifyDate],	[HVID],	[HVFlag],	[ReadOnly],	[CreatedBy],	[CreatedByOrganization],	[UpdatedBy],		[UpdatedByOrganization],	[UpdatedByContact],	[Organization],	[ImmunizationCode])
					values (								@MVDId,			@ImmunizationName,	@ProcedureDate,	0,					GETDATE(),		GETDATE(),		NULL,	0,			0,			@UpdatedBy,		@Organization,				@UpdatedBy,			@Organization,				@UpdatedByContact,  @Organization,	@ProcedureCode)

					select @Action = 'A', @MVDUpdatedRecordId = SCOPE_IDENTITY()
				end
				else
				begin
					-- Don't create procedure/test with same name
					-- Keep most recent procedure/test. 
					-- Update UpdatedBy and Organization as the most recent data provider


					if( @ProcedureDate >= @ToUpdateProcDate)
					begin
						update [dbo].[MainImmunization] set [DateDone] = @ProcedureDate,[UpdatedBy] = @UpdatedBy, 
							[UpdatedByContact] = @UpdatedByContact, [UpdatedByOrganization] = @Organization, [ModifyDate] = GETDATE()							
						where [RecordNumber] = @MVDUpdatedRecordId
 
						set @Action = 'U'
					end
					else
					begin
						set @Action = 'I'	-- Ignore
					end
				end
 
				IF @ImportResult = 0
				BEGIN
					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @ClaimRecordID,
						@HPAssignedID = '',
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = 'A',
						@RecordType = 'Vaccine',
						@Customer = @Customer,
						@SourceName = 'CLAIMS'
				END





			END


		END TRY
		BEGIN CATCH
			SELECT @ImportResult = -1

		DECLARE @addInfo nvarchar(MAX)	

		SELECT @Result = -1,
			@addInfo = 
				'@ClaimRecordId=' + convert(varchar,@ClaimRecordId) + ', 
				@MVDId=' + ISNULL( @MVDId, 'NULL') + ', 
				@ProcedureCode =' + ISNULL( @ProcedureCode, 'NULL') + ', 
				@ProcedureDate =' + ISNULL( @ProcedureDate, 'NULL') + ', 
				@UpdatedBy=' + ISNULL( @UpdatedBy, 'NULL') + ', 
				@UpdatedByContact=' + ISNULL( @UpdatedByContact, 'NULL') + ', 
				@Organization=' + ISNULL( @Organization, 'NULL') 



		EXEC ImportCatchError @addinfo = @addInfo	
		END CATCH
	end

	set @Result = @ImportResult
END