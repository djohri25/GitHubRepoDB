/****** Object:  Procedure [dbo].[CPCreateBlankMemberCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Create a blank member-level careplan
-- updated 2019-10-02 to use program type
-- =============================================
CREATE PROCEDURE [dbo].[CPCreateBlankMemberCarePlan]
	@CustID as varchar(10), 
	@MVDID as varchar(50), 
	@username as varchar(100), 
	@CreateIfNone as smallint,  -- 0 = do not create, 1 = create if none, with children, 2 = create if none, without children, 3 = force create new with children
	@programtype as varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- based on the username or cust_id we should be able to retrieve the libraryID in use
    declare @libraryID as smallint = 1
	declare @newCPId as bigint = -1

    insert into MainCarePlanMemberIndex (Cust_ID, MVDID,cpLibraryID, CarePlanDate, Author, CreatedDate, CreatedBy, CarePlanType)
           values(@CustID, @MVDID, @libraryID, SYSUTCDATETIME( ), @username, SYSUTCDATETIME( ), @username, @programtype)

	SELECT @newCPId = SCOPE_IDENTITY()

    if (@newCPId > -1)
		if (@CreateIfNone = 1 or @CreateIfNone = 3)
			EXEC dbo.CPAddMemberCarePlanProblem @libraryID,@newCPId, @username, -1

    return @newCPId
END