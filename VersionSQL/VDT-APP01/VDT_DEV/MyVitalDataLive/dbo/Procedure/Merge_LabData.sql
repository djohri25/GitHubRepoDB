/****** Object:  Procedure [dbo].[Merge_LabData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_LabData]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainLabRequest where ICENUMBER = @MVDID_1)
	begin
		insert into MainLabRequest(ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
		select @MVDID_1,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
        from MainLabRequest
        where ICENUMBER = @MVDID_2
        
		insert into MainLabResult(ICENUMBER,OrderID,ResultID,ResultName,Code
			,CodingSystem,ResultValue,ResultUnits,RangeLow,RangeHigh,RangeAlpha
			,AbnormalFlag,ReportedDate,Notes,CreationDate,CreatedBy,CreatedByOrganization
			,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
			,UpdatedByNPI,SourceName)
		select @MVDID_1,OrderID,ResultID,ResultName,Code,CodingSystem,ResultValue
			,ResultUnits,RangeLow,RangeHigh,RangeAlpha,AbnormalFlag,ReportedDate
			,Notes,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy
			,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
			,UpdatedByNPI,SourceName
        from MainLabResult
        where ICENUMBER = @MVDID_2
        
		insert into MainLabNote(ICENUMBER,ResultID,Note,CreationDate,CreatedBy
			,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
			,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum)
		select @MVDID_1,ResultID,Note,CreationDate,CreatedBy
			,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
			,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum
        from MainLabNote
        where ICENUMBER = @MVDID_2                
	end
	else
	begin
		-- NOTE: most likely this section is not necessary since same orderID-sourceName will never
		--	exist for 2 different member, but include this section in case the merging fails and 
		--  is rerun multiple times
		declare @recordNumber2 int, @orderID2 int, @sourceName2 varchar(50),
			@recordNumber1 int
	
		declare @tempRequest1 table (
			RecordNumber int,ICENUMBER varchar(15),OrderID varchar(50),OrderName varchar(200),
			OrderCode varchar(20),OrderCodingSystem varchar(50),RequestDate datetime,
			OrderingPhysicianFirstName varchar(50),OrderingPhysicianLastName varchar(50),
			OrderingPhysicianID varchar(50),ProcedureName varchar(200),ProcedureCode varchar(20),
			ProcedureCodingSystem varchar(50),CreationDate datetime,CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),
			UpdatedByContact nvarchar(64),CreatedByNPI varchar(20),UpdatedByNPI varchar(20),
			SourceName varchar(50),
			isProcessed bit default(0)
		)

		declare @tempRequest2 table (
			RecordNumber int,ICENUMBER varchar(15),OrderID varchar(50),OrderName varchar(200),
			OrderCode varchar(20),OrderCodingSystem varchar(50),RequestDate datetime,
			OrderingPhysicianFirstName varchar(50),OrderingPhysicianLastName varchar(50),
			OrderingPhysicianID varchar(50),ProcedureName varchar(200),ProcedureCode varchar(20),
			ProcedureCodingSystem varchar(50),CreationDate datetime,CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),
			UpdatedByContact nvarchar(64),CreatedByNPI varchar(20),UpdatedByNPI varchar(20),
			SourceName varchar(50),
			isProcessed bit default(0)
		)
	
		insert into @tempRequest1(
			RecordNumber,ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
		select RecordNumber,ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
        from MainLabRequest
        where ICENUMBER = @MVDID_1

		insert into @tempRequest2(
			RecordNumber,ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
		select RecordNumber,ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
			,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
			,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
			,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
        from MainLabRequest
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempRequest2 where isProcessed = 0)
		begin		
		
			select top 1 
				@recordNumber2 = RecordNumber,
				@orderID2 = OrderID,
				@sourceName2 = SourceName
			from @tempRequest2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber
			from @tempRequest1
			where OrderID = @orderID2
				and SourceName = @sourceName2
				
			if ISNULL(@recordNumber1,'') = ''
			begin		
				insert into MainLabRequest(
					ICENUMBER
					,OrderID,OrderName,OrderCode,OrderCodingSystem
					,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
					,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
					,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
					,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
				select @MVDID_1
					,OrderID,OrderName,OrderCode,OrderCodingSystem
					,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
					,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
					,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
					,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
				from @tempRequest2
				where RecordNumber = @recordNumber2
						
				insert into MainLabResult(ICENUMBER,OrderID,ResultID,ResultName,Code
					,CodingSystem,ResultValue,ResultUnits,RangeLow,RangeHigh,RangeAlpha
					,AbnormalFlag,ReportedDate,Notes,CreationDate,CreatedBy,CreatedByOrganization
					,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
					,UpdatedByNPI,SourceName)
				select @MVDID_1,OrderID,ResultID,ResultName,Code,CodingSystem,ResultValue
					,ResultUnits,RangeLow,RangeHigh,RangeAlpha,AbnormalFlag,ReportedDate
					,Notes,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy
					,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
					,UpdatedByNPI,SourceName
				from MainLabResult
				where ICENUMBER = @MVDID_2 and OrderID = @orderID2 and SourceName = @sourceName2
		        
				insert into MainLabNote(ICENUMBER,ResultID,Note,CreationDate,CreatedBy
					,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
					,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum)
				select @MVDID_1,ResultID,Note,CreationDate,CreatedBy
					,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
					,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum
				from MainLabNote
				where ICENUMBER = @MVDID_2 and ResultID in
					(
						select ResultID
						from MainLabResult
						where ICENUMBER = @MVDID_2 and OrderID = @orderID2 and SourceName = @sourceName2
					)  				
			end
			
			select @recordNumber1 = null
		
			update @tempRequest2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END