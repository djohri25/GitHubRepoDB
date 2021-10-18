/****** Object:  Function [dbo].[IsValidEMSEmail]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/15/2009
-- Description:	Check if email address provided
--	by EMS user meets the email domain restriction
--	specified by the hostpital the ems works for
--	NOTE: the function does not validate the correctness
--	of the email
-- =============================================
CREATE FUNCTION [dbo].[IsValidEMSEmail] 
(
	@EmsEmail varchar(50),
	@CompanyID int = null 
)
RETURNS bit
AS
BEGIN

	DECLARE @Result bit,
		@EmsEmailDomain varchar(50),
		@DomainList varchar(500)
	declare	@HospDomainList table (data varchar(50))

	set @Result = 1
	
	if(len(isnull(@EmsEmail,'')) = 0 OR len(isnull(@CompanyID,'')) = 0)
	begin
		set @Result = 0
	end
	else
	begin
		-- Get email domain
		set @EmsEmailDomain = substring(@EmsEmail, charindex('@', @EmsEmail) + 1, len(@EmsEmail) - charindex('@', @EmsEmail))

		select @DomainList = RestrictedEmailDomains from MainEmsHospital where ID = @CompanyID
		
		if(len(isnull(@DomainList,'')) > 0)
		begin
			-- DomainList contains comma separated list of allowed domains
			insert into @HospDomainList (data)
			select data from dbo.Split(@DomainList,',')
			
			if exists (select data from @HospDomainList where replace(data,' ','') = @EmsEmailDomain)
			begin
				set @Result = 1 
			end
			else
			begin
				set @Result = 0
			end
		end
	end

	RETURN @Result
END