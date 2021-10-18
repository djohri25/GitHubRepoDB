/****** Object:  Procedure [dbo].[PCCIUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 03/23/2018
-- Description:	This will update the ParklandPCCICOPCRisk from the most recent file
-- =============================================
CREATE PROCEDURE [dbo].[PCCIUpdate]
AS
BEGIN

	SET NOCOUNT ON;

	;WITH CTE_Dups AS
	(
	SELECT MemberNumber, DateOfBirth, HomePhone, Age, RiskScores
	,ROW_NUMBER() OVER(PARTITION BY MemberNumber, DateOfBirth, HomePhone, Age, RiskScores ORDER BY MemberNumber, DateOfBirth, HomePhone, Age, RiskScores) AS RowNum
	FROM dbo.ParklandRiskScoresStaging
	)

	DELETE FROM CTE_Dups
	WHERE RowNum = 2

	MERGE dbo.ParklandPCCICOPCRisk AS target  
	USING 
		(
		 SELECT 
		 R.[ReferenceID] AS ReferenceID
		,10 AS CustID
		,I.MVDID
		,R.[MemberNumber] AS MemberID
		,UPPER(LTRIM(RTRIM(SUBSTRING(R.[MemberName], CHARINDEX(',', R.[MemberName], 1)+1, 100)))) AS FirstName
		,UPPER(LTRIM(RTRIM(SUBSTRING(R.[MemberName], 1, CHARINDEX(',', R.[MemberName], 1)-1)))) AS LastName
		,R.[DateOfBirth] AS dob
		,R.[Age]
		,R.[HomePhone] AS Phone
		,R.[RiskScores]
		FROM dbo.ParklandRiskScoresStaging R
		JOIN dbo.Link_MemberId_MVD_Ins I ON R.[MemberNumber] = I.InsMemberID 
		WHERE I.Cust_ID = 10
		) AS source (ReferenceID,CustID,MVDID,MemberID,FirstName,LastName,dob,Age,Phone,RiskScores)  
	ON (target.CustID = source.CustID AND target.MVDID = source.MVDID AND target.MemberID = source.MemberID)  
	WHEN MATCHED   
			THEN UPDATE 
			SET target.ReferenceID = source.ReferenceID
			,target.FirstName = source.FirstName
			,target.LastName = source.LastName
			,target.dob = source.dob
			,target.Age = source.Age
			,target.Phone = source.Phone
			,target.RiskScores = source.RiskScores
			,target.ModifiedDate = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN  
	INSERT (ReferenceID,CustID,MVDID,MemberID,FirstName,LastName,dob,Age,Phone,RiskScores)
	VALUES (ReferenceID,CustID,MVDID,MemberID,FirstName,LastName,dob,Age,Phone,RiskScores);

END