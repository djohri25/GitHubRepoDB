/****** Object:  Procedure [dbo].[UpdateToDoHedisByTest]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Check if required test was performed in PCP office after the test request date
--  If so then then remove it from pending tests
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[UpdateToDoHedisByTest]
	@LookupHedisTestID int
AS
BEGIN
	SET NOCOUNT ON;

--select @LookupHedisTestID = 4

declare @recordid int, @memberID varchar(50), @mvdid varchar(50), @testLookupID int, @testDate datetime,
		@Major nvarchar(100), @Minor nvarchar(100), @Source varchar(50), @Created datetime

declare @toProcess table (recordid int, memberID varchar(50), mvdid varchar(50), 
	Major nvarchar(100),Minor nvarchar(100),Source varchar(50),Created datetime,
	testLookupID int, testDate datetime, isProcessed bit default(0))

declare @tempArchive table(
	SourceRecordID int,
	MemberID varchar(20),
	Major nvarchar(100),
	Minor nvarchar(100),
	Source varchar(50),
	Created datetime,
	TestLookupID int,
	PerformedByNPI varchar(50),
	ProcedureCode varchar(20),
	ProcedureCodingSystem varchar(20),
	ProcedureSourceID int
)	

insert into @toProcess (recordid,memberID,mvdid,testLookupID,testDate,Major,Minor,Source,Created)
select h.ID,h.MemberID,li.MVDId,h.testLookupID,h.Created,h.Major,h.Minor,h.Source,h.Created 
from MainToDoHEDIS h
	inner join Link_MemberId_MVD_Ins li on h.MemberID = li.InsMemberId
where Source = 'HEDIS:Amerigroup'
	and testlookupID = @LookupHedisTestID

--select * from @toProcess

while exists(select top 1 memberid from @toProcess where isProcessed = 0)
begin
	select top 1 @recordid = recordid,
		@memberID = memberID,
		@mvdid = mvdid,
		@testLookupID = testLookupID,
		@testDate = testDate,
		@Major = major, 
		@Minor = minor, 
		@Source = source, 
		@Created = created
	from @toProcess 
	where isProcessed = 0

	insert into @tempArchive (
		SourceRecordID,MemberID,Major,Minor,Source,Created,TestLookupID,
		PerformedByNPI,ProcedureCode,ProcedureCodingSystem,ProcedureSourceID)
	select distinct @recordid,@memberID,@Major,@Minor,@Source,@Created,@testLookupID,
		s.UpdatedByNPI,s.Code,s.CodingSystem,s.RecordNumber
	from MainSurgeries s
		inner join dbo.LookupNPI n on s.CreatedByNPI = n.NPI		
		inner join dbo.LookupNPI n2 on s.UpdatedByNPI = n2.NPI		
	where icenumber = @mvdid 
		AND
		((CodingSystem = 'CPT' and Code in (select procedureCode from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'CPT' and doneByPCP = 1 ))
			OR
			(CodingSystem = 'HCPCS' and Code in (select procedureCode from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'HCPCS' and doneByPCP = 1 ))
		)
		AND YearDate > @testDate
		AND (n.[Healthcare Provider Taxonomy Code_1] in
				(
					-- The test/procedure was performed in PCP office
					select TaxonomyCode from pcptaxonomy
				)
				OR
				n2.[Healthcare Provider Taxonomy Code_1] in
				(
					-- The test/procedure was performed in PCP office
					select TaxonomyCode from pcptaxonomy
				)	
			)

	if exists(select top 1 * from Link_ToDoTestProcedure where testLookupID = @testLookupID and (ProcedureCodingSystem = 'CPT' OR ProcedureCodingSystem = 'HCPCS') and doneByPCP = 0)
	begin
		insert into @tempArchive (
			SourceRecordID,MemberID,Major,Minor,Source,Created,TestLookupID,
			PerformedByNPI,ProcedureCode,ProcedureCodingSystem,ProcedureSourceID)
		select distinct @recordid,@memberID,@Major,@Minor,@Source,@Created,@testLookupID,
			s.UpdatedByNPI,s.Code,s.CodingSystem,s.RecordNumber
		from MainSurgeries s
		where icenumber = @mvdid 
			AND
			((CodingSystem = 'CPT' and Code in (select procedureCode from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'CPT' and doneByPCP = 0))
				OR
				(CodingSystem = 'HCPCS' and Code in (select procedureCode from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'HCPCS' and doneByPCP = 0))
			)
			AND YearDate > @testDate
	end
		
	if exists(select top 1 TestLookupID from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'LOINC')
	begin
		insert into @tempArchive (
			SourceRecordID,MemberID,Major,Minor,Source,Created,TestLookupID,
			PerformedByNPI,ProcedureCode,ProcedureCodingSystem,ProcedureSourceID)
		select distinct @recordid,@memberID,@Major,@Minor,@Source,@Created,@testLookupID,
			s.UpdatedByNPI,s.Code,s.CodingSystem,s.RecordNumber
		from MainLabResult s				
		where icenumber = @mvdid 
			AND ReportedDate > @testDate
			AND
			((CodingSystem = 'LOINC' OR CodingSystem = 'L') and Code in (select procedureCode from Link_ToDoTestProcedure where testLookupID = @testLookupID and ProcedureCodingSystem = 'LOINC' )
			)
	end
	
	--select * from @tempArchive
	
	insert into MainToDoHEDIS_Done(
		SourceRecordID,MemberID,Major,Minor,Source,Created,TestLookupID,
		PerformedByNPI,ProcedureCode,ProcedureCodingSystem,ProcedureSourceID
	)	
	select distinct SourceRecordID,MemberID,Major,Minor,Source,Created,TestLookupID,
		PerformedByNPI,ProcedureCode,ProcedureCodingSystem,ProcedureSourceID 
	from @tempArchive			
	
	--select * from pcptaxonomy
	
	--select * from dbo.Link_ToDoTestProcedure
	
	--select * from lookupHedis

	delete from MainToDoHEDIS
	where ID in
	(
		select sourceRecordID from @tempArchive
	)

	delete from @tempArchive
	update @toProcess set isProcessed = 1 where recordid = @recordid
end
END