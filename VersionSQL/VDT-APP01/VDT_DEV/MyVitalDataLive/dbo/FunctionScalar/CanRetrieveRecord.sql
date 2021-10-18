/****** Object:  Function [dbo].[CanRetrieveRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/10/2009
-- Description:	Check if the user is health plan member
--	 and if that's the case check if the insurance is not expired.
--	 Return False when insurance is expired. Otherwise return true
-- =============================================
CREATE FUNCTION [dbo].[CanRetrieveRecord]
(
	@MVDId varchar(20)
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit, @hpCustID int, @InsName varchar(100), @InsTermination smalldatetime, @IsArchived bit

	select @Result = '1',
		@hpCustID = 0,
		@isArchived = 0

	-- Get insurance name
	select @InsName = c.name,
		@isArchived = mi.IsArchived
	from dbo.Link_MemberId_MVD_Ins mi
		inner join HPCustomer c on mi.cust_id = c.cust_id
	where mi.mvdid = @mvdid

	if(len(isnull(@InsName,'')) >  0)
	begin
		select @InsTermination = terminationdate
		from MainInsurance 
		where icenumber = @mvdid and name = @InsName

		-- compare only date part
		-- Allow 90 days past expiration date because of possible delayed update from Health Plan 
		if( @IsArchived = 1 OR ( @InsTermination is not null and @InsTermination < convert(datetime,convert(varchar,dateadd(DD,-90, getdate()),10))))
		begin
			set @Result = '0'
		end
	end

	RETURN @Result
END