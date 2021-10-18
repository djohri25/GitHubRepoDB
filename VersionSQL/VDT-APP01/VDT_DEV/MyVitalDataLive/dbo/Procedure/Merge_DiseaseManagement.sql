/****** Object:  Procedure [dbo].[Merge_DiseaseManagement]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Merge_DiseaseManagement]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainDiseaseManagement where ICENUMBER = @MVDID_1)
	begin
		insert into MainDiseaseManagement(ICENUMBER,Created,DM_ID,name)
		select @MVDID_1,Created,DM_ID,name
        from MainDiseaseManagement
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @DM_ID2 int,
			@recordNumber1 int
	
		declare @tempDiseaseManagement1 table (
			RecordNumber int,ICENUMBER varchar(15),Created datetime,DM_ID int,name varchar(100),
			isProcessed bit default(0)
		)

		declare @tempDiseaseManagement2 table (
			RecordNumber int,ICENUMBER varchar(15),Created datetime,DM_ID int,name varchar(100),
			isProcessed bit default(0)
		)
	
		insert into @tempDiseaseManagement1(
			RecordNumber,ICENUMBER,Created,DM_ID,name)
		select RecordNumber,ICENUMBER,Created,DM_ID,name
        from MainDiseaseManagement
        where ICENUMBER = @MVDID_1

		insert into @tempDiseaseManagement2(
			RecordNumber,ICENUMBER,Created,DM_ID,name)
		select RecordNumber,ICENUMBER,Created,DM_ID,name
        from MainDiseaseManagement
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempDiseaseManagement2 where isProcessed = 0)
		begin		
		
			select top 1 
				@recordNumber2 = RecordNumber,
				@DM_ID2 = DM_ID
			from @tempDiseaseManagement2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber
			from @tempDiseaseManagement1
			where DM_ID = @DM_ID2
				
			if ISNULL(@recordNumber1,'') = ''
			begin			
				insert into MainDiseaseManagement(
					ICENUMBER
					,Created,DM_ID,name)
				select @MVDID_1,
					Created,DM_ID,name
				from @tempDiseaseManagement2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null
		
			update @tempDiseaseManagement2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END