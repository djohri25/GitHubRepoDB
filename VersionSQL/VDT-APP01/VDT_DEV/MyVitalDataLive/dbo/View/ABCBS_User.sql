/****** Object:  View [dbo].[ABCBS_User]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW
[dbo].[ABCBS_User]
AS
SELECT DISTINCT
anu.ID,
anu.FirstName,
anu.LastName,
anu.Username,
anu.Email,
anu.PhoneNumber,
anu.JoinDate,
SUBSTRING
(
	(
		REPLACE
		(
			REPLACE
			(
				(
					SELECT
					CONCAT
					(
						', ',
						hpag.Name
					) Names
					FROM
					AspnetUsers u
					INNER JOIN link_hpalertgroupagent lhaga
					ON lhaga.Agent_ID = anu.ID
					INNER JOIN HPAlertGroup hpag
					ON hpag.ID = lhaga.Group_ID
					AND Cust_ID = 16
					WHERE
					u.ID = anu.ID
					ORDER BY
					hpag.Name
					FOR XML PATH ( '' )
				),
				'<Names>',
				''
			),
			'</Names>',
			''
		)
	),
	3,
	64000
) Groups
FROM
AspnetUsers anu
WHERE
CASE
WHEN anu.email LIKE 'ABCBS%' THEN 0
WHEN anu.email LIKE '%noemail%' THEN 1
WHEN anu.email LIKE '%email.com' THEN 1
WHEN anu.email LIKE '%vdtech%' THEN 1
WHEN anu.email LIKE '%vitaldatatech.com%' THEN 1
WHEN anu.email IS NULL THEN 0
ELSE 0
END = 0;