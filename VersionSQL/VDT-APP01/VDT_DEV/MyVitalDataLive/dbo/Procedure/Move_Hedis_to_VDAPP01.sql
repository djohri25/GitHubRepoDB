/****** Object:  Procedure [dbo].[Move_Hedis_to_VDAPP01]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Move_Hedis_to_VDAPP01] @CustID int

As

declare @MonthID char(6)

select @MonthID = max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_ALLMember]
where custid = @CustID

-- 
-- MOVED TO _All_2015_Predictive_HEDIS
-- 
--delete [dbo].[Final_ALLMember] where custid = @custid

--insert [dbo].[Final_ALLMember]

--(ID,[mvdid]
--           ,[MemberID]
--           ,[DOB]
--           ,[HasAsthma]
--           ,[HasDiabetes]
--           ,[CustID]
--           ,[CreateDate]
--           ,[TIN]
--           ,[NPI]
--           ,[Service_Location_ID]
--           ,[PCPID]
--           ,[LOB]
--           ,[MonthID]
--           ,[TestLookupID]
--           ,[TestStatusID]
--           ,[StatusIDSaveDate]
--           ,[StatusUpdatedBy]
--           ,[MemberFirstName]
--           ,[MemberLastName]
--           ,[ERVisitCount]
--           ,[TestList])

--select ID, [mvdid]
--           ,[MemberID]
--           ,[DOB]
--           ,[HasAsthma]
--           ,[HasDiabetes]
--           ,[CustID]
--           ,[CreateDate]
--           ,[TIN]
--           ,[NPI]
--           ,[Service_Location_ID]
--           ,[PCPID]
--           ,[LOB]
--           ,[MonthID]
--           ,[TestLookupID]
--           ,[TestStatusID]
--           ,[StatusIDSaveDate]
--           ,[StatusUpdatedBy]
--           ,[MemberFirstName]
--           ,[MemberLastName]
--           ,[ERVisitCount]
--           ,[TestList]
--from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_ALLMember]
--where custid = @CustID and MonthID = @MonthID




Create table #TempTESTS (TestID int)
Insert #TempTESTS
Select distinct TestID from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member]
where custid = @CustID and TESTID is not null

Declare @TESTID int

While exists (Select * from #TempTESTS)
BEGIN

	Select top 1 @TESTID = TESTID from #TempTESTS


	select @MonthID = max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member]
	where custid = @CustID 
	and testID = @TESTID



	delete [dbo].[Final_HEDIS_Member] where [CustID] = @custid and  testID = @TESTID

	insert  [dbo].[Final_HEDIS_Member]
         (
		 [MVDID]
           ,[MemberID]
           ,[IsTestDue]
           ,[TestID]
           ,[DoctorUserName]
           ,[CustID]
           ,[PCP_NPI]
           ,[PCP_TIN]
           ,[TestStatusID]
           ,[StatusIDSaveDate]
           ,[StatusUpdatedBy]
           ,[MemberFirstName]
           ,[MemberLastName]
          -- ,[HasAsthma]
          -- ,[HasDiabetes]
          -- ,[RemindInDays]
          -- ,[ERVisitCount]
          -- ,[NoteCount]
		   ,monthid
		   ,W15_VisitCount)

		select mvdid, [MemberID],  IsTestDue, TestID,  DoctorUserName, CustID, PCP_NPI,  PCP_TIN, [TestStatusID], [StatusIDSaveDate], StatusUpdatedBy, 
                         MemberFirstName, MemberLastName, MonthID, VisitCount
		  from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member]
		  where custid = @CustID and MonthID = @MonthID and testID = @TESTID
		 

	delete #TempTESTS where testid = @TestID


END




delete [dbo].[Final_HEDIS_Member_FULL] where [CustID] = @custid

insert  [dbo].[Final_HEDIS_Member_FULL]
         (
		 [MVDID]
           ,[MemberID]
           ,[IsTestDue]
           ,[TestID]
           ,[DoctorUserName]
           ,[CustID]
           ,[PCP_NPI]
           ,[PCP_TIN]
           ,[TestStatusID]
           ,[StatusIDSaveDate]
           ,[StatusUpdatedBy]
           ,[MemberFirstName]
           ,[MemberLastName]
          -- ,[HasAsthma]
          -- ,[HasDiabetes]
          -- ,[RemindInDays]
          -- ,[ERVisitCount]
          -- ,[NoteCount]
		   ,monthid
		   ,W15_VisitCount)

select        mvdid, [MemberID],  IsTestDue, TestID,  DoctorUserName, CustID, PCP_NPI,  PCP_TIN, [TestStatusID], [StatusIDSaveDate], StatusUpdatedBy, 
                         MemberFirstName, MemberLastName, MonthID, VisitCount
		  from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member]
		  where custid = @CustID --and MonthID = @MonthID