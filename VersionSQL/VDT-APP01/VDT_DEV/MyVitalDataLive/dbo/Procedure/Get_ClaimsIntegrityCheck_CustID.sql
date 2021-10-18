/****** Object:  Procedure [dbo].[Get_ClaimsIntegrityCheck_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_ClaimsIntegrityCheck_CustID]
(
	@Cust_ID	int
)
AS
BEGIN
	DECLARE @Cust_Name	varchar(100)
	Declare @MaxCreated Datetime
	
	IF @Cust_ID = 11
	BEGIN	
		SET @Cust_Name = 'Driscoll'
	END
	IF @Cust_ID = 10
	BEGIN	
		SET @Cust_Name = 'Parkland'
	END

	select @MaxCreated = MAX(Created) from ImportHistory WHere Customer = @Cust_Name and SourceName = 'Claims' 
	SET @MaxCreated = DATEADD(Day,-2,@MaxCreated)

	IF OBJECT_ID('TempDB.dbo.#Claims_Compare_Final','U') is not null
	Drop table #Claims_Compare_Final
	Create TABLE #Claims_Compare_Final
	(
		Cust_ID	int, 
		MVDID	varchar(60),
		MemberID	varchar(60), 
		ImportRecordID	int, 
		HPAssignedID	VARCHAR(260),
		ClaimID	VARCHAR(100), 
		Line	INT, 
		Customer	VARCHAR(30), 
		SourceName	VARCHAR(30), 
		DBName	VARCHAR(100), 
		Created Datetime
	)

	INSERT INTO #Claims_Compare_Final (Cust_ID, MVDID, ImportRecordID, HPAssignedID, ClaimID, Line, Customer, SourceName, DBName, Created)
	SELECT Distinct @Cust_ID, MVDID, ImportRecordID, HPAssignedID,REPLACE(SUBSTRING(HPAssignedID,CHARINDEX('Claim: ', HPAssignedID,1),CHARINDEX('Line: ', HPAssignedID,1)-3), 'Claim: ','') as ClaimID, REPLACE(SUBSTRING(HPAssignedID,CHARINDEX('Line: ', HPAssignedID,1),LEN(HPAssignedID)), 'Line: ','') as Line, Customer, SourceName, DBName, Created 
	FROM ImportHistory WHere Customer = @Cust_Name and SourceName = 'Claims' and Convert(Date, Created,120) >= @MaxCreated and RecordType <> 'Vaccine' 

	UPDATE  T
	SET T.MemberID = L.InsMemberId
	FROM #Claims_Compare_Final T JOIN Link_MemberId_MVD_Ins L ON L.Cust_ID = T.Cust_ID and L.MVDID = T.MVDID 
	WHERE L.Cust_ID = @Cust_ID


	INSERT INTO [VD-RPT01].[HPM_IMPORT].[dbo].[Claims_Compare_Final] (Cust_ID, MVDID, MemberID, ImportRecordID, HPAssignedID, ClaimID, Line, Customer, SourceName, DBName, Created)
	SELECT Cust_ID, MVDID, MemberID, ImportRecordID, HPAssignedID, ClaimID, Line, Customer, SourceName, DBName, Created FROM #Claims_Compare_Final

END