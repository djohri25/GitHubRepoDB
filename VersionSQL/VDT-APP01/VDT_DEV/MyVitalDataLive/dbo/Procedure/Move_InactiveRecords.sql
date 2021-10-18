/****** Object:  Procedure [dbo].[Move_InactiveRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 8/22/2011
-- Description:	Move inactive member records (expired insurance) to archive database
-- =============================================
CREATE Procedure [dbo].[Move_InactiveRecords]
As
SET NOCOUNT ON

declare
	@CurIteration int,
	@BundleCount int,					-- number of records in the current bundle	
	@CanProceed bit						-- when set to False in ImportConfig, the import will stop when the current bundle is finished

declare
	@MVDId varchar(15), 
	@UpdateResult int,

	-- statistics
	@SuccessfulCount int,		-- # of successfully processed records
	@FailedCount int			-- # of unsuccessfully processed records

select @UpdateResult = 0,
	@SuccessfulCount = 0,
	@FailedCount = 0

declare @tempSummary table (
	SuccessfulCount int,	
	FailedCount int
)

-- Holds data which needs to be processed
declare @tempRecords table (
	MVDID varchar(50)
)

select @CurIteration = 0,
	@SuccessfulCount = 0,
	@FailedCount = 0

EXEC Upd_ActiveMembers

-- Populate temp table with unprocessed records
insert into @tempRecords 
(	MVDID
)
select top 1000 
	MVDID
from Link_MemberId_MVD_Ins
where Active = 0 AND isArchived = 0 and ArchiveAttemptCount = 0


select @BundleCount = count(MVDID) from @tempRecords

BEGIN TRY	
	WHILE @BundleCount > 0 
	begin
		set @CurIteration = @CurIteration + 1

		-- Process each record separately
		while exists (select top 1 * from @tempRecords) 
		begin
			select top 1 @MVDID = MVDID
			from @tempRecords 

			BEGIN TRY

				--EXEC [94553-MSSQL].dbo.Import_Demog_Single
				EXEC Move_InactiveMemberRecord
					@MVDID = @MVDID
			END TRY
			BEGIN CATCH
				SELECT @UpdateResult = -1

				declare @AdditionalInfo varchar(100)
				select @AdditionalInfo = @MVDId

				EXEC ImportCatchError @AddInfo = @AdditionalInfo	
			END CATCH

			if( @UpdateResult = 0 )
			begin
				-- Set Record as already processed
				update Link_MemberId_MVD_Ins
				set isArchived = 1, ArchivedDate = getutcdate(), ArchiveAttemptCount = 0
				where MVDId = @MVDId

				set @SuccessfulCount = @SuccessfulCount + 1
			end
			else
			begin
				set @FailedCount = @FailedCount + 1
				
				update Link_MemberId_MVD_Ins set archiveAttemptCount = archiveAttemptCount + 1 
				where MVDId = @MVDId
			end


			if exists (select * from @tempSummary)
			begin
				update @tempSummary set 
					SuccessfulCount = @SuccessfulCount,
					FailedCount = @FailedCount
				from @tempSummary 
			end
			else
			begin
				insert into @tempSummary (SuccessfulCount,FailedCount)
				values(@SuccessfulCount,@FailedCount)
			end

			delete from @tempRecords where MVDId = @MVDId
		end 	-- end processing bundle

		-- Get records for the next bundle processing
		-- Populate temp table with unprocessed records
		insert into @tempRecords 
		(	MVDID
		)
		select top 1000 
			MVDID
		from Link_MemberId_MVD_Ins
		where Active = 0 AND isArchived = 0 and ArchiveAttemptCount = 0
			
		select @BundleCount = count(MVDID) from @tempRecords
	end	-- END WHILE
		
		
	-- Record import summary
	if exists (select * from @tempSummary)
	begin
		select 
			@SuccessfulCount = SuccessfulCount,
			@FailedCount = FailedCount
		from @tempSummary 

		EXEC HPM_Import.dbo.Upd_ImportSummary
			@ImportType = 'ArchiveRecords',
			@SuccessfulCount = @SuccessfulCount,
			@FailedCount = @FailedCount,
			@NewMemberCount = 0,
			@UpdatedMemberCount = 0,
			@DeactivatedCount = 0,
			@DestinationDB = 'MyVitalDataLIVE',
			@CustomerName = ''

		delete from @tempSummary
	end
END TRY
BEGIN CATCH

	EXEC ImportCatchError	
END CATCH