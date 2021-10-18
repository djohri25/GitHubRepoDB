/****** Object:  Procedure [dbo].[uspPrepareERvsUrgentCareLetter]    Committed by VersionSQL https://www.versionsql.com ******/

/*

Author:			Jose Pons
Create date:	2021-07-07
Description:	Generate data for ABCBS Batch Letters
				Letters:
					ER vs Urgent Care ASP Letter
					ER vs Urgent Care ASEPSE Letter
					ER vs Urgent Care FEP Letter
					ER vs Urgent Care ALOB Letter

--Exec [dbo].[uspPrepareERvsUrgentCareLetter]
--131344

Date				Modified			Description
20210707			Jose				Initial Version
20210728			Sunil Nokku			Remove Break 
20210730			Jose				Add batch logic

*/


CREATE Procedure [dbo].[uspPrepareERvsUrgentCareLetter]
@p_CustomerId int	= NULL,
@p_ProductId int	= NULL
As
Begin

Set NoCount On;

Declare
	@LetterCount					int					= 0,
	@BatchSize						int					= 2000		--Maximum number of letter every time


Declare 
	@v_user_name					nvarchar(255),
	@v_letter_name					nvarchar(255),
	@v_letter_delete_yn				nvarchar(50)		= 'N',
	@v_letter_flag					nvarchar(50)		= 'B',
	@v_letter_date					datetime			= getUTCDate(),
	@v_letter_member_id				bigint,
	@v_member_case_letter_id		bigint;

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
	@v_date_of_birth				date;

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

----To get the letter names 
--select * from LetterTemplate 
--order by LetterType


-- Get the candidate list of packets
Declare letter_cursor Cursor For
Select 
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
		End											[MemberType],
	ccq.[DOB]										[DateOfBirth],
	'ER vs Urgent Care ASP Letter'					[LetterName]
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
	ct.[RuleId] = 268
	And ccq.[CmOrGRegion] = 'ARSTATEPOLICE'
Union
Select 
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
		End											[MemberType],
	ccq.[DOB]										[DateOfBirth],
	'ER vs Urgent Care ASEPSE Letter'				[LetterName]
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
	ct.[RuleId] = 268
	And ccq.[CmOrGRegion] = 'ASEPSE'
Union
Select 
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
		End											[MemberType],
	ccq.[DOB]										[DateOfBirth],
	'ER vs Urgent Care FEP Letter'					[LetterName]
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
	ct.[RuleId] = 268
	And ccq.[CmOrGRegion] = 'FEP'
Union
Select 
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
		End											[MemberType],
	ccq.[DOB]										[DateOfBirth],
	'ER vs Urgent Care ALOB Letter'					[LetterName]
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
	ct.[RuleId] = 268
	And ccq.[CmOrGRegion] Not In ( 'FEP', 'ARSTATEPOLICE', 'ASEPSE', 'WALMART' )
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

----For testing purposes
--Select
--	@v_mvd_id,
--	@v_case_owner,
--	@v_member_id,
--	@v_member_firstname,
--	@v_member_lastname,
--	@v_member_name,
--	@v_line_of_business,
--	@v_cm_org_region,
--	@v_branding_name,
--	@v_company_name,
--	@v_member_type,
--	@v_date_of_birth,
--	@v_letter_name;


-- Iterate through the list
While @@FETCH_STATUS = 0
Begin
	Select 
		@v_member_case_letter_id	= NULL,
		@v_letter_member_id			= NULL;

	Exec dbo.[Get_MemberPreferredAddress]
		@p_MVDID				= @v_mvd_id,
		@p_Address1				= @v_address1		Output,
		@p_Address2				= @v_address2		Output,
		@p_City					= @v_city			Output,
		@p_State				= @v_state			Output,
		@p_PostalCode			= @v_postal_code	Output,
		@p_HomePhone			= @v_home_phone		Output,
		@p_CellPhone			= @v_cell_phone		Output,
		@p_WorkPhone			= @v_work_phone		Output,
		@p_FAX					= @v_fax			Output,
		@p_Email				= @v_email			Output,
		@p_Language				= @v_language		Output;

	Select
		@v_language = IsNull( @v_language, 'English' )

	----For testing purposes
	--Select 
	--	@v_mvd_id,
	--	@v_address1,
	--	@v_address2,
	--	@v_city		,
	--	@v_state	,
	--	@v_postal_code	,
	--	@v_home_phone	,
	--	@v_cell_phone	,
	--	@v_work_phone	,
	--	@v_fax			,
	--	@v_email		,
	--	@v_language		;


	-- Check to see if letter has already been sent
	Exec dbo.[Get_ABCBS_MemberContactLetter]
		@p_MVDID				= @v_mvd_id,
		@p_LetterName			= @v_letter_name,
		@p_ID					= @v_member_case_letter_id		Output,
		@p_LetterMemberID		= @v_letter_member_id			Output,
		@p_ContactFormID		= @v_cf_id						Output;

	----For testing purposes
	--Select
	--	@v_mvd_id,
	--	@v_letter_name,
	--	@v_member_case_letter_id	,
	--	@v_letter_member_id			,
	--	@v_cf_id					;

	-- If letter has already been sent, don't send it again
	If ( @v_member_case_letter_id Is Null )
	Begin
		-- Send the letter
		Set @v_user_name = @v_case_owner;

		Exec dbo.[uspABCBSMergeLetterMembers]
			@UserName					= @v_user_name,
			@MVDID						= @v_mvd_id,
			@MemberID					= @v_member_id,
			@MemberLOB					= @v_line_of_business,
			@MemberGroup				= NULL,
			@MemberCMOrgReg				= @v_cm_org_region,
			@MemberBrandingName			= @v_branding_name,
			@CompanyName				= @v_company_name,
			@MemberType					= @v_member_type,
			@MemberName					= @v_member_name,
			@MemberDOB					= @v_date_of_birth,
			@MemberAddress1				= @v_address1,
			@MemberAddress2				= @v_address2,
			@MemberCity					= @v_city,
			@MemberState				= @v_state,
			@MemberZip					= @v_postal_code,
			@LetterName					= @v_letter_name,
			@LetterDate					= @v_letter_date,
			@LetterLanguage				= @v_language,
			@LetterDelete				= @v_letter_delete_yn,
			@CareManagerName			= @v_case_owner,
			@CareManagerCredentials		= NULL,
			@CareManagerExtension		= NULL,
			@LetterFlag					= @v_letter_flag,
			@ID							= @v_letter_member_id	Output;

		----For testing purposes
		--Select 
		--	@v_user_name,
		--	@v_mvd_id,
		--	@v_member_id,
		--	@v_line_of_business,
		--	NULL,
		--	@v_cm_org_region,
		--	@v_branding_name,
		--	@v_company_name,
		--	@v_member_type,
		--	@v_member_name,
		--	@v_date_of_birth,
		--	@v_address1,
		--	@v_address2,
		--	@v_city,
		--	@v_state,
		--	@v_postal_code,
		--	@v_letter_name,
		--	@v_letter_date,
		--	@v_language,
		--	@v_letter_delete_yn,
		--	@v_case_owner,
		--	NULL,
		--	NULL,
		--	@v_letter_flag,
		--	@v_letter_member_id;


		Exec dbo.[uspABCBSUpdateLetterMembers]
			@ID							= @v_letter_member_id,
			@LetterDelete				= @v_letter_delete_yn,
			@LetterFlag					= @v_letter_flag;

		----For testing purposes
		--Select
		--	@v_letter_member_id,
		--	@v_letter_delete_yn,
		--	@v_letter_flag;

		-- Record that the letter was sent
		Exec dbo.[Set_ABCBS_MemberContactLetter]
			@p_ID						= @v_member_case_letter_id Output,
			@p_LetterMemberID			= @v_letter_member_id,
			@p_ContactFormID			= @v_cf_id;

		----For testing purposes
		--Select
		--	@v_member_case_letter_id,
		--	@v_letter_member_id,
		--	@v_cf_id;
			

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
						' Invalid Address Letter Not Saved.' 
					Else  
						' Letter Saved.' 
					End
				),
			0,
			getDate(),
			@v_user_name,
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

		If @LetterCount >= @BatchSize
		break
	End;

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


--select top 5 * 
--from lettermembers 
--where lettertype>4
--order by id desc


--select top 10 *
--from dbo.HPAlertNote
--order by id desc

--160348D2854CC4939640
--160423882636AC768501
--16044988B9B310945147


End;