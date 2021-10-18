/****** Object:  Function [dbo].[Get_DispensingEventCount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Get_DispensingEventCount]
(
	@NDC varchar(50),
	@DaysSupply int
)
RETURNS int
AS
BEGIN
	DECLARE @DispensingEventCount int

	set @DispensingEventCount = 1
	
	if (@DaysSupply > 30 and exists(select ID from Link_HEDIS_Medication where ndc_code = @NDC and route = 'oral'))
	begin
		select @DispensingEventCount = @DaysSupply/30
	end

	RETURN @DispensingEventCount
END