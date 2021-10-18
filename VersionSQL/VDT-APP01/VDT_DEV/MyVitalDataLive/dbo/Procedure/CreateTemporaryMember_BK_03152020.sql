/****** Object:  Procedure [dbo].[CreateTemporaryMember_BK_03152020]    Committed by VersionSQL https://www.versionsql.com ******/

Create Proc [dbo].[CreateTemporaryMember_BK_03152020] 
@LastName varchar(50),
@FirstName varchar(50),
@Gender varchar(1),
@DOB date,
@Address1 varchar(128),
@Address2 varchar(128),
@City varchar(50),
@State varchar(2),
@Postal varchar(5),
@HomePhone varchar(10),
@Email varchar(100),
@Ethnicity varchar(50),
@MemberID varchar(30),
@EffStartDate date, 
@EffEndDate date,
--@HealthPlanEmployeeFlag varchar(1),
@CustID int,
@ReturnValue1 int output,
@ReturnValue2 varchar(30) output
as

Set NoCount On
-- Exec CreateTemporaryMember 'Jamies', 'Jonny', 'F','1965-06-28', '111 Peckham St', '','Dallas', 'TX', '75001','','','',null,'2019-02-01',NULL,16, null, null

-- Create MemberID/MVDID
Declare @MVDID varchar(30), @ID bigint

Set @MVDID= RTrim(Left(Cast(@CustID as varchar(2))+SUBSTRING(CONVERT(varchar(40), NEWID()),0,5),15)) +'TMP'

If (IsNULL(@MemberID,'') = '') 
Begin
Set  @MemberID = 'TMP'+Replace(@MVDID,'TMP','')
End

-- Insert Link
Insert Into dbo.Link_LegacyMemberId_MVD_Ins (MVDId, InsMemberId,Cust_ID, Created, Active)
Select @MVDID, @MemberID, @CustID, GetDate(), 1

-- Insert Member Info
Insert Into dbo.FinalMemberTemporary ( MVDID,MemberID, MemberLastName, MemberFirstName, Gender, DateOfBirth, Address1, Address2, City, State, Zipcode, HomePhone, Email, Ethnicity, CustID, BaseBatchID, CurrentBatchID, HealthPlanEmployeeFlag)
Select @MVDID, @MemberID, @LastName, @FirstName, @Gender, @DOB, Left(@Address1,100), Left(@Address2,50),@City,@State, @Postal, @HomePhone, @Email, Left(@Ethnicity,2), @CustID, 0, 0, 0-- @HealthPlanEmployeeFlag
	
Select @ID = RecordID
From dbo.FinalMemberTemporary
Where MVDID = @MVDID

-- Insert Insurance Info

Insert Into dbo.FinalEligibilityTemporary (MVDID, MemberID, MemberEffectiveDate,MemberTerminationDate, CustID, BaseBatchID, CurrentBatchID)
Select @MVDID, Left(@MemberID, 15),@EffStartDate, @EffEndDate, @CustID, 0, 0

Set @ReturnValue1 = @ID
Set @ReturnValue2 = @MVDID