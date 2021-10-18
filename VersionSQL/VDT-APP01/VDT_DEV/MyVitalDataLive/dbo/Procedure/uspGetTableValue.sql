/****** Object:  Procedure [dbo].[uspGetTableValue]    Committed by VersionSQL https://www.versionsql.com ******/

--=====================================================================  
-- Author:      MGrover
-- Create date: 08/03/2019
-- MODIFIED: 
-- Description: Retrive a value from latest of one form / table for use on another form 
-- Execution: exec [dbo].[uspGetTableValue] 'FinalMember', 'DateOfBirth', 16,'16886962EDE2', @RetVal OUTPUT
--=====================================================================  



CREATE PROCEDURE [dbo].[uspGetTableValue] (
	@SourceTable Nvarchar(100)
	,@SourceColumn Nvarchar(100)
	,@CustomerID int
	,@MVDID Nvarchar(50)
)

as begin 
	
	Set nocount on;
	
	-- create query string
	declare @sql1 varchar(max)

	if (@SourceTable = 'FinalMember' or @SourceTable = 'HEP_Control')
	begin
		set @sql1 = 'SELECT TOP 1 ' + @SourceColumn + ' FROM ' + @SourceTable + ' WHERE MVDID = ''' + @MVDID + ''' ORDER BY RecordID DESC'
	end
	else
	begin
		set @sql1 = 'SELECT TOP 1 ' + @SourceColumn + ' FROM ' + @SourceTable + ' WHERE MVDID = ''' + @MVDID + ''' ORDER BY ID DESC'
	end

	EXEC (@sql1)

end 