/****** Object:  Procedure [dbo].[Get_HPMemberNotes_20201221_new]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
-- Change History
-- Date         Developer           Issue# - Description
--------------- ------------------- --------------------
-- 10/07/2016	Marc De Luca		Removed the format of notedate so it is back to datetime
-- 10/29/2018	Marc De Luca		Changed and ModifiedByType = 'MD' to and ModifiedByType = 'HP'
-- 01/29/2019   Satyajit P			Changed the username column length for @tempResult table variable from 20 - 100 reference # 1105 TFS 
-- 02/13/2019	dpatel				Updated proc to return DateModified as is instead of hard-coded convertion to CST.
-- 05/14/2019	dpatel				Updated proc to return only notes/documents that are not deleted.
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPMemberNotes]
	@MVDID varchar(50),
	@UserID varchar(50),
	@ShowAll bit			-- If 0 return only notes for the current member
AS
BEGIN
       SET NOCOUNT ON;

--select @MVDID = 'AG337323',
--     @UserID = 'sales',
--     @ShowAll = 1
       
       declare @hasModifyRights bit             -- system Admins and HP admins has modify rights

       declare @query varchar(1000), @querySupport varchar(1000), @adminToolUserId varchar(50),
              @adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
              @healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50),
              @hpMemberID varchar(20)
/*     
*/

       declare @tempResult table (ID int, mvdid varchar(20), text varchar(max), notedate datetime, username varchar(100), ReadOnly bit,
              Status varchar(50), StatusID int,
              fullName varchar(50), organization varchar(50), phone varchar(30), modifiedByType varchar(20),
              LinkedFormType varchar(50),LinkedFormID int, LockType varchar(5), IsLocked varchar(max), FormInitiatedDate datetime
       )

       declare @sql varchar(max)

/*     
*/

	DECLARE @v_linked_form_type varchar(255);

	DECLARE form_cursor CURSOR FOR
	SELECT
	DISTINCT
	LinkedFormType
	FROM
	HPAlertNote (readuncommitted)
	WHERE
	MVDID = @MVDID
	AND ISNULL( LinkedFormType, '' ) != ''
	ORDER BY
	1;

	   select @sql = 'select n.ID, n.MVDID, n.Note as text, 
			  DateModified as date,
              ModifiedBy as username,
              case dbo.IsNoteEditable(ModifiedBy,ModifiedByType,''' + @UserID + ''',''' + 'HP' + ''',Note)
              when 0 then 1
              else 0
              end as ReadOnly,
              ls.Name, alertstatusID,
              dbo.FullName(u.Lastname,u.FirstName,'''') as fullName, u.Organization,u.Phone, modifiedByType,n.LinkedFormType,n.LinkedFormID,
			  lmnf.LockingValue,
			  f.IsLocked,
			  f.FormDate
       from HPAlertNote n (readuncommitted)
              left join MDUser u on n.ModifiedBy = u.Username
              left join lookupHPMemberstatus ls on n.AlertStatusID = ls.id 
			  left join LookupCS_MemberNoteForms lmnf on n.LinkedFormType = lmnf.ProcedureName
			  left join ' + @v_linked_form_type + '_Form f
			  on f.ID = n.LinkedFormID
       where n.MVDID = ''' + @MVDID + '''
              and n.Active = 1
              and ModifiedByType = ''' + 'HP' + '''
			  and (n.IsDelete = 0 or n.IsDelete is null)
			  and n.LinkedFormType = ''' + @v_linked_form_type + ''';';

       --insert into @tempResult(id, mvdid,text, notedate,username,ReadOnly,Status,StatusID, fullName,organization,phone,modifiedByType,LinkedFormType,LinkedFormID,LockType,IsLocked,FormDate)
       --EXEC (@sql)


	
-- open the cursor
	OPEN form_cursor;
-- get the first record; it will be ready for processing when we enter the processing loop
	FETCH NEXT FROM form_cursor INTO
		@v_linked_form_type;

-- enter the processing loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
-- process
       -- select @sql = 'select n.ID, MVDID, Note as text, dbo.ConvertUTCtoCT(DateModified) as date,
	   select @sql = 'select n.ID, n.MVDID, Note as text, DateModified as date,
              ModifiedBy as username,
              case dbo.IsNoteEditable(ModifiedBy,ModifiedByType,''' + @UserID + ''',''' + 'HP' + ''',Note)
              when 0 then 1
              else 0
              end as ReadOnly,
              ls.Name, alertstatusID,
              dbo.FullName(m.Lastname,m.FirstName,''' + ''') as fullName,m.Organization,
              dbo.FormatPhoneExt(m.Phone,m.PhoneExtension) as Phone, n.modifiedByType,n.LinkedFormType,n.LinkedFormID, 
			  lmnf.LockingValue,
			  f.IsLocked,
			  f.FormDate
       from HPAlertNote n (readuncommitted)
              inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users u on n.ModifiedBy = u.Username
              inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership m on m.UserId = u.UserId
              left join lookupHPMemberstatus ls on n.AlertStatusID = ls.id 
			  inner join LookupCS_MemberNoteForms lmnf on n.LinkedFormType = lmnf.ProcedureName
			  left join ' + @v_linked_form_type + '_Form f
			  on f.ID = n.LinkedFormID
       where n.MVDID = ''' + @MVDID + '''
              and n.Active = 1
              and ModifiedByType = ''' + 'HP' + '''
			  and (n.IsDelete = 0 or n.IsDelete is null)
			  and n.LinkedFormType = ''' + @v_linked_form_type + ''';';
       
       insert into @tempResult(id, mvdid,text, notedate,username,ReadOnly,Status,StatusID, fullName,organization,phone,modifiedByType,LinkedFormType,LinkedFormID,LockType,IsLocked, FormInitiatedDate)
       EXEC (@sql)
 -- get the next record
		FETCH NEXT FROM form_cursor INTO
			@v_linked_form_type;

	END;
	CLOSE form_cursor;
	DEALLOCATE form_cursor;

       select id, mvdid,text, notedate as date,username,ReadOnly,Status,StatusID,fullName,organization,phone,modifiedByType,LinkedFormType,LinkedFormID,LockType,IsLocked,FormInitiatedDate
       from @tempResult
       order by notedate desc
       

END