/****** Object:  Procedure [dbo].[Get_HPAgentAlertGroups]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HPAgentAlertGroups]
	@AgentID varchar(50) = NULL,
	@CustomerID int = NULL,
	@Active bit = NULL,
-- For assignment of a member to a group, we must insure that all members of the group have security access
-- By default if the IsEmployee parameter is not set, we return all groups
	@IsEmployee bit = 0

AS
BEGIN
	SET NOCOUNT ON;

--Return all groups from HPAlertGroup table for the customer, agent and active
	IF ( @AgentID IS NULL )
	BEGIN
		SELECT
		id,
		CustomerId,
		name,
		Description,
		Active
		FROM
		(
			SELECT DISTINCT
			CAST( hpag.ID AS int ) id,
			hpag.Cust_ID CustomerId,
			hpag.Name name,
			hpag.Description,
			hpag.Active,
/*
-- secure_yn will only be 1 if all members of the group have security access
			MIN( CAST( dbo.fnABCBSUserMemberCheck( lhpaga.Agent_ID ) AS int ) ) OVER ( PARTITION BY hpag.ID ) secure_yn
*/
			1 secure_yn
			FROM
			HPAlertGroup hpag
			LEFT OUTER JOIN Link_HPAlertGroupAgent lhpaga
			ON lhpaga.Group_ID = hpag.ID
			WHERE
			ISNULL( hpag.Cust_ID, -1 ) = ISNULL( @CustomerID, ISNULL( hpag.Cust_ID, -1 ) )
			AND hpag.Active = ISNULL( @Active, hpag.Active )
		) g
		WHERE
		CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN g.secure_yn = 1 THEN 1
		ELSE 0
		END = 1;
	END
	ELSE
	BEGIN
		SELECT
		id,
		CustomerId,
		name,
		Description,
		Active
		FROM
		(
			SELECT DISTINCT
			CAST( hpag.ID AS int ) id,
			hpag.Cust_ID CustomerId,
			hpag.Name name,
			hpag.Description,
			hpag.Active,
/*
-- secure_yn will only be 1 if all members of the group have security access
			MIN( CAST( dbo.fnABCBSUserMemberCheck( lhpaga.Agent_ID ) AS int ) ) OVER ( PARTITION BY hpag.ID ) secure_yn
*/
			1 secure_yn
			FROM
			HPAlertGroup hpag
			LEFT OUTER JOIN Link_HPAlertGroupAgent lhpaga
			ON lhpaga.Group_ID = hpag.ID
			WHERE
			ISNULL( hpag.Cust_ID, -1 ) = ISNULL( @CustomerID, ISNULL( hpag.Cust_ID, -1 ) )
			AND hpag.Active = ISNULL( @Active, hpag.Active )
		) g
		INNER JOIN Link_HPAlertGroupAgent hpaga
		ON hpaga.Group_ID = g.id
		AND hpaga.Agent_ID = @AgentID
		WHERE
		CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN g.secure_yn = 1 THEN 1
		ELSE 0
		END = 1;
	END;
END;