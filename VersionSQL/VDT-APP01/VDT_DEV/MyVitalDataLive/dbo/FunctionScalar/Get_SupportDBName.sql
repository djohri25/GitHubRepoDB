/****** Object:  Function [dbo].[Get_SupportDBName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/4/2009
-- Description:	Returns the name of the MVD support
--	database corresponding to current database
-- =============================================
CREATE FUNCTION [dbo].[Get_SupportDBName]()
RETURNS varchar(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @SupportDBName varchar(50)

	select @SupportDBName = CASE DB_Name()
			WHEN 'MyVitalDataLive' THEN 'MVDSupportLive'
			WHEN 'MyVitalDataLive_New' THEN 'MVDSupportLive'
			WHEN 'MyVitalDataDemo_BK_From_Live' THEN 'MVDSupportDemo_BK_From_Live'
			WHEN 'MyVitalDataDemo' THEN 'MVDSupportDemo'
			WHEN 'MyVitalDataTest1' THEN 'MVDSupportTest1'
			WHEN 'MyVitalDataTest2' THEN 'MVDSupportTest2'
			WHEN 'MyVitalDataDev' THEN 'MVDSupportDev'
			WHEN 'MyVitalDataUAT' THEN 'MVDSupportUAT'
			ELSE 
			(
				''
			)
		END
	
	-- Return the result of the function
	RETURN @SupportDBName
END