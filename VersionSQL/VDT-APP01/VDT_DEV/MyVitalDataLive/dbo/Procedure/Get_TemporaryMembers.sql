/****** Object:  Procedure [dbo].[Get_TemporaryMembers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_TemporaryMembers] 
	-- Add the parameters for the stored procedure here
	@CustID int
AS
BEGIN

	SELECT
	fmt.RecordID ID,
	fmt.MVDID,
	fmt.MemberID,
	fmt.MemberFirstName FirstName,
	fmt.MemberLastName LastName,
	fmt.SSN,
	fmt.DateOfBirth DOB,
	fmt.Gender,
	fmt.Address1,
	fmt.Address2,
	fmt.Email,
	fmt.HomePhone Phone,
	fmt.City,
	fmt.State,
	fmt.Zipcode PostalCode,
	fmt.Ethnicity,
	fmt.LOB,
	fmt.CMOrgRegion,
	fmt.BrandingName,
	fmt.PlanGroup GroupKey,
	g.grp_name GroupName,
	fmt.SubGroupKey,
	sg.sub_grp_name SubGroupName,
	fmt.CompanyKey,
	c.company_name CompanyName,
	fmt.AssociatedMemberID,
	fm.MVDID AssociatedMVDID,
	fmt.CreatedBy,
	fmt.CreatedDate,
	fmt.LastModifiedBy,
	fmt.LastModifiedDate,
	fet.MemberEffectiveDate EffStartDate,
	fet.MemberTerminationDate EffEndDate
	FROM
	FinalMemberTemporary fmt
	INNER JOIN FinalEligibilityTemporary fet
	ON fmt.CustID = fet.CustID
	AND fmt.MVDID = fet.MVDID
	LEFT OUTER JOIN LookupGroup g
	ON g.grp_key = fmt.PlanGroup
	LEFT OUTER JOIN LookupSubGroup sg
	ON sg.sub_grp_key = fmt.SubGroupKey
	LEFT OUTER JOIN LookupCompanyName c
	ON c.company_key = fmt.CompanyKey
	LEFT OUTER JOIN FinalMemberETL fm
	ON fm.CustID = @CustID
	AND fm.MemberID = fmt.AssociatedMemberID
	WHERE
	fmt.CustID = @CustID;

END;