/****** Object:  Procedure [dbo].[Get_DriscollAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DriscollAdditionalInfo]
( @MVDID VARCHAR(15))
AS 
BEGIN
SET NOCOUNT ON;

--Declare @MVDID VARCHAR(15)

SELECT D.ICENUMBER, P.LastName,P.FirstName, P.DOB, P.[Language],Lob.Label_Desc as LOB,Plan_stratid,dual,MedicareID,medicare_effdt,medicare_termdt,migrant,benefit_code,waiver_toa
FROM [MainPersonalDetails] P JOIN [Driscoll_EligibilityAdditionalInfo] D ON P.ICENUMBER = D.ICENUMBER 
JOIN Lookup_Generic_Code Lob ON Lob.Cust_id = D.Cust_id and Lob.CodeID = D.LobID
Where Lob.CodetypeID = 3
and P.ICENUMBER = @MVDID 

END