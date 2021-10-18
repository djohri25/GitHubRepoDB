/****** Object:  Procedure [dbo].[Populate_Final_HEDIS_Member]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Populate_Final_HEDIS_Member] (@CustID int)

as

	declare @VisitCountDateRange datetime, @MonthID char(6)
	select @VisitCountDateRange = dateadd(mm,-6,getdate())


	declare
	@MVDID varchar(50) ,
	@MemberID varchar(50) ,
	@IsTestDue int ,
	@TestID int ,
	@DoctorUserName varchar(50) ,
	@PCP_NPI varchar(50) ,
	@PCP_TIN varchar(50) ,
	@TestStatusID int ,
	@StatusIDSaveDate datetime ,
	@StatusUpdatedBy varchar(50) ,
	@MemberFirstName varchar(50) ,
	@MemberLastName varchar(50) ,
	@HasAsthma char(1) ,
	@HasDiabetes char(1) ,
	@RemindInDays int ,
	@ERVisitCount int ,
	@NoteCount int,
	@ID int 


Create table #Final_HEDIS_Member(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](50) NULL,
	[MemberID] [varchar](50) NULL,
	[IsTestDue] [int] NULL,
	[TestID] [int] NULL,
	[DoctorUserName] [varchar](50) NULL,
	[CustID] [int] NULL,
	[PCP_NPI] [varchar](50) NULL,
	[PCP_TIN] [varchar](50) NULL,
	[TestStatusID] [int] NULL,
	[StatusIDSaveDate] [datetime] NULL,
	[StatusUpdatedBy] [varchar](50) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[HasAsthma] [char](1) NULL,
	[HasDiabetes] [char](1) NULL,
	[RemindInDays] [int] NULL,
	[ERVisitCount] [int] NULL,
	[NoteCount] [int] NULL)



Select @MonthID = convert(varchar,datepart(month,getdate()))


If (len(@MonthID )= 1)
BEGIN
	Select @MonthID = convert(char(4),datepart(Year,getdate()))+ '0' + convert(varchar,@MonthID)
END
ELSE
BEGIN
	Select @MonthID = convert(char(4),datepart(Year,getdate()))+ convert(varchar,@MonthID)
END


if exists(select MonthID from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member] 
	where MonthID = @MONTHID and CustID = @CustID )

BEGIN


Delete [Final_HEDIS_Member]
where  CustID = @CustID
and memberid not in 
	(select memberid from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member] 
		where MonthID = @MONTHID and CustID = @CustID)






INSERT INTO #Final_HEDIS_Member
           ([MVDID]
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
		   ,HasAsthma
		   ,HasDiabetes
		   ,RemindInDays
		   ,ERVisitCount
		   ,NoteCount)
     
		select 
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
		   	,	case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = m.MVDId and con.CodeFirst3 = '493') 
				when 'Y' then 'Y'
				else 'N'
				end as HasAsthma,	 
				case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = m.MVDId and con.CodeFirst3 = '250') 
				when 'Y' then 'Y'
				else 'N'
				end	as HasDiabetes
				,isnull((select top 1 r.DaysCount from MainToDoHEDIS_RemindIn r where r.MVDID = m.mvdid and r.TestID = m.testid),'') as RemindInDays,
				(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = m.mvdid and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount,
				(SELECT COUNT(ID) FROM MD_Note n where n.MvdID = m.mvdid and n.ModifyDate > dateadd(dd,-14,GETDATE()))  as NoteCount
		   from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_HEDIS_Member] m
		   where MonthID = @MONTHID and CustID = @CustID

		   




	Create table #Temp (ID int identity(1,1), MVDID varchar(50),TestStatusID int, StatusIDSaveDate datetime, TESTID int)

	Insert #Temp (MVDID,TestStatusID, StatusIDSaveDate, TestID)
	select MVDID,TestStatusID, StatusIDSaveDate, TESTID  from [dbo].[MDUser_Member] where TestStatusID is not null
	and custid = @CustID
	order by statusIDSavedate asc




	while exists (select * from #temp)
	BEGIN

		Select @ID = ID,@MVDID = MVDID,@TestStatusID = TestStatusID, @StatusIDSaveDate = StatusIDSaveDate, @TESTID = TESTID   from #temp

		Update [Final_HEDIS_Member]
		Set TestStatusID = @TestStatusID, StatusIDSaveDate = @StatusIDSaveDate
		where mvdid = @MVDID and TESTID = @TESTID

		Delete #temp
		where ID = @ID

	END





END