/****** Object:  Procedure [dbo].[Check_UserTask]    Committed by VersionSQL https://www.versionsql.com ******/

--dpatel - 08/25/2020 update proc to return -1 in order to resolve bug.

CREATE PROCEDURE [dbo].[Check_UserTask]
	@Id bigint = NULL,
	@Title nvarchar(100) = NULL,
	@Narrative nvarchar(MAX) = NULL,
	@MVDID varchar(20) = NULL,
	@CustomerId int = NULL,
	@ProductId int = NULL,
	@Author varchar(100) = NULL,
	@Owner varchar(100) = NULL,
	@NewGroupOwner varchar(100) = NULL, 
	@IsDelete bit = 0, 
	@RecordID bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @RecordID = -1;
--	IF ( @ID IS NOT NULL )
--	BEGIN
---- If we find the record
--		SELECT
--		@RecordID =
--			CASE
---- and it's not deleted then return 0
--			WHEN dbo.MVDIsNULL( IsDelete ) = 1 THEN 0
--			WHEN IsDelete = 0 THEN 0
---- and it is deleted then return ID
--			ELSE ID
--			END
--		FROM
--		Task
--		WHERE
--		ID = @ID;
--	END
--	ELSE
--	BEGIN
---- If we find the record
--		SELECT
--		@RecordID =
--			CASE
---- and it's not deleted then return 0
--			WHEN dbo.MVDIsNULL( IsDelete ) = 1 THEN 0
--			WHEN IsDelete = 0 THEN 0
---- and it is deleted then return ID
--			ELSE ID
--			END
--		FROM
--		Task
--		WHERE
--		MVDID = @MVDID
--		AND Title = @Title
--		AND Narrative = @Narrative
--		AND Author = @Author
--		AND CustomerId = @CustomerId
--		AND ProductId = @ProductId;
--	END;

---- If we don't find a record
--	IF ( @RecordID IS NULL )
--	BEGIN
---- then return -1
--		SET @RecordID = -1;
--	END;
END;