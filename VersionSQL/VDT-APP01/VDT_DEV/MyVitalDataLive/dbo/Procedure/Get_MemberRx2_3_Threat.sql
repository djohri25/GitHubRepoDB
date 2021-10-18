/****** Object:  Procedure [dbo].[Get_MemberRx2_3_Threat]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberRx2_3_Threat] @MedRecs [dbo].[MedRecExt] READONLY
AS
/*
Note:		This procedure will search for double and triple threat combinations based on the NDCs from FDB_DRUG_ID_TYPE 6 that are passed in.  

1.  Get the GCN_Seqno for each NDC passed in.  This is the FDB Drug_ID that corresponds to the many NDCs a drug may have (packaging).
2.  Lookup the Concurrent_Risk_Group_ID for each Drug_ID.
3.  Cross join the NDCs to see if there are drugs from adverse combinations of Risk_Groups.  These are Concurrent_Risk_Sets.  A concurrent risk set
    identifies and two risk groups (double threat) or three risk groups (triple threat) that exist in the bag of Drugs.
4.  Get the Warning messages for each of the Concurrent Risk Sets that are identified and return them.

Modifications:	WHO		WHEN		WHAT
				Scott	2020-05-29	Created
				Scott   2020-06-09  Modify return dataset to include columns for each NDC and DRG name.
				Tim		2021-02-12	4422 - Adding lookup on RMIID1_MED for missing GCN_SEQNO values 
	

DECLARE @MedRec dbo.MedRecExt
--INSERT INTO @MedRec (NDC) VALUES ('63629406807'), ('54569598100') -- double threat: groups (1,5) = Risk Set 5 

-- Medical marijuana Db test
-- Note: well-formed NDCs not in table.  These are compounds that the pharmacist makes.  need to perform drug
--       interaction nonetheless
INSERT INTO @MedRec (NDC) VALUES ('220671'), ('42806054701'), ('50228018105'), ('50742061510'), ('65862067705'), 
								('68382025505'), ('68645055854'), ('68645058459') -- double threat: groups (1,6) = Risk Set 1

EXEC Get_MemberRx2_3_Threat @MedRec 

SELECT * FROM FirstDataBankDB.dbo.RORCOAT0_OPIOID_CONCR_ALERTING --These are all the possible warnings.  There are seven risk sets.

*/
BEGIN

         SET NOCOUNT ON;

		--Get the GCN_SEQNO (FDB_DRUG_ID) for any NDCs in FDB_DRUG_ID_TYPE 6

        DROP TABLE IF EXISTS #PatientMeds;

		SELECT MEDS.*
		INTO #PatientMeds 
		FROM(
			SELECT DISTINCT
				F.[NDC] as NDC11,
				F.BN,
				F.[GCN_SEQNO],
				DRG.CONCURRENT_RISK_GROUP_ID
			FROM @MedRecs mr
			LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F ON F.NDC = mr.NDC --get the GCN_SEQNO
			LEFT OUTER JOIN [FirstDataBankDB].[dbo].RORCORD0_OPIOID_CONCR_RISK_DRG DRG ON DRG.FDB_DRUG_ID = F.GCN_SEQNO AND DRG.FDB_DRUG_ID_TYPE=6 --get the CONCURRENT_RISK_GROUP_ID

			UNION

			-- 4612 - Adding missing medications
			SELECT DISTINCT
				CAST(F.[MEDID] as VARCHAR) as NDC11,
				F.MED_MEDID_DESC as BN,
				F.GCN_SEQNO,
				DRG.CONCURRENT_RISK_GROUP_ID
			FROM @MedRecs mr     
			LEFT OUTER JOIN [FirstDataBankDB].[dbo].RMIID1_MED F ON CAST(F.MEDID as VARCHAR) = mr.NDC
			LEFT OUTER JOIN [FirstDataBankDB].[dbo].RORCORD0_OPIOID_CONCR_RISK_DRG DRG ON DRG.FDB_DRUG_ID = CAST(F.GCN_SEQNO AS VARCHAR) AND DRG.FDB_DRUG_ID_TYPE=6 --get the CONCURRENT_RISK_GROUP_ID
					   
		) MEDS

        --SELECT * FROM #PatientMeds

		--Create a reference table to get the risk sets from the ordered group Ids 

		DROP TABLE IF EXISTS #Risk_Sets
				
		SELECT DISTINCT CONCURRENT_RISK_SET_ID RiskSetID, STUFF(x.RiskGroupID,1,1,'') RiskGroups
		INTO #Risk_Sets
		FROM FirstDataBankDB.dbo.RORCORL0_OPIOID_CONCR_RISK_LNK rocrl
        CROSS
		APPLY (SELECT (',' + CAST(CONCURRENT_RISK_GROUP_ID AS varchar)) 
                 FROM FirstDataBankDB.dbo.RORCORL0_OPIOID_CONCR_RISK_LNK
				WHERE rocrl.CONCURRENT_RISK_SET_ID = CONCURRENT_RISK_SET_ID
				ORDER BY CONCURRENT_RISK_GROUP_ID
                  FOR XML PATH('')) x (RiskGroupID)

		--SELECT * FROM #Risk_Sets

		--Create a temp table to store the Risk Set Alert messages.
		DROP TABLE IF EXISTS #Opioid_Alert

		CREATE TABLE #Opioid_Alert (--Interaction varchar(1000),
				                    NDC1 varchar(255) NOT NULL,
									DRG1 varchar(255) NOT NULL,
				                    NDC2 varchar(255) NOT NULL,
									DRG2 varchar(255) NOT NULL,
				                    NDC3 varchar(255) NULL,
									DRG3 varchar(255) NULL,
									CONCURRENT_RISK_SET_ID numeric(8, 0) NOT NULL,
									CONCURRENT_RISK_SET_ID_DESC varchar(255) NOT NULL,
									TRIPLE_THREAT_IND varchar(1) NOT NULL,
									ALERT_TEXT varchar(2000) NOT NULL,
									ALERT_EXCEPTION_TEXT varchar(2000) NULL,
									CITATION_TEXT varchar(255) NOT NULL
								   ) 

	    --compare all the double and triple set combinations to the risk sets and get the alert messages

		;WITH DoubleThreat AS 
			(
			  SELECT --a.NDC11 + ' : ' + b.NDC11 Interaction,
					 a.NDC11 AS NDC1, a.BN AS DRG1, 
					 b.NDC11 AS NDC2, b.BN AS DRG2,
					 NULL AS NDC3, NULL AS DRG3,
					 CAST(a.Concurrent_Risk_Group_ID AS varchar) + ',' + 
					 CAST(b.Concurrent_Risk_Group_ID AS varchar) Combined
				FROM #PatientMeds a
		  CROSS JOIN #PatientMeds b
				WHERE a.Concurrent_Risk_Group_ID != b.Concurrent_Risk_Group_ID
				  AND a.Concurrent_Risk_Group_ID < b.Concurrent_Risk_Group_ID
		  ),
		  TripleThreat AS
		 (
			  SELECT --a.NDC11 + ' : ' + b.NDC11 + ' : ' + c.NDC11 Interaction,
					 a.NDC11 AS NDC1, a.BN AS DRG1, 
					 b.NDC11 AS NDC2, b.BN AS DRG2,
					 c.NDC11 AS NDC3, c.BN AS DRG3,
					 CAST(a.Concurrent_Risk_Group_ID AS varchar) + ',' + 
					 CAST(b.Concurrent_Risk_Group_ID AS varchar) + ',' + 
					 CAST(c.Concurrent_Risk_Group_ID AS varchar) Combined
				FROM #PatientMeds a
		  CROSS JOIN #PatientMeds b
		  CROSS JOIN #PatientMeds c
				WHERE a.Concurrent_Risk_Group_ID != b.Concurrent_Risk_Group_ID
				  AND b.Concurrent_Risk_Group_ID != c.Concurrent_Risk_Group_ID
				  AND a.Concurrent_Risk_Group_ID != c.Concurrent_Risk_Group_ID
				  AND a.Concurrent_Risk_Group_ID < b.Concurrent_Risk_Group_ID
				  AND b.Concurrent_Risk_Group_ID < c.Concurrent_Risk_Group_ID
			),
			RiskGroups AS
			(
				SELECT NDC1, DRG1, NDC2, DRG2, NDC3, DRG3, Combined FROM DoubleThreat
				UNION
				SELECT NDC1, DRG1, NDC2, DRG2, NDC3, DRG3, Combined FROM TripleThreat
			),
			RiskSets AS
			(
				SELECT NDC1, DRG1, NDC2, DRG2, NDC3, DRG3, RiskSetID 
				  FROM RiskGroups rg
				  JOIN #Risk_Sets rs ON rg.Combined = rs.RiskGroups
			)
            INSERT INTO #Opioid_Alert  
			SELECT NDC1, DRG1, NDC2, DRG2, NDC3, DRG3, 
				   CONCURRENT_RISK_SET_ID,
				   CONCURRENT_RISK_SET_ID_DESC,
				   TRIPLE_THREAT_IND,
				   ALERT_TEXT,
				   ALERT_EXCEPTION_TEXT,
				   CITATION_TEXT
			  FROM FirstDataBankDB.dbo.RORCOAT0_OPIOID_CONCR_ALERTING oa
			  JOIN RiskSets rs ON oa.CONCURRENT_RISK_SET_ID = rs.RiskSetID		

			SELECT * FROM #Opioid_Alert ORDER BY TRIPLE_THREAT_IND, CONCURRENT_RISK_SET_ID 

	RETURN

END


				
		
		