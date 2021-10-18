/****** Object:  Procedure [dbo].[Get_Procedure_Description]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/11/2009
-- Description:	Get procedure description based on
--	national standard code: HCPCS and CPT
-- =============================================
CREATE Procedure [dbo].[Get_Procedure_Description]  
( 
	@OriginalCode varchar(50), 
	@Description varchar(400) output, 
	@Type varchar(50) output,
	@CodingSystem varchar(50) output 
)
As
SET NOCOUNT ON
-- TODO: work on the Type
select @Type = '',
	@CodingSystem = '',
	@Description = ''

-- Search HCPCS 
Select @Description = RTRIM(AbbreviatedDescription)
from LookupHCPCS where code = @OriginalCode

-- If not found, search CPT
if( len(isnull(@Description,'')) = 0)
begin
	Select @Description = left(RTRIM(Description1) + 
			case isnull(Description2,'')	
				when '' then ''
				else ': ' + RTRIM(Description2)
			end 
		, 250)  
	from LookupCPT where code = @OriginalCode	

	if(len(isnull(@Description,'')) > 0)
	begin
		set @CodingSystem = 'CPT'
	end
end
else
begin
	-- Found in HCPCS table
	set @CodingSystem = 'HCPCS'
end

if( len(isnull(@Description,'')) = 0)
begin
	select @Description = [Description],
		@CodingSystem = [CodingSystem]
	from [dbo].[LookupUserDefProcedure]
	where [code] = @OriginalCode
end

-- DJS 03/07/2016
if( len(isnull(@Description,'')) = 0)
begin
	select @Description = [ImmunName],
		@CodingSystem = 'CPT'
	from [dbo].[LookupImmunizationCPT]
	where [CPTCode] = @OriginalCode
end