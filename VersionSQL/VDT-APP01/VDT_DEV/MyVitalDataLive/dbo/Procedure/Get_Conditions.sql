/****** Object:  Procedure [dbo].[Get_Conditions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_Conditions] 
	@IceNumber varchar(15),
	@CheckedOnly bit = 0,
	@Language bit = 1
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT	MobileDescription, ConditionId, ConditionName, isChecked, RecordNumber, ReadOnly
	FROM
	(
		SELECT	RecordNumber,
				'Conditions' AS MobileDescription,
				l.ConditionId, 
				CASE @Language 
					WHEN 1 THEN l.ConditionName
					WHEN 0 THEN l.ConditionNameSpanish
				END AS ConditionName,
				CASE
					WHEN RecordNumber IS NOT NULL THEN CAST(1 AS bit)
					ELSE CAST(0 AS bit)
				END AS isChecked,
				ReadOnly
		FROM	(
					SELECT	*
					FROM	MainCondition
					WHERE	IceNumber = @IceNumber
				) AS m RIGHT JOIN
				LookupCondition AS l ON m.ConditionId = l.ConditionId
		WHERE	@CheckedOnly = 0 
				OR (@CheckedOnly = 1 AND m.IceNumber IS NOT NULL)
				
		UNION
		
		SELECT	RecordNumber,
				'Conditions' AS MobileDescription,
				ConditionId, 
				OtherName AS ConditionName,
				CAST(1 AS bit) AS isChecked,
				ReadOnly
		FROM	MainCondition
		WHERE	IceNumber = @IceNumber AND
				ConditionId IS NULL
	) AS t
	ORDER BY	ConditionName
END