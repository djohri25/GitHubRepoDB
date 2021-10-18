/****** Object:  Procedure [dbo].[Get_HPMembersByCondition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/20/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPMembersByCondition]
	@Condition varchar(50),
	@CustID int,
	@PCP_NPI varchar(50),
	@ErVisitFlag varchar(50),
	@PcpVisitAfterER bit,
	@TotalResultCount int output
	
AS
BEGIN
	SET NOCOUNT ON;

--select @Condition ='1',
--	@CustID ='6',
--	@PCP_NPI ='1265480552',
--	@ErVisitFlag =-1,
--	@PcpVisitAfterER=0
	
	declare @selectedParentHPID int, @mvdid varchar(20), @lastERVisit datetime, @id int
	declare @result table (ID int,InsMemberID varchar(20),CustID varchar(20),MVDID varchar(20)
		,FirstName varchar(50),LastName varchar(50),MemberName varchar(50),StatusID varchar(20)
		,Status	varchar(50),PCPVisitCount int,ERVisitCount int ,PCPVisitCountSinceContact int
		,ERVisitCountSinceContact int,LastContactDate varchar(20),ModifyDate varchar(20)
		,ModifiedByName varchar(100),LastContactByName varchar(100), LastERVisit datetime,
		isProcessed bit default(0))

	select @selectedParentHPID = dbo.Get_HPParentCustomerID(@CustID)

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
	from MemberDiagnosisSummary m
		left join dbo.LookupHPMemberStatus s on m.StatusID = s.ID
	where CustID = @selectedParentHPID
		and MVDID in
		(
			select MVDID from Link_Member_LookupCondition where LookupConditionID =  @Condition
			--select icenumber from MainCondition 
			--where Code in
			--(
			--	select Code from Link_ConditionLookupCode where lookupID = @Condition
			--)
		)	


		
	if(ISNULL(@PCP_NPI,'') <> '')
	begin
		delete from @result
		where mvdid not in
		(
			--select ICENUMBER from MainSpecialist where NPI = @PCP_NPI
			select p.mvdid from dbo.Link_Member_PCP p where p.PCP_NPI = @PCP_NPI
		)
	end		
	
	if(ISNULL(@ErVisitFlag,'') = '1')
	begin
		delete from @result where LastERVisit is null
	end
	else if(ISNULL(@ErVisitFlag,'') = '0')
	begin
		delete from @result where LastERVisit is not null
	end
	
	if(@PcpVisitAfterER = 1 and ISNULL(@PCP_NPI,'') <> '')
	begin
		-- Must be PCP visit after ER visit
		delete from @result where LastERVisit is null

		while exists(select ID from @result where isProcessed = 0)
		begin
			select top 1 @id = ID, @mvdid = MVDID, @lastERVisit = LastERVisit 
			from @result where isProcessed = 0
			
			if not exists(
				select ICENUMBER from EDVisitHistory					
				where ICENUMBER = @mvdid
					and VisitDate > @lastERVisit
					and FacilityNPI in
					(
						select p.pcp_npi from dbo.Link_Member_PCP p where mvdid = @mvdid
						--select npi from MainSpecialist where ICENUMBER = @mvdid and RoleID = 1
					)						
			)
			begin
				delete from @result where MVDID = @mvdid
			end
						
			update @result set isProcessed = 1 where ID = @id
		end
	end
	else if(@PcpVisitAfterER = 0 and ISNULL(@PCP_NPI,'') <> '')
	begin
		-- Members who didn't visit their PCP after ER visit
		delete from @result where LastERVisit is null
		
		update @result set isProcessed = 0

		while exists(select ID from @result where isProcessed = 0)
		begin
			select top 1 @id = ID, @mvdid = MVDID, @lastERVisit = LastERVisit 
			from @result where isProcessed = 0
			
			if exists(
				select ICENUMBER from EDVisitHistory					
				where ICENUMBER = @mvdid
					and VisitDate > @lastERVisit
					and FacilityNPI in
					(
						select p.pcp_npi from dbo.Link_Member_PCP p where mvdid = @mvdid
						--select npi from MainSpecialist where ICENUMBER = @mvdid and RoleID = 1
					)						
			)
			begin
				delete from @result where MVDID = @mvdid
			end
						
			update @result set isProcessed = 1 where ID = @id
		end	
	end
	
	select @TotalResultCount = COUNT(ID)
	from @result
	
	select top 500 ID,InsMemberID,CustID,MVDID,FirstName,LastName,MemberName,StatusID      
      ,Status,PCPVisitCount,ERVisitCount,PCPVisitCountSinceContact,ERVisitCountSinceContact
      ,LastContactDate,ModifyDate,ModifiedByName,LastContactByName,LastERVisit
    from @result
END