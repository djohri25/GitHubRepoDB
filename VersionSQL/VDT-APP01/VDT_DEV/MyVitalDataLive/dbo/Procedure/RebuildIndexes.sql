/****** Object:  Procedure [dbo].[RebuildIndexes]    Committed by VersionSQL https://www.versionsql.com ******/

/*======================================================================================
Rebuild index 
Run weekly
Author 
LUNA 
DATE:2/3/2020
Description: Rebuild index
Modified : 5/1/2020		Sunil Nokku		To filter out old tables 
Modified : 6/22/2020		Sunil Nokku		To run for Computed Tables
=======================================================================================*/

CREATE PROCEDURE [dbo].[RebuildIndexes]

AS

BEGIN

	SET NOCOUNT ON;

	ALTER INDEX ALL ON Task REBUILD
	ALTER INDEX ALL ON ComputedCareQueue REBUILD

	--DECLARE @db_id		SMALLINT;  
	--DECLARE @object_id  INT;  
	--DECLARE @ObjectName VARCHAR(100)
	--DECLARE @TableName  VARCHAR(100)
	--DECLARE @IndexName	VARCHAR(100)
	--DECLARE @SQL	    VARCHAR(1000)


	--SET @db_id = DB_ID(DB_NAME()); 

	--IF Object_ID('TempDB.dbo.#Indexes','U') is not null

	--DROP TABLE #Indexes

	--CREATE TABLE #Indexes
	--(
	--	TableName						VARCHAR(100),
	--	IndexName						VARCHAR(200),
	--	avg_fragmentation_in_percent	FLOAT
	--)

	--IF Object_ID('TempDB.dbo.#Tables','U') is not null
	--BEGIN
	--	DROP TABLE #Tables
	--END

	--CREATE TABLE #Tables
	--(
	--	TABLE_CATALOG	VARCHAR(100), 
	--	TABLE_SCHEMA	VARCHAR(100), 
	--	TABLE_NAME		VARCHAR(100), 
	--	TABLE_TYPE		VARCHAR(100),
	--	ObjectID		VARCHAR(50),
	--	indicator		int 
	--)

	--INSERT INTO #Tables

	--SELECT TABLE_CATALOG,
	--TABLE_SCHEMA,
	--TABLE_NAME,
	--TABLE_TYPE,
	--OBJECT_ID(table_name) AS ObjectID,0 as indicator 
	--FROM INFORMATION_SCHEMA.Tables 
	--WHERE TABLE_TYPE = 'BASE TABLE' 
	--and TABLE_NAME IN ('ComputedCareQueue','ComputedMemberAlert','ComputedMemberMaternity','ComputedMemberEncounterHistory','ComputedMemberTotalPaidClaimsRollling12',
	--					'ComputedMemberTotalPendedClaimsRollling12','ElixMemberRisk','Task')

	--WHILE EXISTS (SELECT 1 FROM #Tables WHERE indicator=0)
	
	--BEGIN

	
	--	SELECT @object_id=MIN(ObjectID)OVER(PARTITION BY OBJECTID ORDER BY OBJECTID) FROM #TABLES WHERE indicator=0
	--	print @object_id 

	--	BEGIN;  
   
	--		INSERT INTO #Indexes (tablename, IndexName, avg_fragmentation_in_percent)
			
	
	--		SELECT
	--			 OBJECT_NAME (indexstats.object_id) AS tablename 
	--			 ,I.Name			AS Indexname 
	--			 ,avg_fragmentation_in_percent 
								 
	--		FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'LIMITED') AS  indexstats
	--		JOIN sys.indexes I 
	--			ON I.object_id = indexstats.object_id
	--			AND I.index_id = indexstats.index_id
			
	--		WHERE avg_fragmentation_in_percent > 30
	--		  AND I.object_id=@object_id;  
	
	--		--SELECT * FROM #Indexes

	--		WHILE EXISTS (SELECT 1 FROM #Indexes)
	--		BEGIN
		
	--			SELECT TOP 1 
	--				  @TableName = tableName
	--				 ,@IndexName = IndexName 
	--			FROM #Indexes

	--			SET @SQL = N'ALTER INDEX ['+ @IndexName + '] ON ' +@TableName + ' REBUILD'

	--			Print @SQL
	--			EXEC (@SQL)
		
	--			DELETE FROM #Indexes 
	--			WHERE 
	--			Tablename = @TableName 
	--			and IndexName = @IndexName
	--		END

	--	END;  

	--	UPDATE TB 
	--	SET tb.indicator=1
	--	FROM #Tables  TB
	--	WHERE ObjectID=@object_id
	--	--PRINT @OjbectName

	--END

END