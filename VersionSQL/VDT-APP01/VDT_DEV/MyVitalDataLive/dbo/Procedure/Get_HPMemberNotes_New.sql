/****** Object:  Procedure [dbo].[Get_HPMemberNotes_New]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HPMemberNotes_New]
@MVDID varchar(50),
@UserID varchar(50),
@ShowAll bit			-- If 0 return only notes for the current member
AS
/*

 Change History
Date		Developer           Issue# - Description
10/07/2016	Marc De Luca		Removed the format of notedate so it is back to datetime
10/29/2018	Marc De Luca		Changed and ModifiedByType = 'MD' to and ModifiedByType = 'HP'
01/29/2019  Satyajit P			Changed the username column length for #TempResult table variable from 20 - 100 reference # 1105 TFS 
02/13/2019	dpatel				Updated proc to return DateModified as is instead of hard-coded convertion to CST.
05/14/2019	dpatel				Updated proc to return only notes/documents that are not deleted.
05/20/2021	ezanelli/schisman	Added SectionCompleted and FormLocked
05/21/2021	mgrover				Added merge step for older ABCBS_MemberManagement_Form as the linked form type
20210524	Jose				Optimize SP added table hint
			Jose/Ed				Added code to thwart parameter sniffing and replace table varible with temp table
			Jose				Refactor the code: pre-populate table and use update statements
			Jose				Add ARITHABORT On
2021-06-03	Scott				Added merge step for Consult forms along with other merge steps.

exec Get_HPMemberNotes_New @MVDID='161111DEE42519C1885B',@UserId='GDASHCRAFT',@ShowAll=1
exec Get_HPMemberNotes_New @MVDID='1668459504D8CB4574B0',@UserId='JGWHALEY',@ShowAll=1

set ARITHABORT On

exec Get_HPMemberNotes_New @MVDID='161111DEE42519C1885B',@UserId='GDASHCRAFT',@ShowAll=1
--00:00:02

set ARITHABORT Off

exec Get_HPMemberNotes_New @MVDID='161111DEE42519C1885B',@UserId='GDASHCRAFT',@ShowAll=1
--00:00:44

exec Get_HPMemberNotes_New @MVDID='161111DEE42519C1885B',@UserId='GDASHCRAFT',@ShowAll=1


*/
BEGIN

SET ARITHABORT ON
SET NOCOUNT ON


----For testing purposes
--Declare
--	@MVDID varchar(50) = '161111DEE42519C1885B',
--	@UserID varchar(50) = 'GDASHCRAFT',
--	@ShowAll bit = 1			-- If 0 return only notes for the current member

       
declare @hasModifyRights bit             -- system Admins and HP admins has modify rights

declare @query varchar(1000), @querySupport varchar(1000), @adminToolUserId varchar(50),
        @adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
        @healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50),
        @hpMemberID varchar(20)

Declare 
	@v_MVDID	varchar(255) = @MVDID,
	@v_UserID	varchar(255) = @UserID;


DROP TABLE IF EXISTS #TempResult;

CREATE TABLE #TempResult (
	ID int, 
	mvdid varchar(20), 
	[text] varchar(max), 
	notedate datetime, 
	username varchar(100), 
	[ReadOnly] bit,
    [Status] varchar(50), 
	StatusID int,
    fullName varchar(50), 
	organization varchar(50), 
	phone varchar(30), 
	modifiedByType varchar(20),
    LinkedFormType varchar(50),
	LinkedFormID int, 
	LockType varchar(5), 
	IsLocked varchar(max), 
	FormInitiatedDate datetime,
	OriginalFormID int,
	FormLocked bit
)

CREATE INDEX IX_TempResult ON #TempResult( ID );


DECLARE 
	@v_linked_form_type		varchar(255) = '',
	@sql					varchar(max)


select @sql = '
	select 
		n.ID, 
		n.MVDID, 
		n.Note as text, 
		DateModified as date,
		ModifiedBy as username,
		case dbo.IsNoteEditable( ModifiedBy, ModifiedByType, ''' + @v_UserID + ''',''HP'', Note) 
			when 0 then 1
			else 0 end as [ReadOnly],
		ls.Name, alertstatusID,
		dbo.FullName(m.Lastname,m.FirstName,'''') as fullName, 
		m.Organization,
		dbo.FormatPhoneExt(m.Phone,m.PhoneExtension) as Phone, 
		modifiedByType,
		n.LinkedFormType,
		n.LinkedFormID,
		lmnf.LockingValue--,
		--f.IsLocked,
		--f.FormDate
	from HPAlertNote n (readuncommitted)
			inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users u (readuncommitted) on n.ModifiedBy = u.Username
			inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership m (readuncommitted) on m.UserId = u.UserId
			left join lookupHPMemberstatus ls (readuncommitted) on n.AlertStatusID = ls.id 
			inner join LookupCS_MemberNoteForms lmnf (readuncommitted) on n.LinkedFormType = lmnf.ProcedureName
			--left join ' + @v_linked_form_type + '_Form f (readuncommitted) on f.ID = n.LinkedFormID
	where 
		n.MVDID = ''' + @v_MVDID + ''' 
		and n.Active = 1
		and ModifiedByType = ''HP''
		and (n.IsDelete = 0 or n.IsDelete is null)
		and COALESCE(n.LinkedFormType, '''' ) <> ''''
		--and n.LinkedFormType = ''' + @v_linked_form_type + ''';';

--PRINT @sql

insert into #TempResult(
	id, 
	mvdid,
	[text], 
	notedate,
	[username],
	[ReadOnly],
	[Status],
	StatusID, 
	fullName,
	organization,
	phone,
	modifiedByType,
	LinkedFormType,
	LinkedFormID,
	LockType--,
	--IsLocked,
	--FormDate
	)
EXEC (@sql)


DECLARE form_cursor CURSOR FORWARD_ONLY FOR
SELECT DISTINCT
	LinkedFormType
FROM
	dbo.HPAlertNote (readuncommitted)
WHERE
	MVDID = @v_MVDID
	AND ISNULL( LinkedFormType, '' ) != ''
ORDER BY
	LinkedFormType

	
-- open the cursor
OPEN form_cursor;

-- get the first record; it will be ready for processing when we enter the processing loop
FETCH NEXT FROM form_cursor INTO
	@v_linked_form_type;

-- enter the processing loop
WHILE @@FETCH_STATUS = 0
BEGIN
	-- process

	---- select @sql = 'select n.ID, MVDID, Note as text, dbo.ConvertUTCtoCT(DateModified) as date,
	--select @sql = 'select n.ID, n.MVDID, Note as text, DateModified as date,
	--		ModifiedBy as username,
	--		case dbo.IsNoteEditable(ModifiedBy,ModifiedByType,''' + @v_UserID + ''',''' + 'HP' + ''',Note)
	--		when 0 then 1
	--		else 0
	--		end as ReadOnly,
	--		ls.Name, 
	--		alertstatusID,
	--		dbo.FullName(m.Lastname,m.FirstName,''' + ''') as fullName,m.Organization,
	--		dbo.FormatPhoneExt(m.Phone,m.PhoneExtension) as Phone, 
	--		n.modifiedByType,
	--		n.LinkedFormType,
	--		n.LinkedFormID, 
	--		lmnf.LockingValue,
	--		f.IsLocked,
	--		f.FormDate
	--from HPAlertNote n (readuncommitted)
	--		inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users u (readuncommitted) on n.ModifiedBy = u.Username
	--		inner join ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership m (readuncommitted) on m.UserId = u.UserId
	--		left join lookupHPMemberstatus ls (readuncommitted) on n.AlertStatusID = ls.id 
	--		inner join LookupCS_MemberNoteForms lmnf (readuncommitted) on n.LinkedFormType = lmnf.ProcedureName
	--		left join ' + @v_linked_form_type + '_Form f (readuncommitted) on f.ID = n.LinkedFormID
	--where n.MVDID = ''' + @v_MVDID + '''
	--		and n.Active = 1
	--		and ModifiedByType = ''' + 'HP' + '''
	--		and (n.IsDelete = 0 or n.IsDelete is null)
	--		and n.LinkedFormType = ''' + @v_linked_form_type + ''';';
       
	----PRINT @sql

	----INSERT INTO #TempResult(id, mvdid,[text], notedate, username, [ReadOnly], [Status], StatusID, fullName, organization,
	----						phone, modifiedByType, LinkedFormType, LinkedFormID, LockType, IsLocked, FormInitiatedDate)
	----EXEC (@sql)


	select @sql = 'update n set 
			n.FormInitiatedDate = f.FormDate,
			n.IsLocked = f.IsLocked 
		from #TempResult n
			inner join ' + @v_linked_form_type + '_Form f (readuncommitted) 
				on f.ID = n.LinkedFormID 
		where
			n.LinkedFormType = ''' + @v_linked_form_type + ''''
	       
	--PRINT @sql

	EXEC (@sql)


	-- get the next record
	FETCH NEXT FROM form_cursor INTO
		@v_linked_form_type;

END;

CLOSE form_cursor;
DEALLOCATE form_cursor;



-- Set OriginalFormId, FormInitiatedDate and FormLocked for Bariatric Form
MERGE INTO
	#TempResult d
USING (
	SELECT
		tr.ID,
		bf.ID OriginalFormID,
		bf.SectionCompleted,
		bf.FormDate FormInitiatedDate
	FROM #TempResult tr
		JOIN ABCBS_BariatricHistory_Form bfh (readuncommitted) ON bfh.ID = tr.LinkedFormID
		JOIN ABCBS_Bariatric_Form bf (readuncommitted) ON bf.ID = bfh.OriginalFormID
	WHERE
		tr.LinkedFormType = 'ABCBS_BariatricHistory'
) s
ON
	s.ID = d.ID
WHEN MATCHED THEN 
	UPDATE SET
		d.OriginalFormID = s.OriginalFormID,
		d.FormInitiatedDate = s.FormInitiatedDate,
		d.FormLocked = CASE WHEN s.SectionCompleted < 1 THEN 0 ELSE 1 END;
   
-- Set OriginalFormId, FormInitiatedDate and FormLocked for MMFHistory
MERGE INTO
	#TempResult d
USING (
	SELECT
		tr.ID,
		mmf.ID OriginalFormID,
		mmf.SectionCompleted,
		mmf.FormDate FormInitiatedDate
	FROM #TempResult tr
		JOIN ABCBS_MMFHistory_Form mmfh (readuncommitted) ON mmfh.ID = tr.LinkedFormID
		JOIN ABCBS_MemberManagement_Form mmf  (readuncommitted)ON mmf.ID = mmfh.OriginalFormID
	WHERE
		tr.LinkedFormType = 'ABCBS_MMFHistory'
	) s
ON
	s.ID = d.ID
WHEN MATCHED THEN 
	UPDATE SET
		d.OriginalFormID = s.OriginalFormID,
		d.FormInitiatedDate = s.FormInitiatedDate,
		d.FormLocked = CASE WHEN s.SectionCompleted < 3 THEN 0 ELSE 1 END;

-- Set OriginalFormId, FormInitiatedDate and FormLocked for ABCBS_MemberManagement
MERGE INTO
	#TempResult d
USING (
	SELECT
		tr.ID,
		mmf.ID OriginalFormID,
		mmf.SectionCompleted,
		mmf.FormDate FormInitiatedDate
	FROM #TempResult tr
		JOIN ABCBS_MemberManagement_Form mmf (readuncommitted) ON mmf.ID = tr.LinkedFormID
	WHERE
		tr.LinkedFormType = 'ABCBS_MemberManagement'
	) s
ON
	s.ID = d.ID
WHEN MATCHED THEN 
	UPDATE SET
		d.OriginalFormID = s.OriginalFormID,
		d.FormInitiatedDate = s.FormInitiatedDate,
		d.FormLocked = CASE WHEN s.SectionCompleted < 3 THEN 0 ELSE 1 END;

-- Set SectionCompleted and FormLocked for SW Outreach and Resource Form
MERGE INTO
	#TempResult d
USING (
	SELECT
		tr.ID,
		swo.ID OriginalFormID,
		swo.SectionCompleted,
		swo.FormDate FormInitiatedDate
	FROM #TempResult tr
		JOIN ABCBS_SWOutReachAndResourceHistory_Form swoh (readuncommitted) ON swoh.ID = tr.LinkedFormID
		JOIN ABCBS_SWOutReachAndResource_Form swo  (readuncommitted) ON swo.ID = swoh.OriginalFormID
	WHERE
		tr.LinkedFormType = 'ABCBS_SWOutReachAndResourceHistory'
	) s
ON
	s.ID = d.ID
WHEN MATCHED THEN 
	UPDATE SET
		d.OriginalFormID = s.OriginalFormID,
		d.FormInitiatedDate = s.FormInitiatedDate,
		d.FormLocked = CASE WHEN s.SectionCompleted < 1 THEN 0 ELSE 1 END;

-- Set OriginalFormId, FormInitiatedDate and FormLocked for Consult
MERGE INTO
	#TempResult d
USING (
	SELECT
		tr.ID,
		mmf.ID OriginalFormID,
		mmf.SectionCompleted,
		mmf.FormDate FormInitiatedDate
	FROM #TempResult tr
		JOIN ABCBS_MemberManagement_Form mmf (readuncommitted) ON mmf.ID = tr.LinkedFormID
	WHERE
		tr.LinkedFormType = 'Consult'
	) s
ON
	s.ID = d.ID
WHEN MATCHED THEN 
	UPDATE SET
		d.OriginalFormID = s.OriginalFormID,
		d.FormInitiatedDate = s.FormInitiatedDate,
		d.FormLocked = CASE WHEN s.SectionCompleted < 2 THEN 0 ELSE 1 END;
  
select 	
	id, 
	mvdid,
	[text], 
	notedate as [date],
	username,
	[ReadOnly],
	[Status],
	StatusID,
	fullName,
	organization,
	phone,
	modifiedByType,
	LinkedFormType,
	LinkedFormID,
	LockType,
	IsLocked,
	FormInitiatedDate,
	OriginalFormID,
	FormLocked
from 
	#TempResult
order by 
	notedate desc       

END