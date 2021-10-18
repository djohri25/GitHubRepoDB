/****** Object:  Procedure [dbo].[Get_CareSpaceDocsAndNotes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CareSpaceDocsAndNotes]
(	@UserName	Varchar(60), 
	@CustomerId INT = NULL, 
	@MVDID	Varchar(30), 
	@userRole	Varchar(30) = NULL 
)
AS
-- =============================================
-- Author:		<PPetluri>
-- Create date: <06/12/2017>
-- Description:	<Cronological order of Member data>
-- Date				Name				Comments		
-- 07/07/2017		PPetluri			Fixed Duplicate issue 
-- 08/25/2017		PPetluri			Commented out the update for IsEditable not to use Users i.e, createdBy column but to go with GroupName alone since there is a minor chance for a User to switch between Groups. 
-- 02/07/2019		dpatel				Updated ambiguous reference for column - CreatedBy from HpAlertNote table.
-- 05/13/2019		dpatel				Updated proc to check IsDelete flag in Customer <> 15 condition block.
-- 09/01/2020		dpatel				Updated proc to return deleted charts too.
-- =============================================
BEGIN

--Declare @UserName	Varchar(60), @CustomerId INT , @MVDID	Varchar(30), @userRole	Varchar(30)
--Select @UserName = 'pcrouch' , @CustomerId = 15 , @MVDID = 'SB275575', @userRole	= '' -- pcrouch, dlauve, cgarza, swyrzyko, scain, lhuddleston
--Exec [Get_CareSpaceDocsAndNotes] 'executive1', 16, '1613360218401'

Declare @GroupID  int
declare @GroupName as varchar(200)

IF Object_ID('TempDB.dbo.#Temp_Users','U') is not null
Drop table #Temp_Users
Create Table #Temp_Users
(
	UserName	varchar(200)
)

IF Object_ID('TempDB.dbo.#Temp','U') is not null
Drop table #Temp
Create table #Temp
(
	ID	INT identity(1,1) not null,
	MVDID	varchar(30),
	NoteID	INT,
	CaseID	Varchar(100),
	CaseStatus	varchar(60),
	NoteDesc	Varchar(max),
	CreatedBy	varchar(100),
	CreatedDate	datetime,
	NoteTypeId	int,
	NoteType	Varchar(150),
	LinkedFormID	int,
	LinkedFormType varchar(150),
	IsEditable	bit	default (0),
	Cust_ID	int,
	SHGroup		varchar(10) NULL,
	SessionID varchar(max) NULL,
	DocType varchar(100) NULL,
	IsDeleted bit,
	Tag varchar(50)
)

BEGIN
	
	
	------ Get all data for this member
	INSERT INTO #Temp (MVDID, NoteID, CaseID,CaseStatus, NoteDesc, CreatedBy, CreatedDate, NoteTypeId, NoteType, LinkedFormID, LinkedFormType, Cust_id, SessionID,DocType,IsDeleted,Tag)
	select N1.MVDID, N1.ID as NoteId,N1.CaseID as CaseId, NULL CaseStatus, Note,N1.CreatedBy,DateCreated as CreatedDate,NoteTypeId, LC.Label NoteType, N1.LinkedFormID, N1.LinkedFormType, LC.Cust_ID, N1.SessionID,N1.DocType, ISNULL(N1.IsDelete, 0) as bit, CreatedByCompany as Tag
	from HPAlertNote N1 JOIN Link_MemberId_MVD_Ins L ON L.MVDID = N1.MVDID 
--	LEFT JOIN Lookup_Generic_Code LC ON CASE WHEN N1.LinkedFormID is not null Then 15 Else N1.NoteTypeID  END =  LC.CodeID -- changed by Mike G on 7/5/19 to support letters
	LEFT JOIN Lookup_Generic_Code LC ON N1.NoteTypeID =  LC.CodeID 	JOIN Lookup_Generic_Code_Type LCT ON LCT.CodeTypeID = LC.CodeTypeID
	WHere LCT.CodeType = 'NoteType' --and LC.Label <> 'DocumentNote' 
	AND N1.MVDID = @MVDID  
	and L.Cust_ID = @CustomerId
	--and (N1.IsDelete = 0 or N1.IsDelete is null)
	--AND C.q4c = 'Open'
	Union
	select N1.MVDID, N1.ID as NoteId,N1.CaseID as CaseId, NULL CaseStatus, Note,N1.CreatedBy,DateCreated as CreatedDate,NoteTypeId, LC.Label NoteType, N1.LinkedFormID, N1.LinkedFormType, LC.Cust_ID, N1.SessionID,N1.DocType, ISNULL(N1.IsDelete, 0) as bit, CreatedByCompany as Tag
	from HPAlertNote N1 JOIN FinalMember L ON L.MVDID = N1.MVDID 
--	LEFT JOIN Lookup_Generic_Code LC ON CASE WHEN N1.LinkedFormID is not null Then 15 Else N1.NoteTypeID  END =  LC.CodeID -- changed by Mike G on 7/5/19 to support letters
	LEFT JOIN Lookup_Generic_Code LC ON N1.NoteTypeID =  LC.CodeID 	JOIN Lookup_Generic_Code_Type LCT ON LCT.CodeTypeID = LC.CodeTypeID
	WHere LCT.CodeType = 'NoteType' --and LC.Label <> 'DocumentNote' 
	AND N1.MVDID = @MVDID  
	and L.CustID = @CustomerId
	--and (N1.IsDelete = 0 or N1.IsDelete is null)
	--AND C.q4c = 'Open'
	ORDER BY DateCreated desc

	select Distinct MVDID, NoteID, SHGroup, SessionID,DocType, CaseID,CaseStatus, NoteDesc, CreatedBy, CreatedDate, NoteTypeId, NoteType, LinkedFormID, LinkedFormType, IsEditable, IsDeleted, Tag from #Temp ORDER BY CreatedDate desc

END

END