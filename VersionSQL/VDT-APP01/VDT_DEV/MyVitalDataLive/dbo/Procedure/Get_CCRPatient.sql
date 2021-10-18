/****** Object:  Procedure [dbo].[Get_CCRPatient]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 5/4/2009
-- Description:	Returns patient personal information
--	formated as XML according to CCR standard. 
--	It also updates list of CCR actors
-- =============================================
CREATE PROCEDURE [dbo].[Get_CCRPatient]
	@MVDID varchar(20),
	@patientNode xml output
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempActorID int,
		@isValid bit,
		@firstName varchar(50),
		@lastName varchar(50),
		@CreatedBy nvarchar(250),
		@CreatedByOrganization varchar(250),
		@CreatedByNPI varchar(20),
		@UpdatedBy nvarchar(250),
		@UpdatedByNPI varchar(20),
		@UpdatedByOrganization varchar(250),
		@UpdatedByContact nvarchar(64)

	select @patientNode = '',
		@IsValid = 0

	select @tempActorID = isnull(max(id),0) + 1
	from #tempActors

	select 
		@firstName = firstName,
		@lastName = lastName,
		@CreatedBy = CreatedBy,
		@CreatedByOrganization = CreatedByOrganization,
		--@CreatedByNPI = CreatedByNPI,
		@UpdatedBy = UpdatedBy,
		--@UpdatedByNPI = UpdatedByNPI,
		@UpdatedByOrganization = UpdatedByOrganization,
		@UpdatedByContact = UpdatedByContact
	from mainpersonaldetails 
	where ICENUMBER = @MVDID

	insert into #tempActors(
		id, 
		actorType,
		firstName,
		lastName,
		fullName,
		actorRole
	)
	values(
		@tempActorID,
		1,
		@firstName,
		@lastName,
		isnull(@firstName + ' ','') + isnull(@lastName, ''),
		'Patient'
	)

	-- Set Data Provider
	EXEC Set_CCRActors 
		@CreatedBy = @CreatedBy,
		@CreatedByOrganization = @CreatedByOrganization,
		@CreatedByNPI = @CreatedByNPI,
		@UpdatedBy = @UpdatedBy,
		@UpdatedByOrganization = @UpdatedByOrganization,
		@UpdatedByNPI = @UpdatedByNPI,
		@UpdatedByContact = @UpdatedByContact,
		@ActorID = @tempActorID output,
		@IsValid = @IsValid output

	select @patientNode =
	(
		select 
			-- TODO: verify if correct
			@tempActorID as ActorObjectID,				
			(
				select
					(
						select
							FirstName as 'Given',
							LastName as 'Family'
						FOR XML PATH('CurrentName'), TYPE, ELEMENTS
					) as Name,						
					(
						case isnull(DOB,'')
						when '' then null
						else 
						(
							select DOB as ExactDateTime								
							FOR XML PATH(''), TYPE, ELEMENTS								
						)
						END
					) as DateOfBirth,						
					CASE ISNULL(GenderID,'')
						WHEN '' THEN 'Unknown'
						WHEN '0' THEN 'Unknown'
						ELSE 
						(
							SELECT a.GENDERNAME FROM dbo.LookupGenderID a WHERE a.GENDERID = mpd.GENDERID
						)
					END AS 'Gender/Text'
				FOR XML PATH('Person'), TYPE, ELEMENTS	
			)
			,
			(
				case isnull(SSN,'')
				when '' then null
				else 
				(
					select	
						'SecurityNumber' as 'Type/Text',
						SSN as ID,
						dbo.Get_CCRFormatSource(@tempActorID,null)
					FOR XML PATH(''), TYPE, ELEMENTS								
				)
				END
			) as IDs,						
			(
				-- If any part of address is present include the Address node
				case isnull(Address1,'') + isnull(Address1,'') + isnull(City,'') + isnull(State,'') + isnull(PostalCode,'')
				when '' then null
				else 
				(
					select	
						(
							select 
								'Home' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS
						),
						Address1 as Line1,
						Address2 as Line2,
						City as City,
						State,
						'USA' as Country,
						PostalCode									
					FOR XML PATH(''), TYPE, ELEMENTS								
				)
				END
			) as Address,						
			(
				select 
				(
					case isnull(HomePhone,'')
					when '' then null
					else 
					(
						select HomePhone as [Value],
						(
							select 'Home' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS
						)
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as Telephone								
				from mainPersonalDetails where ICENUMBER = @MVDId
				FOR XML PATH(''), TYPE, ELEMENTS
			),
			(
				select 
				(
					case isnull(CellPhone,'')
					when '' then null
					else 
					(
						select CellPhone as [Value],
						(
							select 'Mobile' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS
						)
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as Telephone								
				from mainPersonalDetails where ICENUMBER = @MVDId
				FOR XML PATH(''), TYPE, ELEMENTS
			),
			(
				select 
				(
					case isnull(WorkPhone,'')
					when '' then null
					else 
					(
						select WorkPhone as [Value],
						(
							select 'Work' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS
						)
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as Telephone								
				from mainPersonalDetails where ICENUMBER = @MVDId
				FOR XML PATH(''), TYPE, ELEMENTS
			),
			(
				case isnull(email,'')
				when '' then null
				else 
				(
					select email as [Value]
					FOR XML PATH(''), TYPE, ELEMENTS								
				)
				END
			) as EMail,
			dbo.Get_CCRFormatSource(@tempActorID,null)
		from mainPersonalDetails mpd
		where ICENUMBER = @MVDId
		FOR XML PATH('Actor'), TYPE, ELEMENTS	
										
	)

END