/****** Object:  Procedure [dbo].[uspInsertLetterMembersInvalidAddress]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspInsertLetterMembersInvalidAddress]
( 
	@p_MVDID [varchar](30),
	@p_MemberFirstName [varchar](50) = NULL,
 	@p_MemberLastName [varchar](50) = NULL,
	@p_Address1 [varchar](100) = NULL,
	@p_Address2 [varchar](50) = NULL,
	@p_City [varchar](50) = NULL,
	@p_State [varchar](2) = NULL,
	@p_Zipcode [varchar](9) = NULL,
	@p_DateOfBirth [date] = NULL,
	@p_ID bigint OUTPUT
)
AS

/*
Date			Modified			Description
9/17/2020		Sunil Nokku			To insert Invalid Address records from front end forms #TFS 

DECLARE @t INT
EXEC uspInsertLetterMembersInvalidAddress 
	@p_MVDID ='163FDACF34C128CDCBBB',
	@p_MemberFirstName = 'Sunny',
 	@p_MemberLastName  = 'Sam',
	@p_Address1  = 'Tesfs',
	@p_Address2  = 'sfgd',
	@p_City  = 'sdgf',
	@p_State  = 'sdg',
	@p_Zipcode = '5567',
	@p_DateOfBirth  = '19950508',
	@p_ID = @t OUTPUT
SELECT @t

Modified Date			Modified By			Summary
12/07/2020				Sunil Nokku			Defaulted ProcessedDate to NULL on initial load.
*/

BEGIN

	DECLARE @v_MVDID [varchar](30) = NULL,
			@v_MemberFirstName [varchar](50) = NULL,
 			@v_MemberLastName [varchar](50) = NULL,
			@v_Address1 [varchar](100) = NULL,
			@v_Address2 [varchar](50) = NULL,
			@v_City [varchar](50) = NULL,
			@v_State [varchar](2) = NULL,
			@v_Zipcode [varchar](9) = NULL,
			@v_DateOfBirth [date] = NULL	

	SELECT @v_MVDID				=	@p_MVDID,
			@v_MemberFirstName  =	@p_MemberFirstName,
 			@v_MemberLastName  	=	@p_MemberLastName,
			@v_Address1  		=	@p_Address1,
			@v_Address2			=	@p_Address2,
			@v_City 			=	@p_City,
			@v_State 			=	@p_State,
			@v_Zipcode			=	@p_Zipcode,
			@v_DateOfBirth 		=	@p_DateOfBirth
			
	INSERT INTO LetterMembersInvalidAddress
		(
		[MVDID] ,
		[MemberID] ,
		[MemberFirstName] ,
		[MemberLastName] ,
		[Address1] ,
		[Address2] ,
		[City] ,
		[State] ,
		[Zipcode] ,
		[DateOfBirth] ,
		[SubscriberID] ,
		[Suffix] ,
		[ProcessedDate]
		)
	SELECT 
		@v_MVDID,
		MemberID,
		@v_MemberFirstName,
		@v_MemberLastName,
		@v_Address1,
		@v_Address2,
		@v_City,
		@v_State,
		@v_Zipcode,
		@v_DateOfBirth,
		SubscriberID,
		Suffix,
		NULL
	FROM FinalMember
	WHERE MVDID = @v_MVDID

	SET @p_ID = @@IDENTITY
	
END