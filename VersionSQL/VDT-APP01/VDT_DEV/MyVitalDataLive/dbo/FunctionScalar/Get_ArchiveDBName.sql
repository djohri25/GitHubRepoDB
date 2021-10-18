/****** Object:  Function [dbo].[Get_ArchiveDBName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/2/2011
-- Description:	Returns the name of the MVD archive
--	database corresponding to current database
-- =============================================
CREATE FUNCTION [dbo].[Get_ArchiveDBName]()
RETURNS varchar(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ArchiveDBName varchar(50)

	select @ArchiveDBName = CASE DB_Name()
			WHEN 'MyVitalDataLive' THEN 'MyVitalDataLive_Archive'
			WHEN 'MyVitalDataDemo' THEN 'MyVitalDataDev_Archive'
			WHEN 'MyVitalDataTest1' THEN 'MyVitalDataDev_Archive'
			WHEN 'MyVitalDataTest2' THEN 'MyVitalDataDev_Archive'
			WHEN 'MyVitalDataDev' THEN 'MyVitalDataDev_Archive'
			ELSE 
			(
				''
			)
		END
	
	-- Return the result of the function
	RETURN @ArchiveDBName
END