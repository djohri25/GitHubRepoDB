/****** Object:  Procedure [dbo].[ProcessDuplicateRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/27/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessDuplicateRecords]
	@RecordList varchar(4000),
	@PrimaryMVDID varchar(20),
	@Action varchar(50),	
	@NewMVDID varchar(20) OUT -- It has value of newly generated record if Action = Merge
AS
BEGIN
	SET NOCOUNT ON;

	declare @recordIDs table (ID varchar(20), isProcessed bit default(0))
	declare @iterX int,
		@curMVDID varchar(20), @dupMVDID varchar(20),
		@firstMVDID varchar(20), @newMergedMVDID varchar(20)

	--select @RecordList = 'EB718003|ER815694',
	-- @PrimaryMVDID = 'EB718003',
	--	@Action = 'MERGE'
	
	-- DJS 10/23/2015 TODO ** This routine should be updated to handle HPAlertNote table as well as Form* tables **

	insert into @recordIDs(ID)
	select data from dbo.Split(@RecordList,'|')
	
	set @iterX = 1
	while exists(select ID from @recordIDs)
	begin
		select top 1 @curMVDID = ID from @recordIDs
		
		if(@Action = 'MERGE')
		begin
			EXEC ArchiveMergedRecord
				@MVDID = @curMVDID
		
			if (@iterX = 2)
			begin
				EXEC Set_NewMergedAccount
					@MVDID_1 = @firstMVDID,
					@MVDID_2 = @curMVDID,
					@ResultMVDID = @newMergedMVDID OUT	
					
				EXEC MergeMVDRecords
					@MVDID_1 = @newMergedMVDID,
					@MVDID_2 = @firstMVDID
			end

			if(@iterX = 1)
			begin
				set @firstMVDID = @curMVDID	
				
				update Link_MemberId_MVD_Ins
				set IsPrimary = case MVDId
					when @PrimaryMVDID then 1
					else 0
					end
				where  MVDId = @curMVDID								
			end
			else
			begin				
				
				if(@iterX = 2)
				begin
					update Link_MemberId_MVD_Ins
					set MVDId = @newMergedMVDID
					where MVDId = @firstMVDID									
				
					EXEC DEL_MergedRecord
						@MVDID = @firstMVDID	
				end

				EXEC MergeMVDRecords
					@MVDID_1 = @newMergedMVDID,
					@MVDID_2 = @curMVDID				

				update Link_MemberId_MVD_Ins
				set IsPrimary = case MVDId
					when @PrimaryMVDID then 1
					else 0
					end
				where  MVDId = @curMVDID								
				
				update Link_MemberId_MVD_Ins
					set MVDId = @newMergedMVDID
				where MVDId = @curMVDID			
				
				EXEC DEL_MergedRecord
					@MVDID = @curMVDID					
			end		
						
			set @NewMVDID = @newMergedMVDID
		end
		else if(@Action = 'IGNORE')
		begin
			update @recordIDs set isProcessed = 1 where ID = @curMVDID
			
			while exists(select top 1 ID from @recordIDs where isProcessed = 0)
			begin
				select top 1 @dupMVDID = ID from @recordIDs where isProcessed = 0
				
				if not exists(select mvdid_1 from Link_DuplicateRecords where MVDID_1 = @curMVDID and MVDID_2 = @dupMVDID and Status = @Action)
				begin
					insert into Link_DuplicateRecords(MVDID_1,MVDID_2,Status) values(@curMVDID,@dupMVDID,@Action)
				end
				
				update @recordIDs set isProcessed = 1 where ID = @dupMVDID
			end 
			
			update @recordIDs set isProcessed = 0
		end
		
		set @iterX = @iterX + 1
		delete from @recordIDs where ID = @curMVDID
	end
END