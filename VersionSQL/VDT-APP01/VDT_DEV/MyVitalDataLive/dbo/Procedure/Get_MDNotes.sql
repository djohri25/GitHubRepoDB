/****** Object:  Procedure [dbo].[Get_MDNotes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 7/7/2009
-- Description:	Returns list of member notes provided
--	by doctors
-- Parameters:
--	@MemberID - mvd member identifier
--  @UserID   - MD user requesting the list
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDNotes]
	@MemberID varchar(20),
	@UserID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

--select @MemberID = 'CP762350', @UserID = 'sales'

	declare @temp table (ID int, mvdid varchar(20), text varchar(max), date datetime, username varchar(20), editable bit,
		firstName varchar(50), lastName varchar(50), fullName varchar(50), organization varchar(50), phone varchar(20), modifiedByType varchar(20),
		LinkedFormType varchar(50),LinkedFormID int)

	declare @sql varchar(max)

	insert into @temp (id, mvdid,text, date,username,editable,firstName,lastName,fullName,organization,phone, modifiedByType,LinkedFormType,LinkedFormID)
	select n.ID, MVDID, Note as text, dbo.ConvertUTCtoCT(DateModified) as date,
		ModifiedBy as username,
		dbo.IsNoteEditable(ModifiedBy,ModifiedByType,@UserID,'MD',Note) as Editable,
		u.FirstName,u.LastName, dbo.FullName(u.Lastname,u.FirstName,'') as fullName, u.Organization,u.Phone, modifiedByType,
		n.LinkedFormType,n.LinkedFormID
	from HPAlertNote n
		inner join MDUser u on n.ModifiedBy = u.Username
	where MVDID = @MemberID
		and n.Active = 1
		and ModifiedByType = 'MD'
	
	--select * from @temp
	
	select @sql = 'select n.ID, MVDID, Note as text, dbo.ConvertUTCtoCT(DateModified) as date,
		ModifiedBy as username,
		dbo.IsNoteEditable(ModifiedBy,ModifiedByType,''' + @UserID + ''',''' + 'MD' + ''',Note) as Editable,
		m.FirstName,m.LastName,dbo.FullName(m.Lastname,m.FirstName,''' + ''') as fullName,m.Organization,
		dbo.FormatPhone(m.Phone) as Phone, n.modifiedByType,
		 n.LinkedFormType, n.LinkedFormID
	from HPAlertNote n
		inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users u on n.ModifiedBy = u.Username
		inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership m on m.UserId = u.UserId
	where MVDID = ''' + @MemberID + '''
		and n.Active = 1
		and ModifiedByType = ''' + 'HP' + ''''
	
	insert into @temp (id, mvdid,text, date,username,editable,firstName,lastName,fullName,organization,phone,modifiedByType,LinkedFormType,LinkedFormID)
	EXEC (@sql)
		
	select id, mvdid,text, date,username,editable,firstName,lastName,fullName,organization,phone,modifiedByType,LinkedFormType,LinkedFormID
	from @temp
	order by date desc
	
END