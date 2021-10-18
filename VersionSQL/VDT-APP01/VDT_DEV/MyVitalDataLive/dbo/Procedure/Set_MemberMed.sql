/****** Object:  Procedure [dbo].[Set_MemberMed]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MemberMed] 
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
/*
Changes:
WHO			WHEN		WHAT
Unknown		Unknown		Created
2021-05-18	EZanelli	Changed from INSERT to MERGE (TFS4723)
*/
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
/*
From TFS4723:

Issue (1): MainMemberMed is the DB table where user-entered medications are stored.
The primary key on the tables is CustID+MVDID+NDC+RxStartDate, which must be unique.
In this scenario, the user has entered a manual med and is now wanting to revise that
entry or add a duplicate and change the reason for use.

Resolution for (1): Recommend not allowing duplicate manual entries to avoid accidental
duplication, unless there is a strong use case. If dups are to be allowed, we should
add ReasonForUse as an additional element of the key. Instead, we should alter
SP Set_MemberMed to detect if the request is an ADD or an UPDATE and post the data
accordingly.
*/

	MERGE INTO
	MainMemberMed d
	USING
	(
		SELECT
		@CUSTID CustID,
		@MVDID MVDID,
		@NDC NDC,
		@RXSTARTDATE RxStartDate,
		@RXDRUG RxDrug,
		@PRESCRIBEDBY PrescribedBy,
		@RXPHARMACY RxPharmacy,
		@HOWMUCH HowMuch,
		@HOWOFTEN HowOften,
		@WHYTAKING WhyTaking,
		@ROUTE Route,
		@DAYSSUPPLY DaysSupply,
		@CREATEDBY CreatedBy,
		@CREATEDDATE CreatedDate,
		@SessionID SessionID,
		@DrugStrength DrugStrength
	) s
	ON
	(
		s.CustID = d.CustID
		AND s.MVDID = d.MVDID
		AND s.NDC = d.NDC
		AND s.RxStartDate = d.RxStartDate
	)
	WHEN MATCHED THEN UPDATE SET
	d.RxDrug = s.RxDrug,
	d.PrescribedBy = s.PrescribedBy,
	d.RxPharmacy = s.RxPharmacy,
	d.HowMuch = s.HowMuch,
	d.HowOften = s.HowOften,
	d.WhyTaking = s.WhyTaking,
	d.Route = s.Route,
	d.DaysSupply = s.DaysSupply,
	d.CreatedBy = s.CreatedBy,
	d.CreatedDate = s.CreatedDate,
	d.SessionID = s.SessionID,
	d.DrugStrength = s.DrugStrength
	WHEN NOT MATCHED THEN INSERT
	(
		CustID,
		MVDID,
		NDC,
		RxStartDate,
		RxDrug,
		PrescribedBy,
		RxPharmacy,
		HowMuch,
		HowOften,
		WhyTaking,
		Route,
		DaysSupply,
		CreatedBy,
		CreatedDate,
		SessionID,
		DrugStrength
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