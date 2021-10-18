/****** Object:  Procedure [dbo].[Set_MemberAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC [dbo].[Set_MemberAdditionalInfo]
(
	@Cust_ID	INT,
	@MVDID	VARCHAR(20),
	@InsMemberID varchar(30),
	@Homeless [varchar](100),
	@PCP [varchar](100) ,
	@Household_size [int],
	@Housing_Status [varchar](50),
	@CitizenshipStatus [varchar](50),
	@FPL_Level [varchar](50),
	@ProgramHandle [varchar](50),
	@Action CHAR(1)	OUTPUT,
	@Result int OUTPUT
)
AS
---------------------------------------------------------------------------------------------------
-- Name				Date			Description
-- PPetluri			09/23/2016		To Load Member Additional Info
---------------------------------------------------------------------------------------------------
BEGIN
SET NOCOUNT ON;

	IF EXISTS (Select 1 FROM CCC_MemberAdditionalInfo WHERE ICENUMBER = @MVDID)
	BEGIN
	SET @Action = 'U'
		UPDATE  CCC_MemberAdditionalInfo
		SET Homeless = @Homeless,
			PCP = @PCP,
			Household_size = @Household_size,
			Housing_Status = @Housing_Status,
			CitizenshipStatus = @CitizenshipStatus,
			FPL_Level = @FPL_Level,
			ProgramHandle = @ProgramHandle,
			Updated = GETUTCDATE()
		WHERE ICENUMBER = @MVDID
	END
	ELSE IF NOT EXISTS (Select 1 FROM CCC_MemberAdditionalInfo WHERE ICENUMBER = @MVDID)
	BEGIN
		SET @Action = 'I'
		INSERT INTO CCC_MemberAdditionalInfo (ICENUMBER,PCP,Homeless,Household_size,Housing_Status,CitizenshipStatus,FPL_Level,ProgramHandle)
		Select @MVDID, @PCP, @Homeless, @Household_size, @Housing_Status, @CitizenshipStatus, @FPL_Level, @ProgramHandle
	END
	SET @Result = 0
END