/****** Object:  Procedure [dbo].[MergeMembersOnID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 05/05/2019
-- MODIFIED: 
-- Description:	Merge temp Member to actual member
-- Execution: --exec dbo.MergeMembersOnID  'TMP10MT306786', '611925757','2003-02-05 00:00:00', 'Member', 'Temp', null, 0, null, 10, 'rcheruku'
  --exec dbo.MergeMembersOnID  'TMP10TT831004', 'TMPRC921878','2019-04-17 00:00:00', 'test', 'test', null, 0, null, 10, 'rcheruku'

-- =============================================

--select * from Link_MemberId_MVD_Ins where Cust_ID=10 and InsMemberId ='611925757'
--select * from Link_MemberId_MVD_Ins where Cust_ID=10 and InsMemberId ='TMP10MT306786'
--select * from MainPersonalDetails where ICENUMBER ='10AA059583'
--select * from MainPersonalDetails where  ICENUMBER ='10MT306786'
--select * from MergeMembersOnIDLog order by id desc 



CREATE Procedure [dbo].[MergeMembersOnID] 
(  
@TempMemberID varchar(30),
@PermMemberID varchar(30),
@Dob smalldatetime=null, 
@FirstName Varchar(50)=null,
@LastName Varchar(50)=null,
@SSN Varchar(12)=null,
@IsMatched bit, -- 0-No Match, 1-Match
@ProductID int =null,
@CustID int,
@UserName varchar(100))

AS BEGIN 

set nocount on

declare @TempMVDID varchar(30), @PermMVDID varchar(30), @IsMerged bit=0

select @TempMVDID=mvdid  from Link_MemberId_MVD_Ins where insmemberid=@TempMemberID and Cust_ID=@CustID
select @PermMVDID=mvdid  from Link_MemberId_MVD_Ins where insmemberid=@PermMemberID and Cust_ID=@CustID

if @FirstName is null 
select @FirstName= firstname from MainPersonalDetails where ICENUMBER=@TempMVDID

if @LastName is null 
select @LastName= LastName from MainPersonalDetails where ICENUMBER=@TempMVDID

if @SSN is null 
select @SSN= ssn from MainPersonalDetails where ICENUMBER=@TempMVDID

if @Dob is null 
select @Dob= dob from MainPersonalDetails where ICENUMBER=@TempMVDID



IF EXISTS (select 1 from MainPersonalDetails where ICENUMBER=@PermMVDID )

	BEGIN 
				IF EXISTS (select 1 from MainPersonalDetails where ICENUMBER=@TempMVDID )
					
					BEGIN
						DELETE FROM MainPersonalDetails where ICENUMBER=@TempMVDID

						UPDATE Link_MemberId_MVD_Ins 
						SET Active=0,
							IsArchived=1
						WHERE MVDId=@TempMVDID and InsMemberId=@TempMemberID



			set @IsMerged=1

						INSERT INTO MergeMembersOnIDLog 
					  ([TempID]
					  ,[MemberID]
					  ,[TempMVDIDID]
					  ,[PermMVDIDID]
					  ,[IsMatched]
					  ,[IsMerged]
					  ,[CreatedDT]
					  ,[CreatedBy])

	  select @TempMemberID, @PermMemberID, @TempMVDID, @PermMVDID,@IsMatched, @IsMerged, GETUTCDATE(),@UserName

					END 

	END 

END 