/****** Object:  Procedure [dbo].[MainCarePlanMemberIndex_Update_BK_06112020]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		nelanwer
-- Create date: 05/14/2019
-- Modified Date : 07/10/2019, Spaitereddy
-- Description:	<Updates the member care plan index
-- =============================================
Create PROCEDURE [dbo].[MainCarePlanMemberIndex_Update_BK_06112020]
	-- Add the parameters for the stored procedure here
	@UpdatedDate DATETIME,
	@UpdatedBy NVARCHAR(50),
	@CarePlanID INT,
	@SessionID varchar(1000),
	@message varchar(100)


 --HPAlertNote that user “X” has updated the careplan. This is where it get’s tricky. 
 --Before inserting this record, we should check to see that there is not already a record on file 
 --with the same sessionID and NoteType of “CarePlan”

 --select top 5 * from  HPAlertNote  --is not null order by id desc 
 --select * from Lookup_Generic_Code
 --select * from  Lookup_Generic_Code_Type


AS
BEGIN

Declare 
   @MVDID varchar(50)
  ,@Owner varchar(100)
  ,@Note varchar(2000)='Care Plan ' + @message
  ,@FormName varchar(50) = null
  ,@UserType varchar(2)='HP'
  ,@Result bigint
  ,@Label varchar(100) = 'CarePlan'
  ,@CodeType varchar(100)= 'NoteType'
  ,@NoteTypeID int 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Update statements for procedure here
	UPDATE MainCarePlanMemberIndex
	SET 
		UpdatedDate=@UpdatedDate,
		UpdatedBy=@UpdatedBy
	WHERE 
		CarePlanID=@CarePlanID

Select @NoteTypeID = CodeID from Lookup_Generic_Code GC JOIN Lookup_Generic_Code_Type  GCT 
ON GCT.CodeTypeID = GC.CodeTypeID Where GCT.CodeType = @CodeType and GC.[Label] = @Label

select @mvdid=mvdid  from MainCarePlanMemberIndex where CarePlanID=@CarePlanID

if not exists (select top 1 1 from HPAlertNote where SessionID=@SessionID and NoteTypeID=@NoteTypeID )

Begin 

Set @Owner=@UpdatedBy



--EXECUTE [dbo].[Set_HPAlertNoteForForm] 
--   @MVDID=@mvdid
--  ,@Owner=@Owner
--  ,@UserType=@UserType
--  ,@Note=@Note
--  ,@FormID=@FormName
--  ,@MemberFormID=@CarePlanID
--  ,@StatusID=0
--  ,@CaseID=null
--  ,@Label=@Label
--  ,@CodeType=@CodeType
--  ,@sessionID=@sessionID
--  ,@Result=@Result OUTPUT


begin try
EXECUTE [dbo].[Set_HPAlertNoteForForm] 
   @MVDID=@mvdid
  ,@Owner=@Owner
  ,@UserType=@UserType
  ,@Note=@Note
  ,@FormID=''
  ,@MemberFormID=0
  ,@StatusID=0
  ,@CaseID=null
  ,@Label=@Label
  ,@CodeType=@CodeType
  ,@sessionID=@sessionID
  ,@Result=@Result OUTPUT
end try
begin catch
end catch

End 

END