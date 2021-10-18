/****** Object:  Procedure [dbo].[Get_CareSpaceMemberEdit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_CareSpaceMemberEdit
(
--Declare 
	@CustID int ,
	@MemberID nvarchar(100)
)
AS

-- Exec dbo.[Get_CareSpaceMemberEdit] 16, '99084632901'
BEGIN
	DECLARE @MVDID nvarchar(30);

	SELECT
	@MVDID = MVDID
	FROM
	FinalMember
	WHERE
	MemberID = @MemberID
	AND CustID = @CustID;

	IF ( @MVDID IS NOT NULL )
	BEGIN
		IF EXISTS ( SELECT 1 FROM CareSpaceMemberEdit WHERE ICENUMBER = @MVDID)
		BEGIN
				Select RecordNumber, ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,Housing, [Source], [Type], StartDate, EndDate, IsPrimary as CSME_IsPrimary
				From CareSpaceMemberEdit where ICENUMBER = @MVDID;
		END;
		ELSE
		BEGIN
				Select Null as 'RecordNumber', ICENUMBER,LastName,FirstName,MiddleName,Address1,Address2,City,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email,Language,Ethnicity,NULL as Housing, NULL [Source], 'DefaultAddress' as [Type], NULL StartDate, NULL EndDate, 0 as CSME_IsPrimary
				From MainPersonalDetails where ICENUMBER = @MVDID
				Union
				Select Null as 'RecordNumber', MVDID, dbo.fnInitCap(MemberLastName), dbo.fnInitCap(MemberFirstName), dbo.fnInitCap(MemberMiddleName), dbo.fnInitCap(Address1), dbo.fnInitCap(Address2), dbo.fnInitCap(City), State, Zipcode, HomePhone, NULL, WorkPhone, Fax, dbo.fnInitCap(Email),Language, Ethnicity, NULL as Housing, NULL [Source], 'DefaultAddress' as [Type], NULL StartDate, NULL EndDate, 0 as CSME_IsPrimary
				From FinalMember
				Where MVDID = @MVDID;
		END;
	END;

END;