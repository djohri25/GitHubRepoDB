/****** Object:  Procedure [dbo].[usp_ExecGrantViewDefinition]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[usp_ExecGrantViewDefinition]  
(@login VARCHAR(30))  
AS  
/* 

Author: Sunil Nokku
Date Modified: 7/29/2020
About: This SP is to give View definition to a particular user for All SP

Included Object Types are:  
P - Stored Procedure  
V - View  
FN - SQL scalar-function 
TR - Trigger  
IF - SQL inlined table-valued function 
TF - SQL table-valued function 
U - Table (user-defined) 

EXEC usp_ExecGrantViewDefinition 'zwang' 
GO 
*/  
SET NOCOUNT ON  

CREATE TABLE #runSQL 
(runSQL VARCHAR(2000) NOT NULL)  

--Declare @execSQL varchar(2000), @login varchar(30), @space char (1), @TO char (2)  
DECLARE @execSQL VARCHAR(2000), @space CHAR (1), @TO CHAR (2)  

SET @to = 'TO' 
SET @execSQL = 'Grant View Definition ON '  
SET @login = REPLACE(REPLACE (@login, '[', ''), ']', '') 
SET @login = '[' + @login + ']' 
SET @space = ' ' 

INSERT INTO #runSQL  
SELECT @execSQL + schema_name(schema_id) + '.' + [name] + @space + @TO + @space + @login  
FROM sys.all_objects s  
WHERE type IN ('P')  
AND is_ms_shipped = 0  
ORDER BY s.type, s.name  

SET @execSQL = ''  

Execute_SQL:  

SET ROWCOUNT 1  

SELECT @execSQL = runSQL FROM #runSQL 

PRINT @execSQL --Comment out if you don't want to see the output 

--EXEC (@execSQL) 

DELETE FROM #runSQL WHERE runSQL = @execSQL 

IF EXISTS (SELECT * FROM #runSQL)  
   GOTO Execute_SQL  

SET ROWCOUNT 0 

DROP TABLE #runSQL  