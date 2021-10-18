/****** Object:  Procedure [dbo].[Set_MemberMed_20210518]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[Set_MemberMed_20210518] 
	@CUSTID int, 
	@MVDID varchar(30),
	@NDC varchar(20),
	@RXSTARTDATE datetime,
	@RXDRUG varchar(100),
	@PRESCRIBEDBY varchar(250),
	@RXPHARMACY varchar(100),
	@HOWMUCH varchar(50),
	@HOWOFTEN varchar(50),
	@WHYTAKING varchar(50),
	@ROUTE varchar(50),
	@DAYSSUPPLY varchar(50),
	@CREATEDBY varchar(250),
	@CREATEDDATE DATETIME,
	@SessionID varchar(40),
	@DrugStrength varchar(12) = NULL
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
	INSERT INTO dbo.MainMemberMed
	(
		[CustID],
		[MVDID],
		[NDC],
		[RxStartDate],
		[RxDrug],
		[PrescribedBy],
		[RxPharmacy],
		[HowMuch],
		[HowOften],
		[WhyTaking],
		[Route],
		[DaysSupply],
		[CreatedBy],
		[CreatedDate],
		[SessionID],
		[DrugStrength]
	)
	VALUES
	(
		@CUSTID,
		@MVDID,
		@NDC,
		@RXSTARTDATE,
		@RXDRUG,
		@PRESCRIBEDBY,
		@RXPHARMACY,
		@HOWMUCH,
		@HOWOFTEN,
		@WHYTAKING,
		@ROUTE,
		@DAYSSUPPLY,
		@CREATEDBY,
		@CREATEDDATE,
		@SessionID,
		@DrugStrength
	);
END