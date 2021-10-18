/****** Object:  Procedure [dbo].[Merge_Condition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/4/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Condition]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainCondition where ICENUMBER = @MVDID_1)
	begin
		insert into MainCondition(ICENUMBER,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName)
		select @MVDID_1,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName
        from MainCondition
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @code2 varchar(20), @reportDate2 datetime,
			@recordNumber1 int, @reportDate1 datetime 
	
		declare @tempCondition1 table (
			RecordNumber int,ICENUMBER varchar(15),ConditionId int,OtherName nvarchar(50),
			Code varchar(20),CodingSystem varchar(50),ReportDate datetime,
			CreationDate datetime,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),HVID char(36),HVFlag tinyint,
			ReadOnly bit,ModifyDate datetime,LabDataRefID int,LabDataSourceName varchar(50),
			isProcessed bit default(0)
		)

		declare @tempCondition2 table (
			RecordNumber int,ICENUMBER varchar(15),ConditionId int,OtherName nvarchar(50),
			Code varchar(20),CodingSystem varchar(50),ReportDate datetime,
			CreationDate datetime,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),HVID char(36),HVFlag tinyint,
			ReadOnly bit,ModifyDate datetime,LabDataRefID int,LabDataSourceName varchar(50),
			isProcessed bit default(0)
		)
	
		insert into @tempCondition1(
			RecordNumber,ICENUMBER,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName)
		select RecordNumber,ICENUMBER,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName
        from MainCondition
        where ICENUMBER = @MVDID_1

		insert into @tempCondition2(
			RecordNumber,ICENUMBER,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName)
		select RecordNumber,ICENUMBER,ConditionId,OtherName,Code,CodingSystem
           ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
           ,LabDataRefID,LabDataSourceName
        from MainCondition
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempCondition2 where isProcessed = 0)
		begin			
			select top 1 
				@recordNumber2 = RecordNumber,
				@code2 = Code,
				@reportDate2 = ReportDate
			from @tempCondition2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@reportDate1 = ReportDate
			from @tempCondition1
			where Code = @code2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @reportDate2 > @reportDate1)
			begin
				delete from MainCondition	
				where RecordNumber = @recordNumber1
			
				insert into MainCondition(
					ICENUMBER
					,ConditionId,OtherName,Code,CodingSystem
					,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
					,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
					,LabDataRefID,LabDataSourceName)
				select @MVDID_1
					,ConditionId,OtherName,Code,CodingSystem
					,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
					,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
					,LabDataRefID,LabDataSourceName
				from @tempCondition2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@reportDate1 = null
		
			update @tempCondition2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END