/****** Object:  Function [dbo].[Get_InsuranceList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Get concatinated list of insurance names and effective and termination dates
-- =============================================
CREATE FUNCTION [dbo].[Get_InsuranceList]
(
	@mvdid varchar(50)
)
RETURNS varchar(max)
AS
BEGIN
	declare @result varchar(max)

	select @result = ''
	
	select @result = @result +isnull( Name,'') +'   ' + isnull(medicaid,'') +  ' : ' + isnull(CONVERT(varchar,EffectiveDate,101),'') + ' - ' + isnull(CONVERT(varchar,TerminationDate,101),'') + ', ' 
	from MainInsurance
	where ICENUMBER = @mvdid

	if(isnull(@result,'') <> '')
	begin
		set @result = substring(@result,0,len(@result))
	end

	RETURN @result

END