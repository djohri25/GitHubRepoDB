/****** Object:  Procedure [dbo].[Set_CarespaceMemberEdit_V2_Test]    Committed by VersionSQL https://www.versionsql.com ******/

Create Proc [dbo].[Set_CarespaceMemberEdit_V2_Test]
(
--Declare 
@RecordNumber	int = NULL,
@MVDID  Varchar(30),
@LastName   Varchar(50) = NULL,
@FirstName  Varchar(50) = NULL,
@MiddleName Varchar(50) = NULL,
@Address1   Varchar(100) = NULL,
@Address2   Varchar(100) = NULL,
@City	    Varchar(50) = NULL,
@State	    Varchar(2) = NULL,
@PostalCode Varchar(5) = NULL,
@HomePhone	Varchar(10) = NULL,
@CellPhone	Varchar(10) = NULL,
@WorkPhone	Varchar(10) = NULL,
@FaxPhone	Varchar(10) = NULL,
@Email		Varchar(100) = NULL,
@Language	Varchar(100) = NULL,
@Ethnicity	Varchar(50) = NULL,
@Housing	Varchar(50) = NULL,
@CreatedBy	Varchar(50) = NULL,
@Source		varchar(60) = NULL,
@Type		Varchar(60) = NULL,
@StartDate	date	= NULL,
@EndDate	date = NULL,
@IsPrimary bit = null,
@New_ID	int output
)
AS 
BEGIN

--Declare @GenderID int
--SELECT GenderID = GenderID FROM [LookupGenderID] where GenderName = @Gender

Set @New_ID = NULL

	If (@RecordNumber is not NULL)
	BEGIN

		IF (@IsPrimary = 1)
		BEGIN
			UPDATE CareSpaceMemberEdit SET IsPrimary= 0 WHERE ICENUMBER=@MVDID AND IsPrimary= 1
		
			/*INSERT INTO CareSpaceMemberEdit (ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,Housing,CreatedBy, [Source], [Type], StartDate, EndDate, IsPrimary)
			Select @MVDID, @LastName, @FirstName, @MiddleName, @Address1, @Address2, @City, @State, @PostalCode, @HomePhone, @CellPhone, @WorkPhone, @FaxPhone, @Email, @Language, @Ethnicity, @Housing, @CreatedBy, @Source, @Type, @StartDate, @EndDate, @IsPrimary*/
		END


		UPDATE CarespaceMemberEdit
		SET	LastName = 	@LastName, 
			FirstName = @FirstName, 
			MiddleName = @MiddleName, 
			--GenderID = @GenderID,  
			--DOB = CONVERT(smallDatetime, @DOB, 120), 
			Address1 = @Address1, 
			Address2 = @Address2, 
			City = @City, 
			State = @State, 
			PostalCode = @PostalCode, 
			HomePhone = @HomePhone, 
			CellPhone = @CellPhone, 
			WorkPhone = @WorkPhone, 
			FaxPhone = @FaxPhone, 
			Email = @Email, 
			Language = @Language, 
			Ethnicity = @Ethnicity, 
			Housing = @Housing, 
			UpdatedBy = @CreatedBy,
			[Source] = @Source,
			StartDate = @StartDate,
			EndDate = @EndDate,
			IsPrimary=@IsPrimary
		WHERE ICENUMBER = @MVDID and [Type]	= @Type and RecordNumber = @RecordNumber
	END
	ELSE IF not exists (Select 1 from CarespaceMemberEdit where ICENUMBER = @MVDID and [Type] = @Type)
	BEGIN

	IF (@IsPrimary = 1)
		BEGIN
			UPDATE CareSpaceMemberEdit SET IsPrimary= 0 WHERE ICENUMBER=@MVDID AND IsPrimary= 1
		
			/*INSERT INTO CareSpaceMemberEdit (ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,Housing,CreatedBy, [Source], [Type], StartDate, EndDate, IsPrimary)
			Select @MVDID, @LastName, @FirstName, @MiddleName, @Address1, @Address2, @City, @State, @PostalCode, @HomePhone, @CellPhone, @WorkPhone, @FaxPhone, @Email, @Language, @Ethnicity, @Housing, @CreatedBy, @Source, @Type, @StartDate, @EndDate, @IsPrimary*/
		END
		INSERT INTO CareSpaceMemberEdit (ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,Housing,CreatedBy, [Source], [Type], StartDate, EndDate, IsPrimary)
		Select @MVDID, @LastName, @FirstName, @MiddleName, @Address1, @Address2, @City, @State, @PostalCode, @HomePhone, @CellPhone, @WorkPhone, @FaxPhone, @Email, @Language, @Ethnicity, @Housing, @CreatedBy, @Source, @Type, @StartDate, @EndDate, @IsPrimary
	END

	Select @New_ID = SCOPE_IDENTITY();
END