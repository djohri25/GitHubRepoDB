/****** Object:  Procedure [dbo].[uspSelectCareQueue_20200911]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspSelectCareQueue_20200911]
(
	@UserName nvarchar(256),
	@UserID nvarchar(128),
	@CustomerID int,
	@ProductID int
)
AS
BEGIN
	DECLARE @v_start_time datetime = getDate();
	DECLARE @v_end_time datetime;

-- By default, users can not see employee member data
	DECLARE @v_health_care_employee_override_yn bit = 0;
-- However, if the user is a member of the VDT_SECURITY_ABCBS group, they can see employee member data
	DECLARE @v_health_care_security_group nvarchar(255) = '%VDT_SECURITY_ABCBS%';
-- If the user has no care flow rules, we can exclude CareFlowTask from the query (for performance reasons)
	DECLARE @v_care_flow_rules_yn bit = 0;

	SET NOCOUNT ON;

/*
-- Check to see if this user can see employee member data
	SELECT
	@v_health_care_employee_override_yn = MAX( 1 )
	FROM
	AspNetIdentity.dbo.AspNetUserInfo
	WHERE
	UserId = @UserId
	AND Groups LIKE @v_health_care_security_group;
*/

	SELECT @v_health_care_employee_override_yn = dbo.fnABCBSUserMemberCheck( @UserId );

-- Check to see if this user has any care flow rules
	SELECT
	@v_care_flow_rules_yn = ISNULL( MAX(1), 0 )
	FROM
	Link_HPAlertGroupAgent aga
	INNER JOIN HPAlertGroup ag
	ON ag.ID = aga.Group_ID
	AND ag.Active = 1
	AND ag.Cust_ID = @CustomerID
	INNER JOIN Link_HPRuleAlertGroup rag
	ON rag.AlertGroup_ID = ag.ID
	INNER JOIN HPWorkFlowRule wfr
	ON wfr.Rule_ID = rag.Rule_ID
	AND wfr.Active = 1
	AND wfr.Cust_ID = @CustomerID
	WHERE
	aga.Agent_ID = @UserID;

	IF ( @v_care_flow_rules_yn = 1 )
-- The user has care flow rules
	BEGIN
		SELECT DISTINCT
		m.CareFlowReasons,
		ccq.MemberID,
		ccq.LastName MemberLastName,
		ccq.FirstName MemberFirstName,
		CONCAT( ccq.LastName, ', ', ccq.FirstName ) MemberName,
		LTRIM( RTRIM( m.MVDID ) ) MVDID,
		ISNULL( CONVERT( varchar, ccq.dob, 101 ), '' ) MemberDOB,
		ccq.LOB ,
		ccq.PlanGroup as [Group],
		ccq.County,
		ccq.Region,
		ccq.CaseID,
		ccq.OpenCaseCount as NumOpenCases,
		ccq.OpenTaskCount as NumOpenTasks,
		ccq.CaseOwner,
		ccq.CaseProgram,
		CASE
		WHEN dbo.MVDIsNull( mo.UserID ) = 1 THEN NULL
		ELSE mo.OwnerName
		END MemberOwnedByUser,
		mo.GroupID,
		CASE
		WHEN dbo.MVDIsNull( mo.GroupID ) = 1 THEN NULL
		ELSE mo.OwnerName
		END MemberOwnedByGroup,
		CAST( CASE WHEN uomo.ID IS NULL THEN 0 ELSE 1 END AS bit ) UserIsOtherOwnerYN,
		ccq.CMOrgRegion,
		ccq.CompanyKey,
		ccq.CompanyName,
		ISNULL( ccq.RiskGroupID, 0 ) RiskScore
		FROM
		(
-- Get members for which the user is either a primary or other owner; or, for which the user's group is either a primary or other owner
			SELECT DISTINCT
			u.MVDID,
			NULL CareFlowReasons
			FROM
			AspNetIdentity.dbo.AspNetUsers anu
			LEFT OUTER JOIN
			(
				SELECT
				fmou.UserID,
				fmou.MVDID
				FROM
				Final_MemberOwner fmou
				WHERE
				fmou.OwnerType IN ( 'PRIMARY', 'OTHER' )
				AND fmou.IsDeactivated = 0
				UNION
				SELECT
				aga.Agent_ID UserID,
				fmog.MVDID
				FROM
				Link_HPAlertGroupAgent aga
				INNER JOIN Final_MemberOwner fmog
				ON fmog.GroupID = aga.Group_ID
				AND fmog.OwnerType IN ( 'PRIMARY', 'OTHER' )
				AND fmog.IsDeactivated = 0
			) u
			ON u.UserID = anu.ID
			WHERE
			anu.ID = @UserID
			UNION
-- Get members that satisfy the user's care flow rules
			SELECT DISTINCT
			cft.MVDID,
			wfr.Name RuleName
			FROM
			CareFlowTask cft
			INNER JOIN Link_HPAlertGroupAgent aga
			ON aga.Group_ID = cft.OwnerGroup
			AND aga.Agent_ID = @UserID
			INNER JOIN Link_HPRuleAlertGroup ag
			ON ag.AlertGroup_ID = aga.Group_ID
			AND ag.Rule_ID = cft.RuleID
			INNER JOIN HPWorkFlowRule wfr
			ON wfr.Rule_ID = cft.RuleId
-- For some reason adding in the following clauses torpedoed performance; we should revisit at a later time
/*
			AND wfr.Cust_ID = @CustomerID
			AND wfr.Active = 1
*/
			WHERE
			cft.CustomerId = @CustomerID
			AND cft.ProductId = @ProductID
			-- Need to include only tasks with status = active
			AND aga.Agent_ID = @UserID
		) m
		LEFT OUTER JOIN Final_MemberOwner mo
		ON mo.MVDID = m.MVDID
-- Get the primary owner of the member
		AND mo.OwnerType = 'PRIMARY'
-- Exclude deactivated members
		AND mo.IsDeactivated = 0
		LEFT OUTER JOIN Final_MemberOwner uomo
		ON uomo.MVDID = m.MVDID
-- Determine if this owner is an other member
		AND uomo.OwnerName = @UserName
		AND uomo.OwnerType = 'OTHER'
-- Exclude deactivated members
		AND uomo.IsDeactivated = 0
		INNER JOIN ComputedCareQueue ccq
		ON ccq.MVDID = m.MVDID
		AND
-- Enforce privacy of employee members
		CASE
		WHEN ccq.HealthPlanEmployeeFlag = 0 THEN 1
		WHEN @v_health_care_employee_override_yn = 1 THEN 1
		ELSE 0
		END = 1;
	END;
	ELSE
-- The user has care no flow rules; therefore, we can optimize the query
	BEGIN
		SELECT DISTINCT
		m.CareFlowReasons,
		ccq.MemberID,
		ccq.LastName MemberLastName,
		ccq.FirstName MemberFirstName,
		CONCAT( ccq.LastName, ', ', ccq.FirstName ) MemberName,
		LTRIM( RTRIM( m.MVDID ) ) MVDID,
		ISNULL( CONVERT( varchar, ccq.dob, 101 ), '' ) MemberDOB,
		ccq.LOB ,
		ccq.PlanGroup as [Group],
		ccq.County,
		ccq.Region,
		ccq.CaseID,
		ccq.OpenCaseCount as NumOpenCases,
		ccq.OpenTaskCount as NumOpenTasks,
		ccq.CaseOwner,
		ccq.CaseProgram,
		CASE
		WHEN dbo.MVDIsNull( mo.UserID ) = 1 THEN NULL
		ELSE mo.OwnerName
		END MemberOwnedByUser,
		mo.GroupID,
		CASE
		WHEN dbo.MVDIsNull( mo.GroupID ) = 1 THEN NULL
		ELSE mo.OwnerName
		END MemberOwnedByGroup,
		CAST( CASE WHEN uomo.ID IS NULL THEN 0 ELSE 1 END AS bit ) UserIsOtherOwnerYN,
		ccq.CMOrgRegion,
		ccq.CompanyKey,
		ccq.CompanyName,
		ISNULL( ccq.RiskGroupID, 0 ) RiskScore
		FROM
		(
-- Get members for which the user is either a primary or other owner; or, for which the user's group is either a primary or other owner
			SELECT DISTINCT
			u.MVDID,
			NULL CareFlowReasons
			FROM
			AspNetIdentity.dbo.AspNetUsers anu
			LEFT OUTER JOIN
			(
				SELECT
				fmou.UserID,
				fmou.MVDID
				FROM
				Final_MemberOwner fmou
				WHERE
				fmou.OwnerType IN ( 'PRIMARY', 'OTHER' )
				AND fmou.IsDeactivated = 0
				UNION
				SELECT
				aga.Agent_ID UserID,
				fmog.MVDID
				FROM
				Link_HPAlertGroupAgent aga
				INNER JOIN Final_MemberOwner fmog
				ON fmog.GroupID = aga.Group_ID
				AND fmog.OwnerType IN ( 'PRIMARY', 'OTHER' )
				AND fmog.IsDeactivated = 0
			) u
			ON u.UserID = anu.ID
			WHERE
			anu.ID = @UserID
		) m
		LEFT OUTER JOIN Final_MemberOwner mo
		ON mo.MVDID = m.MVDID
-- Get the primary owner of the member
		AND mo.OwnerType = 'PRIMARY'
-- Exclude deactivated members
		AND mo.IsDeactivated = 0
		LEFT OUTER JOIN Final_MemberOwner uomo
		ON uomo.MVDID = m.MVDID
-- Determine if this owner is an other member
		AND uomo.OwnerName = @UserName
		AND uomo.OwnerType = 'OTHER'
-- Exclude deactivated members
		AND uomo.IsDeactivated = 0
		INNER JOIN ComputedCareQueue ccq
		ON ccq.MVDID = m.MVDID
		AND
-- Enforce privacy of employee members
		CASE
		WHEN ccq.HealthPlanEmployeeFlag = 0 THEN 1
		WHEN @v_health_care_employee_override_yn = 1 THEN 1
		ELSE 0
		END = 1;
	END;

	set @v_end_time = getDate();
-- this allows us visibility to performance of the uspSelectCareQueue procedure
	insert into mvdSProcExecutionInfo
	(
		name,
		userid,
		username,
		customerid,
		productid,
		start_time,
		end_time
	)
	values
	(
		'uspSelectCareQueue',
		@userid,
		@username,
		@customerid,
		@productid,
		@v_start_time,
		@v_end_time
	);
END;