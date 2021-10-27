/****** Object:  Procedure [dbo].[uspABCBSMergeLetterMembers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sunil Nokku
-- Create date: 06/25/2019
-- Description:	To flag the Members for the generation of Letters for (ABCBS)
-- Changes:		To add ARSTATEPOLICE Logo (1/4/2020)
-- 5/11/2020 Sunil Nokku CC Spanish Letters
-- 9/16/2020 Sunil Nokku Increase Signature legnth to 80 #TFS 3557
-- 9/24/2020 Sunil Nokku New Letters 32,33,34 and Logo changed #TFS 3679, 3681, 3682
-- 10/6/2020 Sunil Nokku New Letters #TFS 3675, 3676, 3677, 3678, 3680
-- 11/11/2020 Sunil Nokku #TFS 3755,3760,3758,3754,3756,3757,3759,3753,3887,3856,3886,3888
-- 08/19/2021 Sunil Nokku TFS5965 Add Logo for ER Letters	
-- 10/20/2021 Sunil Nokku Simplify Logo Logic
-- =============================================
CREATE PROCEDURE [dbo].[uspABCBSMergeLetterMembers]
	@UserName				VARCHAR(100) = NULL, --new column
	@MVDID					VARCHAR(50) ,
	@MemberID				VARCHAR(20) ,
	@MemberLOB				VARCHAR(50) ,
	@MemberGroup			VARCHAR(50) ,
	@MemberCMOrgReg			VARCHAR(100) = NULL, --new column
	@MemberBrandingName		VARCHAR(100) = NULL, --new column
	@CompanyName			VARCHAR(100) = NULL, --new column
	@MemberType				VARCHAR(50) ,
	@MemberName				VARCHAR(100) ,
	@MemberDOB				VARCHAR(50)	,
	@MemberAddress1			VARCHAR(100) = NULL,
	@MemberAddress2			VARCHAR(100) = NULL,
	@MemberState			VARCHAR(50)	 = NULL,
	@MemberCity				VARCHAR(50)  = NULL,
	@MemberZip				VARCHAR(50)  = NULL,
	@LetterName				VARCHAR(100) ,
	@LetterDate				DATETIME ,
	@LetterLanguage			VARCHAR(50) ,
	@LetterDelete			VARCHAR(5)	,
	@CareManagerName		VARCHAR(100) = NULL,
	@CareManagerCredentials	NVARCHAR(255) = NULL,
	@CareManagerExtension	VARCHAR(200) = NULL,
	@LetterFlag				VARCHAR(20),
	@ID						INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
		
	DECLARE @LetterType INT
	SET @ID = 0

	SELECT @LetterType = LetterType FROM dbo.LetterTemplate WHERE LetterName = @LetterName and LetterLanguage = @LetterLanguage

	DECLARE @UserInfo TABLE ( UserName NVARCHAR(MAX) NULL
		,UserFullName			NVARCHAR(MAX) NULL
		,UserLastName			NVARCHAR(MAX) NULL
		,UserFirstName			NVARCHAR(MAX) NULL
		,UserPhone				NVARCHAR(MAX) NULL
		,UserPhoneExtension		NVARCHAR(MAX) NULL
		,UserEmail				NVARCHAR(MAX) NULL
		,UserDepartment			NVARCHAR(MAX) NULL
		,UserGroups				NVARCHAR(MAX) NULL
		,UserSupervisor			NVARCHAR(MAX) NULL
		,UserSignature			NVARCHAR(MAX) NULL
		,UserLicense			NVARCHAR(MAX) NULL
		,AgentID				NVARCHAR(MAX) NULL)

	INSERT INTO @UserInfo
	EXEC dbo.[usp_GetUserNameInfo] 16, @UserName

	SELECT @CareManagerName = UserFullName, @CareManagerCredentials = UserSignature, @CareManagerExtension = AgentID FROM @UserInfo --Change to use Signature column.

		BEGIN    /* Insert new Member Letter */

			INSERT INTO dbo.LetterMembers(  
				 [UserName]					--new column
				,[MVDID] 
				,[MemberID]
				,[MemberLOB] 
				,[MemberGroup] 
				,[MemberCMOrgReg]			--new column
				,[MemberBrandingName]		--new column
				,[CompanyName]				--new column
				,[MemberType] 
				,[MemberName] 
				,[MemberDOB]
				,[MemberAddress1] 
				,[MemberAddress2] 
				,[MemberState] 
				,[MemberCity] 
				,[MemberZip] 
				,[LetterType] 
				,[LetterDate] 
				,[LetterLanguage] 
				,[LetterDelete] 
				,[CareManagerName] 
				,[CareManagerCredentials] 
				,[CareManagerExtension] 
				,[Createdby] 
				,[CreatedDate] 
				,[Processed] 
				,[ProcessedDate]
				,[LetterFlag])
			SELECT 
				 @UserName					--new column
				,@MVDID
				,@MemberID				
				,@MemberLOB				
				,@MemberGroup	
				,@MemberCMOrgReg			--new column
				,@MemberBrandingName		--new column
				,@CompanyName				--new column
				,@MemberType				
				,SUBSTRING(@MemberName, CHARINDEX(', ', @MemberName) + 2, 8000)  + ' ' + SUBSTRING(@MemberName, 1, CHARINDEX(', ', @MemberName) - 1)
				--,@MemberName
				,@MemberDOB
				,@MemberAddress1			
				,@MemberAddress2			
				,@MemberState			
				,@MemberCity				
				,@MemberZip				
				,@LetterType				
				,@LetterDate				
				,@LetterLanguage			
				,@LetterDelete						
				,@CareManagerName		
				,@CareManagerCredentials	
				,@CareManagerExtension	
				,@CareManagerName		
				,getdate()
				,NULL
				,NULL
				,@LetterFlag
		END

	SET @ID = SCOPE_IDENTITY()

	Update lm
	Set lm.LetterLogoPath	= lt.LetterLogoPath,
		lm.LetterFooter		= lt.LetterFooter,
		lm.LogoPadL			= lt.LogoPadL,
		lm.LogoPadR			= lt.LogoPadR,
		lm.LogoPadT			= lt.LogoPadT,
		lm.LogoPadB			= lt.LogoPadB,
		lm.MemberType		= lt.MemberType
	From LetterMembers lm
	Inner Join LetterTemplate lt On lt.LetterType = lm.LetterType
	Where lm.ID = @ID
	And lm.LetterLanguage = lt.LetterLanguage
	And ( IsNull(lm.MemberCMOrgReg,'') = IsNull(lt.CmOrgRegion,'')	
		Or IsNull(lm.MemberBrandingName,'') = IsNull(lt.BrandingName,'') )

	SELECT @ID

END