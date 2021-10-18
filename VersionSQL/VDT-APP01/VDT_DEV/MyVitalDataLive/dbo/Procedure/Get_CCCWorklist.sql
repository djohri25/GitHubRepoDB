/****** Object:  Procedure [dbo].[Get_CCCWorklist]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_CCCWorklist]
(
	@CustID		int,
	@UserID		varchar(200)
)
AS
BEGIN
--Declare @UserID varchar(max), @CustID int
--select @UserID = '66816E29-EC82-4091-8883-C152D04D0650', @CustID = 15

Declare @SQL varchar(8000);
Declare @Status_table	varchar(100), @Status_Cond	varchar(100),  @Status_Value	varchar(100), @Rule_Body  varchar(8000), @RuleID	int

IF Object_ID('TempDB.dbo.#Temp_Result','U') is not null
Drop table #Temp_Result
Create Table #Temp_Result
(

	AlertID int null,
	memberID varchar(100),
	MVDId varchar(30),
	CaseID varchar(100),
	AlertReason varchar(500),
	FirstName varchar(100),
	LastName varchar(100),
	CMProgram varchar(100), 
	CaseStatus varchar(100), 
	CaseManager varchar(100), 
	[SocialWorker]  varchar(100), 
	[CommunityHealthWorker] varchar(100),
	EligibilityEndDate datetime, 
	CMLevel varchar(100), 
	StartDate Date, 
	CMNextContactDate Datetime, 
	SWNextContactDate Datetime, 
	CHWNextContactDate Datetime, 
	EndDate Date, 
	Reason  varchar(500),
	LockedBy  varchar(100)
)

IF Object_ID('TempDB.dbo.#Temp_Rules','U') is not null
Drop table #Temp_Rules
SELECT * INTO #Temp_Rules FROM HPWorkflowrule where Cust_ID = @CustID

WHILE EXISTS (Select 1 from #Temp_Rules)
BEGIN
	Select top 1 @RuleID = Rule_ID, @Rule_Body = Body from #Temp_Rules where Cust_ID = @CustID 

	--select @RuleID as ruleID, @Rule_Body as '@Rule_Body'
	IF @Rule_Body like '% != %'
	BEGIN
		Select top 1 @Status_Cond = '!='
		select @Status_table = SUBSTRING(@Rule_Body, 1, CHARINDEX( @Status_Cond, @Rule_Body)-1)
		select @Status_Value = SUBSTRING(@Rule_Body, CHARINDEX( @Status_Cond, @Rule_Body)+4,  CHARINDEX( ''' ', @Rule_Body)-CHARINDEX( @Status_Cond, @Rule_Body)-4)
		--Select @Status_Value = '%' + @Status_Value + '%'
		--select @Status_table, @Status_Cond	,  @Status_Value
	END
	else IF @Rule_Body like '% = %'
	BEGIN
		Select top 1 @Status_Cond = '='
		select @Status_table = SUBSTRING(@Rule_Body, 1, CHARINDEX( @Status_Cond, @Rule_Body)-1)
		select @Status_Value = SUBSTRING(@Rule_Body, CHARINDEX( @Status_Cond, @Rule_Body)+3,  CHARINDEX( ''' ', @Rule_Body)-CHARINDEX( @Status_Cond, @Rule_Body)-3)
		--Select @Status_Value = '%' + @Status_Value + '%'
		--select @Status_table, @Status_Cond	,  @Status_Value
	END


	set @SQL = N'SELECT DISTINCT  h.ID as AlertID,
							 h.memberID as memberID,
							 h.MVDID as MVDId,
							 MF.CaseID CaseID,
							 h.[text] as AlertReason,
							 MP.FirstName,
							 MP.LastName,
							 MF.q6c AS CMProgram, 
							 MF.q4c AS CaseStatus, 
							 Case WHEN (MF.CaseID like ''%Case Manager%'')  then CASE WHEN MF.q5c like ''%other%'' then MF.q5ac ELSE MF.q5c END ELSE NULL END AS CaseManager, 
							 Case WHEN (MF.CaseID like ''%Social Worker%'') then CASE WHEN MF.q5c like ''%other%'' then MF.q5ac ELSE MF.q5c END ELSE NULL END  AS [SocialWorker], 
							 Case WHEN (MF.CaseID like ''%Community Health Worker%'') then CASE WHEN MF.q5c like ''%other%'' then MF.q5ac ELSE MF.q5c END ELSE NULL END  AS [CommunityHealthWorker],
							 CONVERT(datetime, MI.TerminationDate, 100) AS EligibilityEndDate, 
							 MF.q7c AS CMLevel, 
							 CASE WHEN CONVERT(Date, MF.q3c) like ''%1900-01-01%'' THEN NULL ELSE CONVERT(Date, MF.q3c) END AS StartDate, 
							 Case WHEN (MF.CaseID like ''%Case Manager%'')  then CONVERT(Datetime, P.q99,120) ELSE NULL END AS CMNextContactDate, 
							 Case WHEN (MF.CaseID like ''%Social Worker%'')  then CONVERT(Datetime, P.q99,120) ELSE NULL END AS SWNextContactDate, 
							 Case WHEN (MF.CaseID like ''%Community Health Worker%'')  then CONVERT(Datetime, P.q99,120) ELSE NULL END AS CHWNextContactDate, 
							 CASE WHEN CONVERT(Date, MF.q4ac) like ''%1900-01-01%'' THEN NULL ELSE CONVERT(Date, MF.q4ac) END AS EndDate, 
							 MF.q4bc AS Reason,
							 h.LockedBy as LockedBy
	FROM  dbo.HPAlert h INNER JOIN [dbo].[Link_HPAlertGroupAgent] A ON CAST(A.Group_id as  varchar(10))= CAST(h.AgentID as varchar(200))INNER JOIN
				  dbo.HPWorkflowrule r ON r.Rule_ID = H.TriggerID and r.Cust_id = H.RecipientCustID  INNER JOIN 
				  dbo.Link_MemberID_MVD_Ins lm ON h.MemberID = lm.InsMemberId and lm.cust_id = h.RecipientCustID INNER JOIN 
				  MainPersonalDetails AS MP ON lm.MVDId = MP.ICENUMBER INNER JOIN
				  (Select MVDID, FormDate, FormAuthor,q3c, q4c, q4ac, q4bc, q5c, q5ac, q6c, q7c, CaseID, ROW_NUMBER() OVER(Partition By MVDID, q4c, q5c, q5ac, SH.ID ORDER BY Formdate desc) as rnk --, q5c, q5ac , SH.ID
					from  dbo.CCC_CAS_Form  JOIN 
					dbo.CCC_StakeholderGroup SH ON  SH.StakeHolderGroup =  LTRIM(RTRIM(SUBSTRING(CaseID,24,150))) LEFT JOIN ---- SH.StakeholderGroup = DBO.Get_SHGroupFromUser(CCC_CAS_Form.q5c) LEFT JOIN 
					dbo.Link_CCC_UserSHGroup SHG ON SH.ID = SHG.SHGroupID 
					--Where CAS.q4c not like   @Status_Value  
					Where '+@Status_table +' '+ @Status_Cond +' '''+  @Status_Value+''' 
				)   MF ON MF.MVDID = MP.ICENUMBER INNER JOIN
				  dbo.Link_MemberId_MVD_Ins AS L ON L.MVDId = MP.ICENUMBER INNER JOIN
				  dbo.MainInsurance AS MI ON MI.ICENUMBER = MP.ICENUMBER LEFT OUTER JOIN
	 (Select MVDID , caseID, MAX(q99) as q99  from dbo.CCC_ProgressNote_Form P1 
						group by p1.MVDID, P1.CaseID) P ON P.MVDID = MF.MVDID  and MF.CaseID = P.CaseID 
	WHERE       (L.Cust_ID = '''+CAST(@CustID as varchar(3))+''' )
				AND r.Rule_ID = '''+CAST(@RuleID as varchar(10))+'''
				AND h.TriggerType = ''WORKFLOW''
				AND h.RecipientType = ''Group''
				AND MF.Rnk = 1
				AND A.Agent_ID = '''+@UserID+'''
	ORDER BY MVDID, startdate '

	Print @SQL;

	INSERT INTO #Temp_Result (AlertID, memberID ,MVDId ,	CaseID ,	AlertReason ,FirstName ,LastName ,CMProgram , CaseStatus , CaseManager , [SocialWorker]  , [CommunityHealthWorker] ,EligibilityEndDate , CMLevel , 	StartDate,CMNextContactDate,SWNextContactDate, CHWNextContactDate,	EndDate ,Reason,LockedBy)
	EXEC (@SQL);


	delete from #Temp_Rules Where Rule_ID = @RuleID
END

Select Distinct * from #Temp_Result		
	
END