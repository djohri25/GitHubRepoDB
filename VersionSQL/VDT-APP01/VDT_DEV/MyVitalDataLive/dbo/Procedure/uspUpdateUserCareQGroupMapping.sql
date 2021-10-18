/****** Object:  Procedure [dbo].[uspUpdateUserCareQGroupMapping]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateUserCareQGroupMapping]
	@userId nvarchar(50),
	@groupName nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_num_insert bigint;
	DECLARE @v_num_delete bigint;

/*	
	delete from Link_HPAlertGroupAgent where Agent_ID = @userId
    
	Insert into Link_HPAlertGroupAgent(Group_ID,Agent_ID)
	select hag.ID, @userId
	from HPAlertGroup hag
	where hag.[Name] in (select * from string_split(@groupName,','))
*/

	SELECT
	@v_num_delete = count(1)
	FROM
	(
		SELECT
		Group_ID,
		Agent_ID
		FROM
		Link_HPAlertGroupAgent
		WHERE
		Agent_ID = @userId
		EXCEPT
		select hag.ID Group_ID,
		@userId Agent_ID
		from HPAlertGroup hag
		where hag.[Name] in (select * from string_split(@groupName,','))
	) s;

	IF ( @v_num_delete > 0 )
	BEGIN
		MERGE INTO
		Link_HPAlertGroupAgent d
		USING
		(
			SELECT
			Group_ID,
			Agent_ID
			FROM
			Link_HPAlertGroupAgent
			WHERE
			Agent_ID = @userId
			EXCEPT
			select hag.ID Group_ID,
			@userId Agent_ID
			from HPAlertGroup hag
			where hag.[Name] in (select * from string_split(@groupName,','))
		) s
		ON
		(
			s.Agent_ID = d.Agent_ID
			AND s.Group_ID = d.Group_ID
		)
		WHEN MATCHED THEN
		DELETE;
	END;

	SELECT
	@v_num_insert = count(1)
	FROM
	(
		select hag.ID Group_ID,
		@userId Agent_ID
		from HPAlertGroup hag
		where hag.[Name] in (select * from string_split(@groupName,','))
		EXCEPT
		SELECT
		Group_ID,
		Agent_ID
		FROM
		Link_HPAlertGroupAgent
		WHERE
		Agent_ID = @userId
	) s;

	IF ( @v_num_insert > 0 )
	BEGIN
		MERGE INTO
		Link_HPAlertGroupAgent d
		USING
		(
			select hag.ID Group_ID,
			@userId Agent_ID
			from HPAlertGroup hag
			where hag.[Name] in (select * from string_split(@groupName,','))
			EXCEPT
			SELECT
			Group_ID,
			Agent_ID
			FROM
			Link_HPAlertGroupAgent
			WHERE
			Agent_ID = @userId
		) s
		ON
		(
			s.Agent_ID = d.Agent_ID
			AND s.Group_ID = d.Group_ID
		)
		WHEN NOT MATCHED THEN
		INSERT
		(
			Group_ID,
			Agent_ID
		)
		VALUES
		(
			s.Group_ID,
			s.Agent_ID
		);
	END;
END;