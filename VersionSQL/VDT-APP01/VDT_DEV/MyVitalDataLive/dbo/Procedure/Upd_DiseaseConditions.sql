/****** Object:  Procedure [dbo].[Upd_DiseaseConditions]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Updates condition record
	Arguments:
		@ICENUMBER - member Id
		@ConditionId - condition Id
		@ConditionName - condition Name
		@IsChecked - True is selected, False otherwise
	Note: Condition can be identified by Id or Name. Id is used when condition
		is one of the options from lookup table. Name is used when user entered 
		his own condition name.
*/
CREATE Procedure [dbo].[Upd_DiseaseConditions]

	@ICENUMBER varchar(15),
	@ConditionId int = null,
	@ConditionName varchar(50) = null,
	@IsChecked bit,
	@CreatedBy nvarchar(100) = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL
As

SET NOCOUNT ON

BEGIN

	DECLARE @Count int
	
	IF @IsChecked = 1
	BEGIN
		SELECT @Count = COUNT(*) FROM MainCondition WHERE 
			ICENUMBER = @IceNumber AND (OtherName = @ConditionName or ConditionId = @ConditionId)

		IF @Count = 0
		BEGIN						
			INSERT INTO MainCondition (ICENUMBER, ConditionId, OtherName, 
				CreationDate,CreatedBy,CreatedByOrganization,
				UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
			VALUES (@ICENUMBER, @ConditionId , @ConditionName , 
				GETUTCDATE(),@CreatedBy, @Organization,
				@UpdatedBy,@UpdatedByContact,@Organization)
		END
	END
	ELSE
	BEGIN
		if @conditionId is null or len(@conditionId) = 0 or @conditionId = 0
		begin
			DELETE MainCondition WHERE ICENUMBER = @IceNumber AND OtherName = @ConditionName
		end
		else
			DELETE MainCondition WHERE ICENUMBER = @IceNumber AND ConditionId = @ConditionId
	end
END