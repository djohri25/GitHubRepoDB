/****** Object:  Procedure [dbo].[Get_MemberTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_MemberTask
(
	@p_MVDID varchar(20),
	@p_CaseID varchar(100),
	@p_ProcedureName nvarchar(100) = NULL,
	@p_TaskStatus varchar(100) = NULL,
	@p_MatchStatusYN bit = 1,
	@p_CustomerId int,
	@p_ProductId int,
	@p_ID bigint OUTPUT
)
AS
BEGIN
	DECLARE @v_quick_action_id bigint;

	EXEC Get_QuickActionID
		@p_ActionName = @p_ProcedureName,
		@p_ID = @v_quick_action_id OUTPUT,
		@p_CustomerId = @p_CustomerId,
		@p_ProductId = @p_ProductId;

	SELECT
    @p_ID = MAX( ct.ID )
	FROM
	(
	  SELECT DISTINCT
	  t.ID,
	  t.MVDID,
	  t.CaseID,
	  t.AutomationProcId,
	  t.CustomerId,
	  t.ProductId,
	  tal.TaskId,
	  FIRST_VALUE( tal.StatusId ) OVER ( PARTITION BY t.MVDID, tal.TaskId ORDER BY tal.ID DESC ) StatusId
	  FROM
	  Task t
	  INNER JOIN TaskActivityLog tal
	  ON tal.TaskId = t.id
	  WHERE
	  t.MVDID = @p_MVDID
	  AND
	  CASE
	  WHEN @p_CaseID IS NULL THEN 1
	  WHEN t.CaseID = @p_CaseID THEN 1
	  ELSE 0
	  END = 1
	  AND
	  CASE
	  WHEN @p_ProcedureName IS NULL THEN 1
	  WHEN t.AutomationProcId = @v_quick_action_id THEN 1
	  ELSE 0
	  END = 1
	) ct
	INNER JOIN Lookup_Generic_Code ts
	ON ts.CodeId = ct.StatusId
	WHERE
	ct.ID = ISNULL( @p_ID, ct.ID )
	AND
	CASE
	WHEN ts.label IS NULL THEN 1
	WHEN @p_MatchStatusYN = 1 AND ts.label LIKE @p_TaskStatus THEN 1
	WHEN @p_MatchStatusYN = 0 THEN 1
	ELSE 0
	END = 1	
	AND ct.CustomerId = @p_CustomerId
	AND ct.ProductId = @p_ProductId;

END;