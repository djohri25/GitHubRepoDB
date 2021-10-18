/****** Object:  Function [dbo].[SplitStringVal]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[SplitStringVal](@text varchar(8000), @delimiter varchar(20) = ' ')
RETURNS 	@Strings TABLE 		
(   POSITION int IDENTITY PRIMARY KEY,
		VALUE      varchar(8000)   )
AS

/*******************************************************************************
 Description : This function will handle comma separated  values
06/18/2015     : Priya   
Declare @val  VARCHAR(25)
SET     @val  =   'Lights,Screws,Lamps,COILS,LIFTS,'
SELECT Value  FROM dbo.[SplitString]( @val,',')

11/4		: Sunil 
Modifications to handle large varchar columns
********************************************************************************/
BEGIN
DECLARE @index int 
	SET @index = -1 

	WHILE (LEN(@text) > 0) 

	  BEGIN  
    		SET @index = CHARINDEX(@delimiter , @text)  
    		IF (@index = 0) AND (LEN(@text) > 0)  
      BEGIN   
	        INSERT INTO @Strings VALUES (@text)
       BREAK  
      END  

    IF (@index > 1)  

	      BEGIN   

        INSERT INTO @Strings VALUES (LEFT(@text, @index - 1))   
	        SET @text = RIGHT(@text, (LEN(@text) - @index))  
      	END  
    ELSE 
	      SET @text = RIGHT(@text, (LEN(@text) - @index)) 
    	END
  RETURN
END