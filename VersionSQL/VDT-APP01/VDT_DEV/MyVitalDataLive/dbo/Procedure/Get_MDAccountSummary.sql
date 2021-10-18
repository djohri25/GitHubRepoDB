/****** Object:  Procedure [dbo].[Get_MDAccountSummary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/3/2014
-- Modify date: 8/5/2014
-- Description:	Returns summary counts for DR user account
-- Date			Name			Comments
-- 02/15/2017	PPetluri		Modified ERVisit count to get the count from EDvisitHistory table instead of EDVisitHistory table since this table is retired.
-- 02/28/2017	Misha			Used Final_ALLMember to calculate Patient and PCP counts.
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDAccountSummary]
	@DoctorID varchar(20),
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIN_Temp varchar(250), @TIN varchar(250)
	DECLARE @TIN_Array Table (TIN varchar(50))

	declare @PatientCount int, @PCPCount int, @ERVisitCount int, @CustID_Import	int
	
	select @PatientCount = 0, @PCPCount = 0, @ERVisitCount = 0
	
	--CustID
	SELECT DISTINCT @CustID_Import = CustID_Import
	FROM [dbo].[MDUser] a
	JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
	JOIN MDGroup c ON b.mdGroupID = c.ID
	WHERE username = @DoctorID

	--TIN
	SELECT @TIN = (CASE WHEN @TIN = '' THEN 'ALL' ELSE @TIN END)
	INSERT INTO @TIN_Array
	SELECT *
	FROM [dbo].[Get_TinArray](@DoctorID, @TIN)
	IF (@TIN = 'ALL' AND @DoctorID IS NOT NULL)
	BEGIN
		SELECT @TIN = '' -- TIN list is specified by the logged in user
	END

	SELECT @PatientCount = COUNT(DISTINCT MemberID)
	FROM [dbo].[Final_ALLMember]
	WHERE CustID = @CustID_Import
		AND (@TIN = 'ALL' OR ([TIN] IN (SELECT TIN from @TIN_Array)))
		--AND ISNULL(NPI, '') != ''

	SELECT @PCPCount = COUNT(DISTINCT NPI)
	FROM [dbo].[Final_ALLMember]
	WHERE CustID = @CustID_Import
		AND (@TIN = 'ALL' OR ([TIN] IN (SELECT TIN from @TIN_Array)))
		AND ISNULL(NPI, '') != ''
	
	SELECT @ERVisitCount = COUNT(v.id)
	FROM EDVisitHistory v
	INNER JOIN MainSpecialist s ON v.icenumber = s.icenumber 
	INNER JOIN Link_MDGroupNPI n ON n.NPI = s.NPI
	INNER JOIN Link_MDAccountGroup ag ON ag.MDGroupID = n.MDGroupID
	INNER JOIN MDUser u ON u.ID = ag.MDAccountID
	INNER JOIN Link_MemberId_MVD_Ins li ON li.MVDId = s.ICENUMBER
	WHERE
		v.VisitDate BETWEEN DATEADD(DAY, -7, GETDATE()) AND GETDATE()
		AND v.VisitType = 'ER'
		AND u.Username = @DoctorID
		AND s.RoleID = 1
		AND li.Active = 1
		AND li.Cust_ID = @CustID_Import
		
	SELECT @PatientCount as 'PatientCount', @PCPCount as 'PCPCount', @ERVisitCount as 'ERVisitCount'
	
	IF (ISNULL(@EMS, '') != '' OR ISNULL(@UserID_SSO, '') != '')
	BEGIN
		-- Record SP Log
		declare @params nvarchar(1000)
		set @params = '@DoctorID=' + @DoctorID + ';'
		exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_MDAccountSummary]', @EMS, @UserID_SSO, @params
	END
END