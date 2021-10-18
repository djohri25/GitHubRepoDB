/****** Object:  Procedure [dbo].[IndexGetMaincareplan]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[IndexGetMaincareplan]
(	@Cust_ID nvarchar(50),
	@MVDID nvarchar(50),
	@cpLibraryID int,
	@CarePlanDate date,
	@Author nvarchar(50) = NULL, 
	@Language nvarchar(20) = NULL, 
	@CaseID varchar(100) = NULL, 
	@cpInactiveDate date = NULL, 
	@CreatedDate datetime = NULL,
	@CreatedBy nvarchar(50),
	@UpdatedDate datetime = NULL,
	@UpdatedBy nvarchar(50) = NULL)


	AS 
BEGIN 
	SET NOCOUNT ON;

	DECLARE @ScopeId int


	IF EXISTS (SELECT 1 FROM dbo.CarePlanLibraryIndex 
								where cpLibraryID=@cpLibraryID and cpLibraryCustID=@Cust_ID)

		BEGIN
		INSERT INTO MainCarePlanMemberIndex 
		 (Cust_ID
		  ,MVDID
		  ,cpLibraryID
		  ,CarePlanDate
		  ,Author
		  ,Language
		  ,CaseID
		  ,cpInactiveDate
		  ,CreatedDate
		  ,CreatedBy
		  ,UpdatedDate
		  ,UpdatedBy)
		 VALUES (@Cust_ID,
		  @MVDID,
		  @cpLibraryID,
		  @CarePlanDate,
		  @Author,
		  @Language,
		  @CaseID,
		  @cpInactiveDate,
		  @CreatedDate,
		  @CreatedBy,
		  @UpdatedDate,
		  @UpdatedBy)

		  SET @ScopeId= SCOPE_IDENTITY()

		  SELECT [CarePlanID]
		  ,[Cust_ID]
		  ,[MVDID]
		  ,[cpLibraryID]
		  ,[CarePlanDate]
		  ,[Author]
		  ,[Language]
		  ,[CaseID]
		  ,[cpInactiveDate]
		  ,[CreatedDate]
		  ,[CreatedBy]
		  ,[UpdatedDate]
		  ,[UpdatedBy]
	  FROM [dbo].[MainCarePlanMemberIndex] 
	  WHERE [CarePlanID]=@ScopeId

		  END 


ELSE 

	BEGIN
		--CHECK LATER FOR THE OPERATIONS
		SELECT GETDATE() --DUMMY QUERY
	END 

END 