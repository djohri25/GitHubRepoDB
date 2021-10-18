/****** Object:  Procedure [dbo].[GET_RecentActivatedAssignedUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Raghu C
-- Create date: 08/29/19
-- Description:	Get Active MMF 
-- exec Get_ActiveMMF '16577456118885332'
-- =============================================
create PROCEDURE [dbo].[GET_RecentActivatedAssignedUser]
	
	@MVDID varchar(30) null	,
	@CustID int null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
	Declare @isdifferentUserPrimaryAvailable varchar (100);
	Declare @selectedRecordID int;

	select top 1 @isdifferentUserPrimaryAvailable = ID from Final_MemberOwner where CustID= @CustID and MVDID= @MVDID and IsDeactivated =0 and OwnerType ='Primary'
	select top 1 @selectedRecordID = ID from Final_MemberOwner where  MVDID=@MVDID and CustID= @CustID and IsDeactivated = 0 order by StartDate Desc;


	if(@isdifferentUserPrimaryAvailable is null)
		BEGIN
			update Final_MemberOwner  set OwnerType= 'Primary' where MVDID=@MVDID and CustID= @CustID and ID = @selectedRecordID 		
		END
	
END