/****** Object:  Procedure [dbo].[Upd_HPMemberUpdater]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/27/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Upd_HPMemberUpdater]
	@MVDID varchar(50),
	@UpdaterUsername varchar(50),	-- Username of one of the mvd support site users
	@StatusID int = null				
AS
BEGIN
	SET NOCOUNT ON;

--select @UpdaterUsername = 'qa6'

	declare @sql varchar(1000),@UpdaterFullName varchar(100), @ContactedStatusID int, @curDate datetime
	declare @temp table(firstname varchar(50), lastname varchar(50))
	
	select @curDate = GETUTCDATE()
	
	select @sql = 'select m.FirstName,m.LastName 
	from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users u
		inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership m on u.UserId = m.UserId
	where u.UserName = ''' + @UpdaterUsername + ''''	
	
	insert into @temp
	EXEC (@sql)
	
	if exists (select top 1 firstname from @temp)
	begin
		select top 1 @updaterFullName = dbo.FullName(lastName, firstName,'')
		from @temp

		update MemberDiagnosisSummary 
			set ModifiedBy = @UpdaterUsername, 
				ModifiedByName = @updaterFullName, 
				modifyDate = @curDate
		where MVDID = @MVDID
		
		select @ContactedStatusID = ID
		from dbo.LookupHPMemberStatus
		where name = 'Contacted'
		
		if(ISNULL(@StatusID,'') = @ContactedStatusID)
		begin
			update MemberDiagnosisSummary 
				set LastContactBy = @UpdaterUsername, 
					LastContactByName = @updaterFullName, 
					LastContactDate = @curDate
			where MVDID = @MVDID
		end
	end
END