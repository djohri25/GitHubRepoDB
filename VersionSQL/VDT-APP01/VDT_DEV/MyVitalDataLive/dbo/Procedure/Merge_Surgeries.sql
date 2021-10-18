/****** Object:  Procedure [dbo].[Merge_Surgeries]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/4/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Surgeries]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainSurgeries where ICENUMBER = @MVDID_1)
	begin
		insert into MainSurgeries(
			ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI)
		select @MVDID_1,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI
        from MainSurgeries
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @code2 varchar(20), @codingSystem2 varchar(50),
			@recordNumber1 int, @YearDate1 datetime, @YearDate2 datetime  
	
		declare @tempSurgeries1 table (
			RecordNumber int,ICENUMBER varchar(15),YearDate datetime,Condition varchar(50),Treatment varchar(150),
			Code varchar(20),CodingSystem varchar(50),HVID char(36),CreationDate datetime,ModifyDate datetime,
			HVFlag tinyint,ReadOnly bit,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),
			isProcessed bit default(0)
		)

		declare @tempSurgeries2 table (
			RecordNumber int,ICENUMBER varchar(15),YearDate datetime,Condition varchar(50),Treatment varchar(150),
			Code varchar(20),CodingSystem varchar(50),HVID char(36),CreationDate datetime,ModifyDate datetime,
			HVFlag tinyint,ReadOnly bit,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),
			isProcessed bit default(0)
		)
	
		insert into @tempSurgeries1(
			RecordNumber,ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI)
		select RecordNumber,ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI
        from MainSurgeries
        where ICENUMBER = @MVDID_1

		insert into @tempSurgeries2(
			RecordNumber,ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI)
		select RecordNumber,ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
		   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI
        from MainSurgeries
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempSurgeries2 where isProcessed = 0)
		begin			
			select top 1 
				@recordNumber2 = RecordNumber,
				@code2 = Code,
				@codingSystem2 = CodingSystem,
				@YearDate2 = YearDate
			from @tempSurgeries2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@YearDate1 = YearDate
			from @tempSurgeries1
			where Code = @code2
				AND CodingSystem = @codingSystem2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @YearDate2 > @YearDate1)
			begin
				delete from MainSurgeries	
				where RecordNumber = @recordNumber1
			
				insert into MainSurgeries(
					ICENUMBER
					,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
				   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI)
				select @MVDID_1
					,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
				   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI
				from @tempSurgeries2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@YearDate1 = null
		
			update @tempSurgeries2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END