/****** Object:  Procedure [dba].[Rebuild_Indexes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dba].[Rebuild_Indexes]
--------------------------------------------------------------------------
-- CreatedBy: PPetluri		
-- Date		: 04/28/2017
--	Date		Name			Comments
--------------------------------------------------------------------------
AS
BEGIN

SET NOCOUNT ON;

DECLARE @db_id SMALLINT;  
DECLARE @object_id INT;  
Declare @ObjectName varchar(100)
Declare @TableName varchar(100)
Declare @IndexName	varchar(100)
Declare @SQL	varchar(1000)

SET @db_id = DB_ID(DB_NAME()); 

IF Object_ID('TempDB.dbo.#Indexes','U') is not null
drop table #Indexes
Create table #Indexes
(
	TableName		varchar(100),
	IndexName		varchar(200),
	avg_fragmentation_in_percent	float
)

IF Object_ID('TempDB.dbo.#Tables','U') is not null
drop table #Tables
Create Table #Tables
(
	TABLE_CATALOG	VARCHAR(100), 
	TABLE_SCHEMA	VARCHAR(100), 
	TABLE_NAME		VARCHAR(100), 
	TABLE_TYPE		VARCHAR(100)

)
INSERT INTO #Tables
Select *  FROM INFORMATION_SCHEMA.Tables 
where TABLE_TYPE = 'BASE TABLE' 
and table_name in (
					'HPAlert',
					'HPAlertNote',
					'Link_MemberId_MVD_Ins',
					'MainCareInfo',
					'MainCondition',
					'MainConditionHistory',
					'MainDiseaseCond',
					'MainEMS',
					'MainICEGROUP',
					'MainICENUMBERGroups',
					'MainImmunization',
					'MainInsurance',
					'MainInsurance_History',
					'MainLabNote',
					'MainLabRequest',
					'MainLabResult',
					'MainMedication',
					'MainMedicationHistory',
					'MainMedicationPayments',
					'MainPersonalDetails',
					'MainPlaces',
					'MainSpecialist',
					'MainSurgeries',
					'MainClaimsHeader',
					'MainClaimPayments',
					'EDVisitHistory',
					'DISCHARGE_DATA_History',
					'Final_ALLMember',
					'Final_HEDIS_Member',
					'Final_HEDIS_Member_FULL',
					'LookupNPI',
					'MDUser',
					'MDGroup',
					'MemberDiagnosisSummary',
					'MainRisk'

				 )

While exists (select 1 from #Tables)
BEGIN

select top 1 @ObjectName = '['+TABLE_CATALOG+'].'+ TABLE_SCHEMA+'.['+ TABLE_NAME+ ']' from #Tables 

SET @object_id = OBJECT_ID(@ObjectName); 

BEGIN;  
    INSERT INTO #Indexes (tablename, IndexName, avg_fragmentation_in_percent)
	SELECT OBJECT_NAME (sys.dm_db_index_physical_stats.object_id) as tablename , I.Name as Indexname , avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'LIMITED') 
	JOIN sys.indexes I ON I.object_id = @object_id and I.index_id = sys.dm_db_index_physical_stats.index_id
	Where  ISNULL(I.Name,'') <> '' and avg_fragmentation_in_percent > 10;  
	
	While exists (select 1 from #Indexes)
	BEGIN
		
		Select top 1 @TableName = tableName, @IndexName = IndexName from #Indexes

		SET @SQL = N'ALTER INDEX ['+ @IndexName + '] ON ' +@TableName + ' REBUILD'

		--Print @SQL
		Exec (@SQL)
		
		Delete from #Indexes where Tablename = @TableName and IndexName = @IndexName
	END

END;  
	Delete from #Tables where  '['+TABLE_CATALOG+'].'+ TABLE_SCHEMA+'.['+ TABLE_NAME+ ']' = @ObjectName
END

END