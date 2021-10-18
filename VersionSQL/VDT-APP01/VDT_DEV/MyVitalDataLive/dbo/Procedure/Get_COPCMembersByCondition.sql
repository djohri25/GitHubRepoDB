/****** Object:  Procedure [dbo].[Get_COPCMembersByCondition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/4/2012
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_COPCMembersByCondition]
	@Condition varchar(50),
	@CustID int,
	@TotalResultCount int output
AS
BEGIN
	SET NOCOUNT ON;

--select @Condition ='1',
--	@CustID ='10'
	
	declare @selectedParentHPID int, @mvdid varchar(20), @lastERVisit datetime, @id int,
		@AsthmaLookupID int, @W15LookupID int, @W15HedisLookupID int
		
    
	declare @result table (ID int,InsMemberID varchar(20),CustID varchar(20),MVDID varchar(20)
		,FirstName varchar(50),LastName varchar(50),MemberName varchar(50),StatusID varchar(20)
		,Status	varchar(50),PCPVisitCount int,ERVisitCount int ,PCPVisitCountSinceContact int
		,ERVisitCountSinceContact int,LastContactDate varchar(20),ModifyDate varchar(20)
		,ModifiedByName varchar(100),LastContactByName varchar(100), LastERVisit datetime,
		isProcessed bit default(0))

	select @selectedParentHPID = dbo.Get_HPParentCustomerID(@CustID)

    select @AsthmaLookupID = ID
    from LookupDRMyPatientsDisease 
    where Abbreviation = 'AST'
    
    select @W15LookupID = ID
    from LookupDRMyPatientsDisease 
    where Abbreviation = 'W15'

	select @W15HedisLookupID = ID
	from LookupHedis
	where Abbreviation = 'W15'

	insert into @result(ID,InsMemberID,CustID,MVDID,FirstName,LastName,MemberName,StatusID      
      ,Status,PCPVisitCount,ERVisitCount,PCPVisitCountSinceContact,ERVisitCountSinceContact
      ,LastContactDate,ModifyDate,ModifiedByName,LastContactByName,LastERVisit)
	select m.ID
      ,InsMemberID
      ,CustID
      ,MVDID
      ,FirstName
      ,LastName
      ,dbo.FullName(LastName,FirstName,'') as MemberName
      ,StatusID      
      ,s.Name as Status	
      ,PCPVisitCount
      ,ERVisitCount
      ,PCPVisitCountSinceContact
      ,ERVisitCountSinceContact
      ,CONVERT(varchar(10),LastContactDate,101) as LastContactDate
      ,CONVERT(varchar(20),dbo.ConvertUTCtoEST(ModifyDate)) as ModifyDate
      ,ModifiedByName
      ,LastContactByName
      ,LastERVisit
	from MemberDiagnosisSummaryCOPC m
		left join dbo.LookupHPMemberStatus s on m.StatusID = s.ID
	where CustID = @selectedParentHPID
		and 
		(
			(@Condition = @AsthmaLookupID and m.MVDID in(select ICENUMBER from MainCondition con where con.CodeFirst3 = '493'))
			OR
			(@Condition = @W15LookupID and m.MVDID in(select MVDID from MainToDoHEDIS where TestLookupID = @W15HedisLookupID)
			)
		)

	
	select @TotalResultCount = COUNT(ID)
	from @result
	
	select top 500 ID,InsMemberID,CustID,MVDID,FirstName,LastName,MemberName,StatusID      
      ,Status,PCPVisitCount,ERVisitCount,PCPVisitCountSinceContact,ERVisitCountSinceContact
      ,LastContactDate,ModifyDate,ModifiedByName,LastContactByName,LastERVisit
    from @result
END