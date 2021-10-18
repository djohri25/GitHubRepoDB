/****** Object:  View [Rules].[MainPersonalDataStats]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE View [Rules].[MainPersonalDataStats]
AS

SELECT P.FirstName, P.LastName, P.DOB, P.SSN, P.Address1, P.City, P.State, P.PostalCode, P.HomePhone, P.CellPhone,  M.*, D.DIA_1stDiagDate, D.HTN_1stDiagDate, D.ASM_1stDiagDate, D.BH_1stDiagDate
FROM	Rules.MainPersonalStats M WITH (NOLOCK) JOIN MainPersonalDetails  P WITH (NOLOCK) ON P.ICENUMBER = M.MVDID
LEFT JOIN Rules.MemberDiagnosedDetl D WITH (NOLOCK) ON M.MVDID = D.ICENUMBER and M.Cust_ID = D.Cust_ID and M.MemberID = D.MemberID
WHERE M.MonthID = (Select MAX(MonthID) from Rules.MainPersonalStats M1 WITH (NOLOCK) Where M1.Cust_ID = M.Cust_ID)