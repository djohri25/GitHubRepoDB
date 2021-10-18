/****** Object:  Procedure [dbo].[UPDATE_AssignedUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Save Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_AssignedUser]
    @ID int,
	@AssignedBy varchar(100)=null,
	@MVDID varchar(30)=null,
	@OwnerType varchar(50)=null,
	@FirstName varchar(100)=null,
	@LastName varchar(100)=null,
	@User varchar(100)=NULL,
	@StartDate varchar(100)=NULL,
	@EndDate varchar(100)=NULL,	
	@CustID int=null,
	--@IsPrimary bit,
	@IsDeactivated bit,
	@IsEntityFromMMF bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @isAnyExistingMMF int;
	Declare @selectedRecordID int;	
	DECLARE @v_assignment_type_code_at int;

	SELECT
	@v_assignment_type_code_at = CodeID
	FROM
	Lookup_Generic_Code_Type lgct
	INNER JOIN Lookup_Generic_Code lgc
	ON lgc.CodeTypeID = lgct.CodeTypeID
	AND lgc.Label = 'AT'
	WHERE
	lgct.CodeType = 'AssignmentType';
	
	if(@isEntityFromMMF = 0)
		BEGIN				
			UPDATE
			Final_MemberOwner
			SET
			IsDeactivated = 1,
			UpdatedDate = @EndDate,
			EndDate = @EndDate
			where
			MVDID = @MVDID
			and CustID = @CustID
			and ID = @ID
			and AssignmentTypeCodeID = @v_assignment_type_code_at;
		END

	IF(@IsEntityFromMMF = 1)
		BEGIN
			update
			Final_MemberOwner
			SET
			IsDeactivated = 1,
			UpdatedDate=@EndDate,
			EndDate = @EndDate
			where
			MVDID = @MVDID
			and CustID = @CustID
			and OwnerName = @User
			and IsDeactivated = 0;
	    END
END