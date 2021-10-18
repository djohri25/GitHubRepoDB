/****** Object:  Procedure [dbo].[Set_LicenseState]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	
-- Create date: 
-- MODIFIED: 
-- Description:	Updates status of nurse licenses based on the flags 
--FLG1: updates states Status 1 to 2 
--FLG2: updates states Status 2 to 3
--FLG3: updates states Status 3 to 2
--FLG4: updates states Status 2 to 1
-- Execution:  exec [Set_LicenseState] 'adbrightwell','TX', null,1, null
--exec dbo.Set_LicenseState @UserName='adbrightwell',@StateNameList=N'AZ',@FLG=2
--modified sproc to use logic for state and county
-- =============================================

CREATE PROCEDURE [dbo].[Set_LicenseState] (@UserName varchar(100),@StateNameList nvarchar(max),@Status smallint=null,@FLG int, @IsActive bit = null)
 AS 

 BEGIN 
 SET NOCOUNT ON;


-- declare @UserName varchar(100) ='adbrightwell'
--,@StateNameList nvarchar(max) = 'UT,AR-ARKANSAS'
--,@Status smallint=null
--,@FLG int = 4
--,@IsActive bit = null


 IF @IsActive IS NULL 
 SET @IsActive= 1

--DROP TEMP TABLE 
 DROP TABLE IF EXISTS #StateNameList

--CREATE TEMP TABLE 
	CREATE TABLE #StateNameList
	(
		StateName varchar(100)
	)

--SPLIT THE COMMA SEPERATED FILE & INSERT INTO A TEMP TABLE 

DECLARE @newCodeID varchar(100), @Pos int

	SET @StateNameList = LTRIM(RTRIM(@StateNameList))+ ','
	SET @Pos = CHARINDEX(',', @StateNameList, 1)

	IF REPLACE(@StateNameList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @newCodeID = LTRIM(RTRIM(LEFT(@StateNameList, @Pos - 1)))
			IF @newCodeID <> ''
			BEGIN
				INSERT INTO #StateNameList (StateName) VALUES (@newCodeID) --Insert into temp table
			END
			SET @StateNameList = RIGHT(@StateNameList, LEN(@StateNameList) - @Pos)
			SET @Pos = CHARINDEX(',', @StateNameList, 1)

		END
	END	

--DROP TEMP TABLE 
 DROP TABLE IF EXISTS #ARBCBS_StateName

--CREATE TEMP TABLE 
	CREATE TABLE #ARBCBS_StateName
	(
		StateName varchar(100),
		CountyName varchar(100)
	)

;WITH Split_Names (StateName, xmlname)
AS
-- Define the CTE query.
(
    SELECT StateName,
    CONVERT(XML,'<Names><name>'  
    + REPLACE(StateName,'-', '</name><name>') + '</name></Names>') AS xmlname
      FROM #StateNameList
)
-- Define the outer query referencing the CTE name.
 INSERT INTO #ARBCBS_StateName(StateName, CountyName) SELECT      
 xmlname.value('/Names[1]/name[1]','varchar(100)') AS StateName,    
 xmlname.value('/Names[1]/name[2]','varchar(100)') AS CountyName
 FROM Split_Names

--select * from #StateNameList
--select * from #ARBCBS_StateName
IF (@FLG=1)
	BEGIN


	IF @status IS NULL 
	SET @status=1
	  

    IF EXISTS (SELECT CountyName FROM #ARBCBS_StateName WHERE CountyName IS NOT NULL)
	

	    UPDATE dbo.NurseLicensure
		SET status=2 
	    --select * from  dbo.NurseLicensure_082119   
	    WHERE username=@UserName AND state IN (SELECT StateName FROM #ARBCBS_StateName)
		AND county IN (SELECT CountyName FROM #ARBCBS_StateName )
		AND status=@status AND IsActive=@IsActive

		
	END

IF (@FLG=1)
	BEGIN


	IF @status IS NULL 
	SET @status=1
	  

    IF EXISTS (SELECT CountyName FROM #ARBCBS_StateName WHERE CountyName IS NULL)

		UPDATE dbo.NurseLicensure
		SET status=2 
		--select * from  dbo.NurseLicensure_082119    
		WHERE username=@UserName AND state IN (SELECT StateName FROM #ARBCBS_StateName)
		AND county IS NULL
		AND status=@status AND IsActive=@IsActive
		
	END

--select * from dbo.NurseLicensure_082119 where username = 'adbrightwell' and status !=1

IF (@FLG=2)

	BEGIN 

	IF @status IS NULL 
	SET @status=2
		   IF EXISTS (SELECT StateName,CountyName FROM #ARBCBS_StateName WHERE CountyName IS NOT NULL)

			UPDATE dbo.NurseLicensure
			SET status=3 
			WHERE username=@UserName AND state IN (SELECT StateName FROM #ARBCBS_StateName)
			AND county IN (SELECT CountyName FROM #ARBCBS_StateName )
			AND status=@status AND IsActive=@IsActive
		
	END	
			
IF (@FLG=2)

	BEGIN 

	IF @status IS NULL 
	SET @status=2
		   IF EXISTS (SELECT StateName,CountyName FROM #ARBCBS_StateName WHERE CountyName IS NULL)

			UPDATE dbo.NurseLicensure
			SET status = 3 
			WHERE State IN (SELECT StateName FROM #ARBCBS_StateName)
			AND County IS NULL
			AND UserName =  @UserName
			AND status = 2
					
     END
	          
--select * from dbo.NurseLicensure_082119 where username = 'adbrightwell' and status !=1

IF (@FLG=3)

	BEGIN 
		IF @status IS NULL 
		SET @status=3
		  IF EXISTS (SELECT statename, CountyName FROM #ARBCBS_StateName WHERE CountyName IS NOT NULL)

			UPDATE dbo.NurseLicensure
			SET status=2
			WHERE username=@UserName AND state IN (SELECT StateName FROM #ARBCBS_StateName)
			AND county IN (SELECT countyname FROM #ARBCBS_StateName)

       END
		 
IF (@FLG=3)

	BEGIN 
		IF @status IS NULL 
		SET @status=3
		  IF EXISTS (SELECT statename, CountyName FROM #ARBCBS_StateName WHERE CountyName IS NULL)

		    UPDATE dbo.NurseLicensure
			SET status = 2 
			WHERE State IN (SELECT StateName FROM #ARBCBS_StateName)
			AND County IS NULL
			AND UserName =  @UserName
			AND status = 3

	END 
	
--select * from dbo.NurseLicensure_082119 where username = 'adbrightwell' and status !=1

IF (@FLG=4)
	BEGIN 
		IF @status IS NULL 
		SET @status=2
		   IF EXISTS (SELECT CountyName FROM #ARBCBS_StateName WHERE CountyName IS NOT NULL)

			--DELETE FROM dbo.NurseLicensure_082119
			UPDATE dbo.NurseLicensure
			SET status = 1 
			WHERE username=@UserName AND state IN (SELECT StateName FROM #ARBCBS_StateName)
			AND county IN (SELECT countyname FROM #ARBCBS_StateName)
			AND status=2
	  END

IF (@FLG=4)
	BEGIN 
		IF @status IS NULL 
		SET @status=2
		   IF EXISTS (SELECT CountyName FROM #ARBCBS_StateName WHERE CountyName IS NULL)

			--DELETE FROM dbo.NurseLicensure_082119
			UPDATE dbo.NurseLicensure
			SET status = 1 
			WHERE State IN (SELECT StateName FROM #ARBCBS_StateName)
			AND County IS NULL
			AND UserName =  @UserName
			AND status = 2

	END 
--select * from dbo.NurseLicensure_082119 where username = 'adbrightwell' and state in ('UT','AR') 

END