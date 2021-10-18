/****** Object:  Procedure [dbo].[Import_DMPrograms]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/19/2009
-- Description:	Process the list of pipe delimited "|"
--	Disease Management programs for specified member
-- =============================================
CREATE PROCEDURE [dbo].[Import_DMPrograms]
	@MVDID varchar(15),
	@DMProgramList varchar(1000),
	@HPCustomerID int,
	@Result int OUT
AS
BEGIN
	SET NOCOUNT ON;

--	select @MVDID = 'B85GC27WN9',
--		@DMProgramList = 'Asthma L1|ALPHA A4|CVD L3 | Test Prog 1',
--		@HPCustomerID = 1

	declare @curProgram varchar(50), @curProgramID int

	set @DMProgramList = rtrim(LTrim(@DMProgramList))

	if(len(@DMProgramList) > 0)
	begin
		declare @tempPrograms table (name varchar(50), isProcessed bit default(0))

		insert into @tempPrograms(name)
		select rtrim(LTrim(data)) from dbo.Split(@DMProgramList,'|')

		while exists(select name from @tempPrograms where isProcessed = 0)
		begin
			select top 1 @curProgram = name from @tempPrograms where isProcessed = 0

			set @curProgramID = null

			select @curProgramID = DM_ID 
			from dbo.HPDiseaseManagement 
			where name = @curProgram
				 and cust_id = @HPCustomerID

			-- Update Lookup list
			if(@curProgramID is null)			
			begin
				insert into dbo.HPDiseaseManagement(name,cust_id,active)
				values (@curProgram,@HPCustomerID, 1)

				set @curProgramID = scope_identity()
			end

			if(@curProgramID is not null)
			begin
				IF NOT EXISTS(SELECT TOP 1 recordnumber FROM dbo.MainDiseaseManagement WHERE icenumber = @mvdid AND dm_id = @curProgramID)
				begin
					insert into MainDiseaseManagement(icenumber,dm_id,created)
					values(@mvdid,@curProgramID,getutcdate())
				end
			end
			else
			begin
				set @result = -1
			end

			update @tempPrograms set isProcessed = 1 where name = @curProgram
		end
	end

	set @result = 0

END