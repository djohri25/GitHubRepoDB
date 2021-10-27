/****** Object:  Procedure [dbo].[uspSelectCareQueue]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspSelectCareQueue] (@UserName nvarchar(256),
											@UserID nvarchar(128),
											@CustomerID int,
											@ProductID int
											)
AS
/*

Modifications:
WHO				WHEN		WHAT
?				?			Initial and ongoing development
Ed/Jose/Sunil	2021-01-29	Hot fix to implement parameter sniffing patch
Ed				2021-10-27	TFS1596 removed reference to CFT.OwnerGroup

EXEC uspSelectCareQueue 'executive1', '4B7BD117-F86D-4C64-B554-252EFC7EC2E7', 16, 2

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_username nvarchar(256) = @UserName;
	DECLARE @v_userid nvarchar(128) = @UserID;
	DECLARE @v_customer_id int = @CustomerID;
	DECLARE @v_product_id int = @ProductID;
	DECLARE @v_start_time datetime = getDate();
	DECLARE @v_end_time datetime;

-- By default, users can not see employee member data
	DECLARE @v_health_care_employee_override_yn bit = 0;
-- However, if the user is a member of the VDT_SECURITY_ABCBS group, they can see employee member data
	DECLARE @v_health_care_security_group nvarchar(255) = '%VDT_SECURITY_ABCBS%';
-- If the user has no care flow rules, we can exclude CareFlowTask from the query (for performance reasons)
	DECLARE @v_care_flow_rules_yn bit = 0;

/*
-- Check to see if this user can see employee member data
	SELECT	@v_health_care_employee_override_yn = MAX( 1 )
	FROM 	AspNetIdentityUAT.dbo.AspNetUserInfo
	WHERE 	UserId = @UserId
	AND		Groups LIKE @v_health_care_security_group;
*/

	SELECT @v_health_care_employee_override_yn = dbo.fnABCBSUserMemberCheck( @v_userid );

-- Check to see if this user has any care flow rules
	SELECT @v_care_flow_rules_yn = ISNULL( MAX(1), 0 )
	  FROM Link_HPAlertGroupAgent aga (readuncommitted)
	  JOIN HPAlertGroup ag (readuncommitted) ON ag.ID = aga.Group_ID
	   AND ag.Active = 1
	   AND ag.Cust_ID = @v_customer_id
	  JOIN Link_HPRuleAlertGroup rag (readuncommitted) ON rag.AlertGroup_ID = ag.ID
	  JOIN HPWorkFlowRule wfr (readuncommitted) ON wfr.Rule_ID = rag.Rule_ID
	   AND wfr.Active = 1
	   AND wfr.Cust_ID = @v_customer_id
	 WHERE aga.Agent_ID = @v_userid;

	IF ( @v_care_flow_rules_yn = 1 ) -- The user has care flow rules
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
					ccq.State,
					RTRIM(ccq.Region) as Region,
					ccq.CaseID,
					ccq.OpenCaseCount as NumOpenCases,
					ccq.OpenTaskCount as NumOpenTasks,
					ccq.CaseOwner,
					ccq.CaseProgram,
					CASE WHEN ISNULL( mo.UserID, '' ) = '' THEN NULL
						 ELSE mo.OwnerName
					 END MemberOwnedByUser,
					mo.GroupID,
					CASE WHEN ISNULL( mo.GroupID, '' ) = '' THEN NULL
						 ELSE mo.OwnerName
					 END MemberOwnedByGroup,
					CAST(CASE WHEN uomo.ID IS NULL THEN 0 ELSE 1 END AS bit) UserIsOtherOwnerYN,
					ccq.CMOrgRegion,
					ccq.CompanyKey,
					ccq.CompanyName,
					CASE WHEN IsNULL(cmm.MaternityRiskScore,0) > ISNULL( ccq.RiskGroupID, 0 ) THEN ISNULL(cmm.MaternityRiskScore,0) 
						 ELSE ISNULL( ccq.RiskGroupID, 0 ) 
					 END RiskScore,
					CONVERT(bit, ISNULL(ccq.HealthPlanEmployeeFlag, '0')) as IsHealthPlanEmployee,
					ccq.GrpInitvCd,
					m.CareQueueDate
			  FROM (-- Get members for which the user is either a primary or other owner; or, for which the user's group is either a primary or other owner
					SELECT DISTINCT
							u.MVDID,
							NULL CareFlowReasons,
							u.CareQueueDate
					  FROM	AspNetUsers anu (readuncommitted)
				 LEFT JOIN	(SELECT fmou.UserID,
									fmou.MVDID,
									NULL CareQueueDate
							   FROM Final_MemberOwner fmou (readuncommitted)
							  WHERE fmou.CustID = @v_customer_id
								AND fmou.OwnerType IN ( 'PRIMARY', 'OTHER' )
								AND fmou.IsDeactivated = 0
							  UNION
							 SELECT	aga.Agent_ID UserID,
									fmog.MVDID,
									NULL CareQueueDate
							   FROM	Link_HPAlertGroupAgent aga (readuncommitted)
							   JOIN Final_MemberOwner fmog (readuncommitted) ON fmog.CustID = @v_customer_id
								AND fmog.GroupID = aga.Group_ID
								AND fmog.OwnerType IN ( 'PRIMARY', 'OTHER' )
								AND fmog.IsDeactivated = 0
							) u
						ON  u.UserID = anu.ID
					 WHERE anu.ID = @v_userid
					 UNION -- Get members that satisfy the user's care flow rules
					SELECT DISTINCT	cft.MVDID,
						   wfr.Name RuleName,
						   cft.CreatedDate CareQueueDate
					  FROM Link_HPAlertGroupAgent aga (readuncommitted)
					  JOIN Link_HPRuleAlertGroup ag (readuncommitted) ON ag.AlertGroup_ID = aga.Group_ID
					  JOIN CareFlowTask cft (readuncommitted) ON cft.RuleID = ag.Rule_ID
					   AND cft.CustomerId = @v_customer_id
					   AND cft.ProductId = @v_product_id
					  JOIN HPWorkFlowRule wfr (readuncommitted) ON wfr.Rule_ID = cft.RuleId
						-- For some reason adding in the following clauses torpedoed performance; we should revisit at a later time
					   AND wfr.Cust_ID = @CustomerID
					   AND wfr.Active = 1
					 WHERE aga.Agent_ID = @v_userid
				   ) m
		 LEFT JOIN Final_MemberOwner mo (readuncommitted) ON mo.CustID = @v_customer_id
			   AND mo.MVDID = m.MVDID 
			   AND mo.OwnerType = 'PRIMARY'			-- Get the primary owner of the member
			   AND mo.IsDeactivated = 0				-- Exclude deactivated members
  		 LEFT JOIN Final_MemberOwner uomo (readuncommitted)	ON uomo.CustID = @v_customer_id
			   AND uomo.MVDID = m.MVDID
			   AND uomo.OwnerName = @v_username
			   AND uomo.OwnerType = 'OTHER'			-- Determine if this owner is an other member
			   AND uomo.IsDeactivated = 0				-- Exclude deactivated members
			  JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = m.MVDID
			   AND CASE WHEN ccq.HealthPlanEmployeeFlag = 0 THEN 1  -- Enforce privacy of employee members
						WHEN @v_health_care_employee_override_yn = 1 THEN 1
						ELSE 0
					END = 1
		 LEFT JOIN ComputedMemberMaternity cmm on cmm.mvdid = m.mvdid;
		 END;
	ELSE  -- The user has care no flow rules
		BEGIN  
			SELECT DISTINCT m.CareFlowReasons,
					ccq.MemberID,
					ccq.LastName MemberLastName,
					ccq.FirstName MemberFirstName,
					CONCAT( ccq.LastName, ', ', ccq.FirstName ) MemberName,
					LTRIM( RTRIM( m.MVDID ) ) MVDID,
					ISNULL( CONVERT( varchar, ccq.dob, 101 ), '' ) MemberDOB,
					ccq.LOB,
					ccq.PlanGroup as [Group],
					ccq.County,
					ccq.State,
					rtrim(ccq.Region) as Region,
					ccq.CaseID,
					ccq.OpenCaseCount as NumOpenCases,
					ccq.OpenTaskCount as NumOpenTasks,
					ccq.CaseOwner,
					ccq.CaseProgram,
					CASE WHEN ISNULL( mo.UserID, '' ) = '' THEN NULL
						 ELSE mo.OwnerName
					 END MemberOwnedByUser,
					mo.GroupID,
					CASE WHEN ISNULL( mo.GroupID, '' ) = '' THEN NULL
						 ELSE mo.OwnerName
					 END MemberOwnedByGroup,
					CAST(CASE WHEN uomo.ID IS NULL THEN 0 ELSE 1 END AS bit) UserIsOtherOwnerYN,
					ccq.CMOrgRegion,
					ccq.CompanyKey,
					ccq.CompanyName,
					CASE WHEN ISNULL(cmm.MaternityRiskScore,0) > ISNULL( ccq.RiskGroupID, 0 ) THEN ISNULL(cmm.MaternityRiskScore,0) 
					     ELSE ISNULL( ccq.RiskGroupID, 0 ) 
					 END RiskScore,
					CONVERT(bit, ISNULL(ccq.HealthPlanEmployeeFlag, '0')) as IsHealthPlanEmployee,
					ccq.GrpInitvCd,
					m.CareQueueDate
			  FROM  (--Get members where the user is either a primary or other owner 
			         --or for which the user's group is either a primary or other owner
						SELECT DISTINCT	u.MVDID,
								NULL CareFlowReasons,
								u.CareQueueDate
						  FROM AspNetUsers anu (readuncommitted)
					 LEFT JOIN (SELECT	fmou.UserID,
										fmou.MVDID,
										NULL CareQueueDate
								  FROM	Final_MemberOwner fmou (readuncommitted)
								 WHERE	fmou.CustID = @v_customer_id
								   AND	fmou.OwnerType IN ( 'PRIMARY', 'OTHER' )
								   AND  fmou.IsDeactivated = 0
								 UNION
								SELECT  aga.Agent_ID UserID,
										fmog.MVDID,
										NULL CareQueueDate
								  FROM 	Link_HPAlertGroupAgent aga (readuncommitted)
								  JOIN Final_MemberOwner fmog (readuncommitted)	ON fmog.CustID = @v_customer_id
								   AND fmog.GroupID = aga.Group_ID
								   AND fmog.OwnerType IN ( 'PRIMARY', 'OTHER' )
								   AND fmog.IsDeactivated = 0
								) u ON u.UserID = anu.ID
						 WHERE anu.ID = @v_userid
				    ) m
			LEFT JOIN Final_MemberOwner mo (readuncommitted) ON mo.CustID = @v_customer_id
				  AND mo.MVDID = m.MVDID
				  AND mo.OwnerType = 'PRIMARY' -- Get the primary owner of the member
				  AND mo.IsDeactivated = 0  -- Exclude deactivated members
			LEFT JOIN Final_MemberOwner uomo (readuncommitted) ON uomo.CustID = @v_customer_id
				  AND uomo.MVDID = m.MVDID
				  AND uomo.OwnerName = @v_username
				  AND uomo.OwnerType = 'OTHER'  -- Determine if this owner is an other member
				  AND uomo.IsDeactivated = 0  -- Exclude deactivated members
				 JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = m.MVDID
				  AND CASE WHEN ccq.HealthPlanEmployeeFlag = 0 THEN 1 -- Enforce privacy of employee members
						WHEN @v_health_care_employee_override_yn = 1 THEN 1
						ELSE 0
					   END = 1
			LEFT JOIN ComputedMemberMaternity cmm on cmm.mvdid = m.mvdid;
		 END;

	-- log performance statistics
	SET @v_end_time = GETDATE();
	INSERT INTO mvdSProcExecutionInfo (name,userid,username,customerid,productid,start_time,end_time)
	VALUES ('uspSelectCareQueue',@v_userid,@v_username,@v_customer_id,@v_product_id,@v_start_time, @v_end_time);

END;