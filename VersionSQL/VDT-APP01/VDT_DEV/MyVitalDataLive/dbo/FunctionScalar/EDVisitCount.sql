/****** Object:  Function [dbo].[EDVisitCount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[EDVisitCount]
	(
	@memberId NVARCHAR(50)
	)
RETURNS INT
BEGIN
/*
	8/28/2009, TThein:
		Given the health plan member id, EDVisitCount returns the number of visits to the ED made by the member,
		by combining the datetimes of patient lookups with the datetimes of ED claims from facilities.
		Only datetimes that are 1440 minutes (24 hours) apart from the previous datetime are counted.
		First datetime has no previous datetime and is always counted.

	10/27/2009, sw:
		Visit table has the full list of visits from claims and mvd lookups so use that table instead.
		New logic was used to determine ER visits
 */

	declare @mvdid varchar(20)

	select @mvdid = mvdid
	from Link_MemberId_MVD_Ins
	where insMemberID = @memberID

	RETURN
	(
		select count(id)
		from edVisitHistory
		where icenumber = @mvdid
			and visitType = 'ER'
	)

/* Procedure used untill 10/27/2009
	DECLARE @T TABLE
	(
		ID INT IDENTITY(1, 1) NOT NULL,
		DATE DATETIME NOT NULL
	)
	
	INSERT	@T (DATE)
	SELECT	a.Created AS DATE
	FROM	MVD_AppRecord AS a INNER JOIN Link_MemberId_MVD_Ins AS b ON a.MVDID = b.MVDId
	WHERE	InsMemberId = @memberId AND ResultCount = 1 AND a.Created >= DATEADD(YY, -1, GETUTCDATE())
	UNION
	SELECT	DISTINCT CAST([Serv From Date] AS DATETIME) AS DATE
	FROM	HPM_Import.dbo.Claims AS c LEFT JOIN LookupNPI AS n ON c.[Serv Prov NPI] = n.NPI
	WHERE	[Member ID] = @memberId AND CAST([Serv From Date] AS DATETIME) >= DATEADD(YY, -1, GETUTCDATE()) 
			AND (RIGHT([Rev Code], 3) LIKE '45%' OR [Procedure] IN ('99281','99282','99283','99284','99285'))
			AND (([Entity Type Code] IS NULL AND [Serv Prov First Name] = '') OR [Entity Type Code] = 2)
	ORDER BY DATE
		
	RETURN 
	(
		SELECT COUNT(*)
		FROM @T AS this LEFT JOIN @T AS previous ON this.ID = previous.ID + 1
		WHERE previous.DATE IS NULL OR previous.DATE < DATEADD(MI, -1440, this.DATE)
	)
*/

END