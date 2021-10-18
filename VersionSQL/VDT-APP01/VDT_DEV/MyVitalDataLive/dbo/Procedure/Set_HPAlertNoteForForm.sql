/****** Object:  Procedure [dbo].[Set_HPAlertNoteForForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 07/12/2017	Marc De Luca	Pushed changes NoteTypeID, VALUE(15)
-- =============================================

CREATE PROCEDURE [dbo].[Set_HPAlertNoteForForm]
	@MVDID varchar(50),
	@Owner varchar(50),
	@UserType varchar(20) = 'HP',
	@Note varchar(2000),
	@FormID varchar(50),
	@MemberFormID int = null,
	@StatusID int,	
	@CaseID	varchar(100) = NULL,
	@SessionID varchar(max)=null,
	@Label varchar(100) = null, 
	@CodeType varchar(100)= null,
	@DocType varchar(100) = null,
	@DocTag varchar(50) = null,
	@Result int out

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @newNoteID INT,	@curDate DATETIME

	SELECT @curDate = GETUTCDATE()
	SET @Result = -1

	Declare @NoteTypeID  int 

/*
If @CaseID is null 
Begin
	EXECUTE [dbo].[uspCaseIdLookUp] 
	   @MVDID=@MVDID
	  ,@CaseId=@CaseId OUTPUT
End
*/
	
if @Label is null 
set @Label = 'DocumentNote'

If @CodeType is null 
set @CodeType = 'NoteType'

	Select @NoteTypeID = CodeID from Lookup_Generic_Code GC JOIN Lookup_Generic_Code_Type  GCT ON GCT.CodeTypeID = GC.CodeTypeID Where GCT.CodeType = @CodeType and GC.[Label] = @Label
	
	INSERT INTO [dbo].[HPAlertNote] 
	(
		MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,datemodified,modifiedby,ModifiedByType,SendToHP,SendToPCP,SendToNurture,
		SendToNone,NoteTypeID,LinkedFormType,LinkedFormID,CaseID, IsDelete, SessionID, DocType, CreatedByCompany
	) 
	VALUES(@MVDID, @NOTE,@StatusID,@curdate,@Owner,@UserType,@curdate,@Owner,@UserType,0,0,0,0,@NoteTypeID,@FORMID,@MEMBERFORMID, @CaseID, 0,@SessionID , @DocType, @DocTag)

	SET @Result = @@IDENTITY

END