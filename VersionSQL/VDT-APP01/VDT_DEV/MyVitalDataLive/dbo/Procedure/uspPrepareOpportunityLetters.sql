/****** Object:  Procedure [dbo].[uspPrepareOpportunityLetters]    Committed by VersionSQL https://www.versionsql.com ******/

/*

Author:			Sunil Nokku
Create date:	2021-09-22
Description:	Generate data for Opportunity Batch Letters for the below rules ( TFS 6022 )
				'Emerging High Cost CHF Risk < 4',
				'Emerging High Cost COPD Risk < 4',
				'Emerging High Cost HTN Risk < 4',
				'Emerging High Cost DIA Risk < 4',
				'Emerging High Cost Cancer Risk < 4',
				'Emerging High Cost Asthma Risk < 4',
				'Emerging High Cost CAD Risk < 4'

--Exec [dbo].[uspPrepareOpportunityLetters] NULL,NULL,5000
--131344

Date				Modified			Description
2021-09-22			Sunil Nokku			Initial Version
2021-10-21			Sunil Nokku			Modified LettersInsert from SP call to direct Insert.

*/

CREATE Procedure [dbo].[uspPrepareOpportunityLetters]
@p_CustomerId int	= NULL,
@p_ProductId int	= NULL,
@p_BatchSize int	= 2000
As
Begin

Set NoCount On;

Declare
	@LetterCount					int				= 0,
	@v_BatchSize					int				= @p_BatchSize		--Maximum number of letter every time


Declare 
	@v_user_name					nvarchar(255),
	@v_letter_name					nvarchar(255),
	@v_letter_delete_yn				nvarchar(50)		= 'N',
	@v_letter_flag					nvarchar(50)		= 'SB',
	@v_letter_date					datetime			= getUTCDate(),
	@v_letter_member_id				bigint,
	@v_member_case_letter_id		bigint,
	@v_ID							int

Declare 
	@v_mvd_id						varchar(20),
	@v_case_owner					varchar(max),
	@v_mmf_id						bigint,
	@v_mmf_form_date				datetime,
	@v_case_id						varchar(100),
	@v_mef_id						bigint,
	@v_mef_form_date				datetime,
	@v_cf_id						bigint,
	@v_member_id					nvarchar(50),
	@v_member_name					nvarchar(255),
	@v_member_firstname				nvarchar(255),
	@v_member_lastname				nvarchar(255),
	@v_other_language				nvarchar(255),
	@v_line_of_business				nvarchar(255),
	@v_group						nvarchar(255),
	@v_cm_org_region				nvarchar(255),
	@v_branding_name				nvarchar(255),
	@v_company_name					nvarchar(255),
	@v_member_type					nvarchar(50),
	@v_date_of_birth				date,
	@v_letter_type					int,
	@v_CareManagerName				varchar(50),
	@v_CareManagerCredentials		nvarchar(255),
	@v_CareManagerExtension			varchar(20)

Declare 
	@v_address1						nvarchar(255),
	@v_address2						nvarchar(255),
	@v_city							nvarchar(255),
	@v_state						nvarchar(2),
	@v_postal_code					nvarchar(50),
	@v_home_phone					nvarchar(50),
	@v_cell_phone					nvarchar(50),
	@v_work_phone					nvarchar(50),
	@v_fax							nvarchar(50),
	@v_email						nvarchar(50),
	@v_language						nvarchar(50);


--select * from lookup_generic_code where codeid = 271
--LetterSSRS
Declare 
	@v_note_type_id					bigint				= 271;

-- Get the candidate list of Members
Declare letter_cursor Cursor For
	Select Distinct
		ccq.[MVDID],
		ccq.[CaseOwner],
		ccq.[MemberID],
		ccq.[LastName],
		ccq.[FirstName],
		CONCAT( ccq.LastName, ', ', ccq.FirstName )		[MemberName],
		ccq.[LOB],	
		ccq.[CmOrGRegion],	
		fm.[BrandingName],
		ccq.[CompanyName],	
		Case
		When ccq.[CmOrGRegion] = 'WALMART' THEN 'Care'
		Else 'Case'
		End												[MemberType],
		ccq.[DOB]										[DateOfBirth],
		'Opportunity Letter'							[LetterName]
	From 
		dbo.[CareFlowTask] ct (readuncommitted)
		inner join 
		dbo.[ComputedCareQueue] ccq (readuncommitted) 
			on ct.[MVDID] = ccq.[MVDID] 
		inner join dbo.[FinalMemberEtl] fm (readuncommitted)
			on
			ct.[MVDID] = fm.[MVDID] 
			and fm.[CMOrgRegion] = ccq.[CmOrGRegion]
	Where 
		ct.[RuleId] in ( 225,228,231,234,237,250,253 )
	Order By
		ccq.[MVDID]
	For Read Only

Open letter_cursor;

-- Get the first record
Fetch Next From letter_cursor Into
	@v_mvd_id,
	@v_case_owner,
	@v_member_id,
	@v_member_firstname,
	@v_member_lastname,
	@v_member_name,
	@v_line_of_business,
	@v_cm_org_region,
	@v_branding_name,
	@v_company_name,
	@v_member_type,
	@v_date_of_birth,
	@v_letter_name;

-- Iterate through the list
While @@FETCH_STATUS = 0
Begin
	Select 
		@v_member_case_letter_id	= NULL,
		@v_letter_member_id			= NULL;

	SELECT
	@v_address1 = ISNULL( csme.Address1, fm.Address1 ),
	@v_address2 = ISNULL( csme.Address2, fm.Address2 ),
	@v_city = ISNULL( csme.City, fm.City ),
	@v_state = ISNULL( csme.State, fm.State ),
	@v_postal_code = ISNULL( csme.PostalCode, fm.Zipcode ),
	@v_language = ISNULL( csme.[Language], ISNULL( fm.WrittenLanguage, fm.[Language] ) )
	FROM
	FinalMember fm
	LEFT OUTER JOIN
	(
		SELECT DISTINCT
		IceNumber,
		Address1,
		Address2,
		City,
		State,
		PostalCode,
		HomePhone,
		CellPhone,
		WorkPhone,
		FAXPhone,
		Email,
		Language,
		RANK() OVER ( PARTITION BY IceNumber ORDER BY RecordNumber DESC ) record_rank
		FROM
		CareSpaceMemberEdit
		WHERE
		IceNumber = @v_mvd_id
		AND IsPrimary = 1
	) csme
	ON csme.IceNumber = fm.MVDID
	AND csme.record_rank = 1
	WHERE
	fm.MVDID = @v_mvd_id;
	
	Select @v_language = IsNull( @v_language, 'English' )
	
	Set @v_user_name = @v_case_owner;
		
	Select @v_letter_type = LetterType 
	From LetterTemplate
	Where LetterName = @v_letter_name
	And LetterLanguage = @v_language

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
		,[LetterFlag]
		,BatchID)
	SELECT 
		 @v_user_name					--new column
		,@v_mvd_id
		,@v_member_id				
		,@v_line_of_business				
		,NULL	
		,@v_cm_org_region			--new column
		,@v_branding_name		--new column
		,@v_company_name				--new column
		,@v_member_type				
		,SUBSTRING(@v_member_name, CHARINDEX(', ', @v_member_name) + 2, 8000)  + ' ' + SUBSTRING(@v_member_name, 1, CHARINDEX(', ', @v_member_name) - 1)
		--,@MemberName
		,@v_date_of_birth
		,@v_address1			
		,@v_address2			
		,@v_state			
		,@v_city				
		,@v_postal_code				
		,@v_letter_type				
		,@v_letter_date				
		,@v_Language			
		,@v_letter_delete_yn						
		,@v_CareManagerName		
		,@v_CareManagerCredentials	
		,@v_CareManagerExtension	
		,'System'	
		,getdate()
		,'N'
		,NULL
		,@v_letter_flag
		,0

	SET @v_ID = SCOPE_IDENTITY()

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
	Where lm.ID = @v_ID
	And lm.LetterLanguage = lt.LetterLanguage
	And ( IsNull(lm.MemberCMOrgReg,'') = IsNull(lt.CmOrgRegion,'')	
		Or IsNull(lm.MemberBrandingName,'') = IsNull(lt.BrandingName,'') )

	Insert Into dbo.HPAlertNote (
		Note,
		AlertStatusID,
		DateCreated,
		CreatedBy,
		DateModified,
		ModifiedBy,
		MVDID,
		CreatedByType,
		ModifiedByType,
		Active,
		SendToHP,
		SendToPCP,
		SendToNurture,
		SendToNone,
		LinkedFormType,
		LinkedFormID,
		NoteTypeID,
		CaseID,
		IsDelete
		)
	Select
		Concat( 
			Replace( @v_letter_name, ' Letter', '' ),
			Case
			When 
			IsNull(@v_member_firstname, '') = ''
			Or IsNull(@v_member_lastname, '') = ''
			Or IsNull(@v_city, '') = ''
			Or IsNull(@v_state, '') = ''
			Or IsNull(@v_postal_code, '') = ''
			Or (IsNull(@v_address1,'') = '' AND IsNull(@v_address2,'') = '') Then 
			' Letter Invalid Address, Letter Not Saved.' 
			Else  
			' Letter Auto Generated for Emerging High Cost.' 
			End
				),
		0,
		getDate(),
		'System',
		getDate(),
		@v_user_name,
		@v_mvd_id,
		'HP',
		'HP',
		1,
		0,
		0,
		0,
		0,
		NULL,
		@v_letter_member_id,
		@v_note_type_id,
		NULL,
		0								

		--To support batch logic
		Set @LetterCount += 1

		If @LetterCount >= @v_BatchSize
		break
	--End;

	--For testing purposes, process onee 
	--Break

	-- Get the next record
	Fetch Next From letter_cursor Into
		@v_mvd_id,
		@v_case_owner,
		@v_member_id,
		@v_member_firstname,
		@v_member_lastname,
		@v_member_name,
		@v_line_of_business,
		@v_cm_org_region,
		@v_branding_name,
		@v_company_name,
		@v_member_type,
		@v_date_of_birth,
		@v_letter_name;
End;

Close letter_cursor;
Deallocate letter_cursor;

End