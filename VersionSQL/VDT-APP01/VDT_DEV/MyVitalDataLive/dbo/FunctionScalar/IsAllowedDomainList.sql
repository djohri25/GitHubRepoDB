/****** Object:  Function [dbo].[IsAllowedDomainList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/17/2009
-- Description:	Check if none of the domain provided in the list
--	exists on forbidden list
--	NOTE: the function does not validate the correctness
--	of the domain list
-- =============================================
create FUNCTION [dbo].[IsAllowedDomainList] 
(
	@EmailDomains varchar(500)		-- comma separated list of domains
)
RETURNS bit
AS
BEGIN

	DECLARE @Result bit
	declare	@TempDomainList table (data varchar(50))

	set @Result = 1
	
	if(len(isnull(@EmailDomains,'')) > 0)
	begin
		-- Parse comma separated list
		insert into @TempDomainList (data)
		select data from dbo.Split(@EmailDomains,',')
		
		if exists (select data from @TempDomainList d inner join ForbiddenEmailDomains f on replace(d.data,' ','') = f.name)
		begin
			set @Result = 0
		end
		else
		begin
			set @Result = 1
		end
	end

	RETURN @Result
END