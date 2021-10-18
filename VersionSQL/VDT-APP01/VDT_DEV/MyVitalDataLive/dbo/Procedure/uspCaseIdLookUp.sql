/****** Object:  Procedure [dbo].[uspCaseIdLookUp]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCaseIdLookUp] 
    @MVDID Varchar(100), 
	@CaseId varchar(max) output
AS

Begin 

if exists (select top 1 1 from ABCBS_MemberManagement_Form where MVDID = @MVDID)

BEGIN 

select top 1 @CaseId= caseID from ABCBS_MemberManagement_Form 
			where MVDID = @MVDID and (caseid is not null or ltrim(rtrim(caseid))='') and
				  qclosecase='No'

END

END 