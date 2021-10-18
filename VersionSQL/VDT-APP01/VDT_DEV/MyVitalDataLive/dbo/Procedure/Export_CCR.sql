/****** Object:  Procedure [dbo].[Export_CCR]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sylvester Wyrzykowski
-- Create date: 05/08/2009
-- Description:	Export MyVitalData record for the 
--	member identified by @MVDID (MyVitalData ID)
--	in XML format. 
-- =============================================
CREATE PROCEDURE [dbo].[Export_CCR]
	@MVDId varchar(20),
	@MedicationsPermitted bit,		-- set to 1 if user permitted to share that data
	@SurgeriesPermitted bit,
	@InsurancePermitted bit,
	@ConditionPermitted bit,
	@RecordCount int OUT,
	@XmlOutput varchar(max) OUT
as 
begin

declare @_patientNode xml, 
	@_conditionNode xml,
	@_medicationNode xml,
	@_procedureNode xml,
	@_encounterNode xml,
	@_payerNode xml,
	@_actorList xml,
	@_patientActorID int,		-- id of the record with patient as actor
	@_curObjID int,				-- unique identifier of each object in CCR
	@_mvdActorID int,			-- id of the record with MVD as actor
	@Result XML,
	@Header varchar(1000),
	@Footer varchar(100)

create table #tempActors 
(
	id int, 
	actorType int,				-- 1 - person, 2 - organization
	NPI varchar(20),
	IDProvider int,
	DataProvider int,			-- who provided data about actor
	organizationName varchar(250),	
	firstName varchar(250),
	lastName varchar(250),
	title varchar(50),
	fullName varchar(500),
	actorRole varchar(50),		-- set to 'Patient' when record contains data of a person the CCR is generated for
	credentials varchar(50),
	address1 varchar(50),
	address2 varchar(50),
	city  varchar(50),
	state  varchar(2),
	zip	 varchar(50),
	Phone varchar(10),
	Fax varchar(50),
	isProcessed bit
)

--select @MVDId = 'H68QM79EY2',
--	@MedicationsPermitted = 1,
--	@SurgeriesPermitted = 1,
--	@InsurancePermitted = 1,
--	@ConditionPermitted = 1 


set @_curObjID = 0

-- When namespace was specified in the main query, the xmlns attribute was added to child nodes of the root.
-- Workaround add header and rooter at the very end
select @Header = '<ContinuityOfCareRecord xmlns="urn:astm-org:CCR" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:astm-org:CCR CCR1.0.xsd">',
	@Footer = '</ContinuityOfCareRecord>'

select @RecordCount = count(icenumber) from mainpersonaldetails where ICENUMBER = @mvdid

if(@RecordCount = 1)
begin

	-- Get patient node
	EXEC get_ccrPatient
		@MVDId = @MVDId,
		@PatientNode = @_patientNode output

	-- Get procedure node
	if(@InsurancePermitted = 1)
	begin
		EXEC get_ccrPayers
			@MVDId = @MVDId,
			@PayerNode = @_payerNode output,
			@curObjID = @_curObjID output
	end

	-- Get condition node
	if(@ConditionPermitted = 1)
	begin 
		EXEC get_ccrConditions
			@MVDId = @MVDId,
			@ConditionNode = @_conditionNode output,
			@curObjID = @_curObjID output
	end

	-- Get medication node
	if(@MedicationsPermitted = 1)
	begin
		EXEC get_ccrMedications
			@MVDId = @MVDId,
			@MedicationNode = @_medicationNode output,
			@curObjID = @_curObjID output
	end

	-- Get procedure node
	if(@SurgeriesPermitted = 1)
	begin
		EXEC get_ccrProcedures
			@MVDId = @MVDId,
			@ProcedureNode = @_procedureNode output,
			@curObjID = @_curObjID output
	end

	-- Get procedure node
	EXEC get_ccrEncounters
		@MVDId = @MVDId,
		@EncounterNode = @_encounterNode output,
		@curObjID = @_curObjID output

	-- Set MVD as actor because it is an organization providing CCR
	if exists (select id from #tempActors where OrganizationName = 'MyVitalData')
	begin
		select @_mvdActorID = id from #tempActors where OrganizationName = 'MyVitalData'

		update #tempActors
		set actorType = '2',
			address1 = '120 Newport Center Drive',
			address2 = 'Suite 240',
			city = 'Newport Beach',
			state = 'CA',
			zip = '92660',
			Phone = '9497199014'	
		where id = @_mvdActorID
	end
	else
	begin
		select @_mvdActorID = isnull(max(id),0) + 1
		from #tempActors

		insert into #tempActors
		(
			id, 
			actorType,
			organizationName,	
			address1,
			address2,
			city,
			state,
			zip,
			Phone
		)
		values
		(
			@_mvdActorID,
			'2',		-- organization
			'MyVitalData',
			'120 Newport Center Drive',
			'Suite 240',
			'Newport Beach',
			'CA',
			'92660',
			'9497199014'
		)
	end

	-- Fill in addition info about actors
	EXEC Upd_CCRActors
		@MVDId = @MVDId

	-- Get actor nodes
	EXEC get_ccrActors
		@actorList = @_actorList output

	--select @_actorList

	select @_patientActorID = ID from #tempActors where actorRole = 'Patient'

	declare @x xml


	select @Result = 
	(
		select 
			-- CCR HEADER
			newID() as CCRDocumentObjectID,
			'English' as 'Language/Text',
			'V1.0' as Version,
			left(CONVERT(VARCHAR(50),getutcdate(),126),19) + 'Z' as 'DateTime/ExactDateTime'	-- Time is UTC
			,					
			@_patientActorID as 'Patient/ActorID',
			(
				select @_mvdActorID as ActorID,
					(
						select 'EHR System' as Text
						FOR XML PATH('ActorRole'), TYPE, ELEMENTS
					)
				FOR XML PATH('ActorLink'), TYPE, ELEMENTS --TODO Required, maybe HPM or mvd
			) as [From],
			-- CCR BODY
			(
				select 
					@_payerNode,
					@_conditionNode,
					@_medicationNode,
					@_procedureNode,
					@_encounterNode
				FOR XML PATH('Body'), TYPE, ELEMENTS
			),

			-- CCR FOOTER					
			(
					select 		

						@_patientNode,
						@_actorList		

					FOR XML PATH('Actors'), TYPE, ELEMENTS

			)
		FOR XML PATH(''), TYPE, ELEMENTS
	)
end
--select * from #tempActors

drop table #tempActors

SET @XmlOutput = @Header + CONVERT(VARCHAR(MAX),@RESULT) + @Footer

--select @RESULT

end