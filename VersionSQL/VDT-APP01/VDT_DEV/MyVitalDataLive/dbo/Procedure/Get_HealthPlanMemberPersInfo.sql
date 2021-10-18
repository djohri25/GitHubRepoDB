/****** Object:  Procedure [dbo].[Get_HealthPlanMemberPersInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/8/2008
-- Description:	Get personal info and Health Plan note about the insured MVD member.
--		Only one parameter must be set.
--		If MVDId is provided, HPMemberId is valued by the stored proc,
--		and vice versa
-- =============================================
CREATE Procedure [dbo].[Get_HealthPlanMemberPersInfo]  
	@MvdId varchar(15) output,
	@HPCustomerID int,
	@HPMemberId varchar(15) output

as

set nocount on

--select @MvdId = 'EB439373',
--	@HPCustomerID =4

if( len(isnull(@MvdId,'')) <> 0 or len(isnull(@HPMemberId,'')) <> 0)
begin

	-- If MVDId wasn't provided, retrieve it by Health Plan Member Id
	if( len(isnull(@MvdId,'')) = 0 )
	begin
		select @MvdId = MVDId from Link_MemberId_MVD_Ins
		where InsMemberId = @HPMemberId and Cust_ID = @HPCustomerID
	end

	-- If Health Plan Member Id wasn't provided, retrieve it by MVD Id
	if( len(isnull(@HPMemberId,'')) = 0 )
	begin
		select @HPMemberId = InsMemberId from Link_MVDID_CustID
		where MVDId = @MvdId and Cust_ID = @HPCustomerID
	end

	-- Member must be linked to the customer
	if len(isnull(@MvdId,'')) <> 0 and exists (select mvdid from Link_MVDID_CustID 
		where mvdid = @MvdId and Cust_ID = @HPCustomerID)
	begin

		If Exists (Select ICENUMBER from MainPersonalDetails a 
			inner join Link_MVDID_CustID b 
				on a.ICENUMBER = b.MVDId where ICENUMBER = @MvdId)
		BEGIN

			Select 
			ICENUMBER,
			@HPMemberId as HPMemberId,
			LastName,
			FirstName,
			MiddleName,
			(Select GenderName From LookupGenderId Where
				GenderId = IsNull(a.GenderId, 0)) As GenderName,
			isnull(Substring(SSN,1,3),'') + '-' +	isnull(Substring(SSN,4,2),'') + '-' + isnull(Substring(SSN,6,4),'') As FullSSN,	
			DOB,
			Address1,
			Address2,
			City,
			IsNull(State, '0') As State,
			PostalCode,	
			dbo.FormatPhone(HomePhone) As FullHome,
			dbo.FormatPhone(CellPhone) As FullCell,
			dbo.FormatPhone(WorkPhone) As FullWork,
			dbo.FormatPhone(FaxPhone) As FullFax,
			Email,
			(Select BloodTypeName From LookupBloodTypeId Where
				BloodTypeId = IsNull(a.BloodTypeId, 0)) As BloodTypeName,
			(Select OrganDonorName From LookupOrganDonorTypeID Where
				OrganDonorID = IsNull(a.OrganDonor, 0)) As OrganDonorName,
			HeightInches,		
			WeightLbs,
			(Select MaritalStatusName From LookupMaritalStatusId Where
				MaritalStatusId = IsNull(a.MaritalStatusID, 0)) As MaritalStatusName,
			(Select EconomicStatusName From LookupEconomicStatusId Where
				EconomicStatusId = IsNull(a.EconomicStatusId, 0)) As EconomicStatusName,
			Occupation,
			Hours,
			c.HealthPlanUserNote
			From MainPersonalDetails a
				inner join Link_MVDID_CustID b on a.ICENUMBER = b.MVDId
				inner join dbo.UserAdditionalInfo c on a.ICENUMBER = c.MVDID
			Where ICENUMBER = @MvdId
		END
	end
end