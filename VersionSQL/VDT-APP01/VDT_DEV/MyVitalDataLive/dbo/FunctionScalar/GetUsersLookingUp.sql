/****** Object:  Function [dbo].[GetUsersLookingUp]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetUsersLookingUp]
(@Medicaid VARCHAR (50), @LookupDate DATETIME)
RETURNS VARCHAR (MAX)
AS
BEGIN
	DECLARE @UserList varchar(max), @tempLookupDate varchar(20)
	declare @temp table (name varchar(100))
	declare @DistinctTemp table (name varchar(100))

--select @Medicaid = '604671801',
--	@lookupDate = '8/27/2009'

	select @UserList = '',
		@tempLookupDate = CONVERT(varchar, dbo.ConvertCTtoUTC(@LookupDate),1)

	insert into @temp(name)
	select isnull(e.FirstName,'') + ISNULL(' ' + e.LastName,'') + ', '
	from MainInsurance i
		inner join MVD_AppRecord r on i.ICENUMBER = r.MVDID
		inner join MainEMS e on r.UserName = e.Username
	where i.Medicaid = @Medicaid and CONVERT(varchar,r.Created,1) = @tempLookupDate
		and r.Action = 'LOOKUP' and ResultCount = 1 and ResultStatus = 'SUCCESS'

	insert into @DistinctTemp
	select distinct name from @temp

	select @UserList = @UserList +  name
	from @DistinctTemp

	if(LEN(@UserList) > 0)
	begin
		set @UserList = SUBSTRING(@userList,0,len(@userList))
	end

--select @UserList

	RETURN @UserList

END