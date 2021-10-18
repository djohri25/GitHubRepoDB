/****** Object:  Function [dbo].[Get_EmailPrefix]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Get indicator which system the email 
--	was sent from 
-- =============================================
CREATE FUNCTION [dbo].[Get_EmailPrefix] 
(	
)
RETURNS varchar(100)
AS
BEGIN
	declare @dbname varchar(50), @prefix varchar(50)

	set @dbname = db_name()

	if(@dbname = 'MyVitalDataDemo')
	begin
		set @prefix = 'DEMO: '		
	end
	else if(@dbname = 'MyVitalDataTest1')
	begin
		set @prefix = 'TEST_1 TEST: '		
	end
	else if(@dbname = 'MyVitalDataTest2')
	begin
		set @prefix = 'TEST_2 TEST: '		
	end
	else if(@dbname = 'MyVitalDataDev')
	begin
		set @prefix = 'DEV TEST: '		
	end

	RETURN @prefix

END