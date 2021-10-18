/****** Object:  Procedure [dbo].[Set_CarespaceMemberEdit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Set_CarespaceMemberEdit]
(
--Declare 
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
@EndDate	date = NULL
)
AS 
BEGIN

--Declare @GenderID int
--SELECT GenderID = GenderID FROM [LookupGenderID] where GenderName = @Gender

	If exists (Select 1 from CarespaceMemberEdit where ICENUMBER = @MVDID and [Type] = @Type)
	BEGIN
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
			EndDate = @EndDate
		WHERE ICENUMBER = @MVDID and [Type]	= @Type
	END
	ELSE IF not exists (Select 1 from CarespaceMemberEdit where ICENUMBER = @MVDID and [Type] = @Type)
	BEGIN
		INSERT INTO CareSpaceMemberEdit (ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,Housing,CreatedBy, [Source], [Type], StartDate, EndDate)
		Select @MVDID, @LastName, @FirstName, @MiddleName, @Address1, @Address2, @City, @State, @PostalCode, @HomePhone, @CellPhone, @WorkPhone, @FaxPhone, @Email, @Language, @Ethnicity, @Housing, @CreatedBy, @Source, @Type, @StartDate, @EndDate
	END

END