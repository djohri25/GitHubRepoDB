/****** Object:  Procedure [dbo].[ImportHP_Procedure_837]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 10/22/2008
-- Description:	Import 837 procedure info into MVD member record
--		If the record exists, update. Otherwise create new record
--		Return import status: 0 - success, -1 - failure		
-- =============================================
CREATE PROCEDURE [dbo].[ImportHP_Procedure_837]
	@MVDId varchar(15),
	@ProcCode varchar (10),
	@ProcDate varchar (10),
	@Result int output
as
	declare @CodeType varchar(10),	-- code might come from 2 tables: CPT or HCPCS, 
									-- based on which standard was used
		@ProcDescription varchar(1100)

--	select @MVDId ='N94AY78QF3',
--		@ProcCode ='73630',
--		@ProcDate ='20030712'

	if(len(isnull(@ProcCode,'')) <> 0)
	begin

		BEGIN TRY			
			-- Determine where the code comes from and the procedure description
			if exists (select code from LookupCPT where code = @ProcCode)
			begin
				select @CodeType = 'CPT',
					@ProcDescription = Description1 + ': ' + Description2  
				from LookupCPT 
				where code = @ProcCode
			end
			else if exists (select code from LookupHCPCS where code = @ProcCode)
			begin
				select @CodeType = 'HCPCS',
					@ProcDescription = isnull(Description,'') + ': ' + isnull(DescriptionCont,'')
				from LookupHCPCS 
				where code = @ProcCode
			end			

			if(len(isnull(@CodeType,'')) <> 0 and len(isnull(@ProcDate,'')) = 8 )
			begin
				-- convert  procedure date string to datetime
				declare @prDate datetime

				select @prDate = cast(@ProcDate AS datetime)

				-- Check if the procedure was already imported
				-- TODO: currently allow only one specific procedure per day, check if that's correct
				if(not exists(select icenumber from MainSurgeries 
					where ICENUMBER = @MVDId and condition = (@CodeType + ':' + @ProcCode) and 
					yeardate = @prDate ))
				begin
					-- Create new instance
					INSERT INTO MainSurgeries (ICENUMBER, YearDate,Condition,Treatment,
						CreationDate, ModifyDate) 
					VALUES (@MVDId, @prDate, @CodeType + ':' + @ProcCode, @ProcDescription,
						GETUTCDATE(), GETUTCDATE())
				end

				SET @Result = 0
			end
			else
			begin
				-- TODO: log if the code wasn't found, and maybe notify admin to add the code
				--		to the lookup
				SET @Result = -1
			end
		END TRY
		BEGIN CATCH
			SET @Result = -1

			EXEC ImportCatchError	
		END CATCH
	end