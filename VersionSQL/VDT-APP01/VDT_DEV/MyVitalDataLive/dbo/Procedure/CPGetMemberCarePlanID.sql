/****** Object:  Procedure [dbo].[CPGetMemberCarePlanID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Get the unique Member-level careplan, optionally creating it and its children
-- updated 2019-10-02 to use program type
-- =============================================
CREATE PROCEDURE [dbo].[CPGetMemberCarePlanID] 
	@CustID as varchar(10), 
	@MVDID as varchar(50), 
	@CPID as bigint, 
	@username as varchar(100), 
	@CreateIfNone as smallint,  -- 0 = do not create, 1 = create if none, with children, 2 = create if none, without children, 3 = force create new with children
	@programtype as varchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	declare @rslt as bigint = -1

	if (@CPID > 0)
	begin
		select @rslt = CarePlanID from MainCarePlanMemberIndex where CarePlanID= @CPID and CarePlanStatus < 1
	end
	else
	begin
		if exists (select CarePlanID from MainCarePlanMemberIndex where MVDID = @MVDID and CarePlanStatus < 1 and UPPER(RTRIM(CarePlanType)) = UPPER(RTRIM(@programtype)))
		begin
			select @rslt = CarePlanID from MainCarePlanMemberIndex where MVDID = @MVDID and CarePlanDate = (select max(CarePlanDate) from MainCarePlanMemberIndex where MVDID = @MVDID and CarePlanStatus < 1 and UPPER(RTRIM(CarePlanType)) = UPPER(RTRIM(@programtype)))
			return @rslt
		end
	end

	if (@rslt < 1)
	begin
		if (@CreateIfNone > 0)
		begin
			EXEC @rslt = dbo.CPCreateBlankMemberCarePlan @CustID, @MVDID, @username, @CreateIfNone, @programtype
			-- SET @rslt = SCOPE_IDENTITY()
			return @rslt
		end
	end
END