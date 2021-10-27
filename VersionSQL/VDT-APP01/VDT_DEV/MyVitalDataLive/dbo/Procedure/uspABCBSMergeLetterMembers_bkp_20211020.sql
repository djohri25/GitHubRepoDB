/****** Object:  Procedure [dbo].[uspABCBSMergeLetterMembers_bkp_20211020]    Committed by VersionSQL https://www.versionsql.com ******/

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
-- =============================================
CREATE PROCEDURE [dbo].[uspABCBSMergeLetterMembers_bkp_20211020]
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

	UPDATE dbo.LetterMembers SET MemberType = CASE WHEN [MemberCMOrgReg] = 'WALMART' THEN 'Care' ELSE 'Case' END FROM dbo.LetterMembers WHERE ID = @ID 

	UPDATE LM
	SET LM.LetterFooter = CASE 
		WHEN LM.[MemberCMOrgReg] = 'WALMART' THEN REPLACE(LT.[LetterFooter],'CareType','Care')
		WHEN LM.[MemberCMOrgReg] <> 'WALMART' THEN REPLACE(LT.[LetterFooter],'CareType','Case')
		ELSE LM.LetterFooter END
	FROM dbo.LetterMembers LM
		INNER JOIN dbo.LetterTemplate LT ON LM.LetterType = LT.LetterType
	WHERE LM.[LetterType] = 1 AND LM.[LetterLanguage] = 'English' AND ID = @ID

	UPDATE LM
	SET LM.LetterFooter = CASE 
		WHEN LM.[MemberCMOrgReg] = 'WALMART' THEN REPLACE(LT.[LetterFooter],'CareType','de la atención médica')
		WHEN LM.[MemberCMOrgReg] <> 'WALMART' THEN REPLACE(LT.[LetterFooter],'CareType','de casos')
		ELSE LM.LetterFooter END
	FROM dbo.LetterMembers LM
		INNER JOIN dbo.LetterTemplate LT ON LM.LetterType = LT.LetterType
	WHERE LM.[LetterType] = 2 AND LM.[LetterLanguage] = 'Spanish' AND ID = @ID

	--UPDATE LM
	--SET LM.LetterFooter = LT.LetterFooter 
	--FROM dbo.LetterMembers LM
	--	INNER JOIN dbo.LetterTemplate LT ON LM.LetterType = LT.LetterType
	--WHERE LM.[LetterType] = 26 AND LM.[LetterLanguage] = 'English' AND ID = @ID

	UPDATE LM
	SET LM.LetterFooter = LT.LetterFooter 
	FROM dbo.LetterMembers LM
		INNER JOIN dbo.LetterTemplate LT ON LM.LetterType = LT.LetterType
	WHERE ID = @ID
	AND LM.LetterType not in (1,2)
	AND LM.LetterLanguage = LT.LetterLanguage

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\SpecialDelivery.png', LogoPadR='198.72pt', LogoPadB='28.8pt' FROM dbo.LetterMembers WHERE LetterType IN (20,22) AND ID = @ID

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\FEP.png', LogoPadR='259.2pt', LogoPadB ='61.92pt' 
	FROM dbo.LetterMembers 
	WHERE LetterType IN (19,21,32,33,35,36,37,38,39,40,41,42,43,44,45,46) 
	AND ID = @ID --Changed size
	
	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\LifeWithBaby.png', LogoPadR='378pt', LogoPadB='28.8pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (11,12,13,14,15,16,17,18,34,47) 
	AND MemberCMOrgReg = 'WALMART'

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\HealthyTots.png', LogoPadR='297.36pt', LogoPadB='28.8pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (11,12,13,14,15,16,17,18,34,47) 
	AND MemberCMOrgReg = 'TYSON'

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\SpecialDelivery.png', LogoPadR='198.72pt', LogoPadB='28.8pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (11,12,13,14,15,16,17,18,34,47) 
	AND MemberCMOrgReg NOT IN ('WALMART','TYSON')

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\ABCBS.png', LogoPadR='241.92pt', LogoPadB ='61.92pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,52,56) 
	AND MemberBrandingName IN ('ABCBS','EXCHNG','MEDICAREADV')

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\ASE_PSE_HealthAdvantage.png', LogoPadB ='54pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,50,54) 
	AND MemberBrandingName IN ('ASEPSE')

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\HealthAdvantage.png', LogoPadR='241.92pt', LogoPadB ='72pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,52,56) 
	AND MemberBrandingName IN ('HA')

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\Arkansas_State_Police_Health_Advantage.png', LogoPadB ='14.4pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,49,53) 
	AND MemberBrandingName IN ('ARSTATEPOLICE')

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\BlueAdvantage.png', LogoPadR='193.68pt', LogoPadB ='61.92pt'
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,52,56) 
	AND MemberBrandingName IN ('BAAA') 

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\FEP.png', LogoPadR='259.2pt', LogoPadB ='61.92pt' --Changed size
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,51,55) 
	AND MemberBrandingName IN ('FEP') 

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\USAA.png', LogoPadR='359.28pt', LogoPadB ='61.92pt' --Changed size
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,52,56) 
	AND MemberBrandingName IN ('USAA') 

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\USAM.png', LogoPadR='352.08pt', LogoPadB ='61.92pt' --Changed size
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,23,24,25,26,27,28,29,30,31,52,56) 
	AND MemberBrandingName IN ('USAM') 

	UPDATE dbo.LetterMembers SET LetterLogoPath='file:C:\ReportImages\ABCBS.png', LogoPadR='241.92pt', LogoPadB ='61.92pt'					--Default Image	
	FROM dbo.LetterMembers WHERE ID = @ID
	AND LetterType IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,23,24,25,26,27,28,29,30,31,52,56) 
	AND [MemberBrandingName]  IS NULL 
	AND [MemberCMOrgReg] IS NULL
	AND [LetterLogoPath] IS NULL

	SELECT @ID

END