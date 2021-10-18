/****** Object:  Procedure [dbo].[Get_UserProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_UserProfiles]
	@Email varchar(100),
	@SecQue int,
	@SecAns varchar(50),	
	@Result int OUT
As


SET NOCOUNT ON

	SELECT @Result = COUNT(*) FROM MainUserName WHERE UserName = @Email 
	AND SecQuestion = @SecQue AND SecAnswer = @SecAns