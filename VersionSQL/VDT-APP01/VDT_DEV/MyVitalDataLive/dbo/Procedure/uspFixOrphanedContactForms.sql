/****** Object:  Procedure [dbo].[uspFixOrphanedContactForms]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspFixOrphanedContactForms
AS
BEGIN
	DECLARE @v_form_type varchar(255) = 'ARBCBS_Contact';

	MERGE INTO
	HPAlertNote d
	USING
	(
		SELECT
		cf.ID,
		cf.MVDID,
		cf.FormAuthor,
		cf.q7ContactSuccess,
		cf.q2Program,
		cf.q4ContactType
		FROM
		ARBCBS_Contact_Form cf (readuncommitted)
		LEFT OUTER JOIN HPAlertNote hpan (readuncommitted)
		ON hpan.linkedformtype = @v_form_type
		AND hpan.linkedformid = cf.id
		WHERE
		hpan.id IS NULL
	) s
	ON
	(
		d.LinkedFormType = @v_form_type
		AND d.LinkedFormID = s.ID
	)
	WHEN NOT MATCHED THEN INSERT
	(
		AlertID,
		Note,
		AlertStatusID,
		DateCreated,
		CreatedBy,
		DateModified,
		ModifiedBy,
		CreatedByCompany,
		ModifiedByCompany,
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
		ActionTypeID,
		DueDate,
		CompletedDate,
		NoteTimestampId,
		NoteSourceId,
		SendToMyVitalDataMobile,
		SendToOHIT,
		SendToState,
		SendToDMVendor,
		CaseID,
		IsDelete,
		SessionID,
		DocType
	)
	VALUES
	(
		NULL, -- AlertID
		CONCAT
		(
			CASE WHEN s.q7ContactSuccess = 'Yes' THEN 'Successful' ELSE 'Unsuccessful' END,
			' Contact | ',
			s.q2Program, ' | ',
			s.q4ContactType
		), -- Note
		0, -- AlertStatusID
		getDate(), -- DateCreated
		s.FormAuthor, -- CreatedBy
		getDate(), -- DateModified
		s.FormAuthor, -- ModifiedBy
		NULL, -- CreatedByCompany
		NULL, -- ModifiedByCompany
		s.MVDID, -- MVDID
		'HP', -- CreatedByType
		'HP', -- ModifiedByType
		1, -- Active
		0, -- SendToHP
		0, -- SendToPCP
		0, -- SendToNurture
		0, -- SendToNone
		@v_form_type, -- LinkedFormType
		s.ID, -- LinkedFormID
		175, -- NoteTypeID
		NULL, -- ActionTypeID
		NULL, -- DueDate
		NULL, -- CompletedDate
		NULL, -- NoteTimestampId
		NULL, -- NoteSourceId
		NULL, -- SendToMyVitalDataMobile
		NULL, -- SendToOHIT
		NULL, -- SendToState
		NULL, -- SendToDMVendor
		NULL, -- CaseID
		0, -- IsDelete
		NULL, -- SessionID
		NULL -- DocType
	);

END;