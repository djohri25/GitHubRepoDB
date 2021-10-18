/****** Object:  Procedure [dbo].[uspCFR_ERVisits90day_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisits90day_MVDID]
AS
/*
    CustID: 16
    RuleID: 246
 ProgramID: 2
OwnerGroup: 168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	CREATEd by refactor of original to call uspCFR_Merge
Scott	2021-05-05	Add Universal Exclusion for no benefit and hourly.  Reformat to CTE
Scott	2021-07-30	Add granular exclusion method
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_ERVisits_MVDID 

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_ERVisits90day_MVDID', @CustID = 16, @RuleID = 246, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @pRuleID = 246, @pAction = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 246
	DECLARE @RuleName varchar(255) = 'ER Utilization - 90 days'

--New Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

GetMVDIDs:

		;WITH cteMembers AS
		( SELECT CCQ.MVDID 
	        FROM ComputedCareQueue (READUNCOMMITTED) CCQ
	   LEFT JOIN ComputedMemberAlert  (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
	        JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
	       WHERE CCQ.IsActive = 1 
	         AND IsNull(FM.CompanyKey,'0000') != '1338'
	         AND IsNull(CCQ.CaseOwner,'--') = '--'
	         AND IsNull(CA.PersonalHarm,0) = 0
	         AND IsNull(FM.COBCD,'U') not in ('S','M','A')
	         AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
	         AND CCQ.MVDID IN (SELECT MVDID 
			                     FROM (SELECT CH.mvdid, 
								              COUNT(DISTINCT CH.StatementFromDate) AS CNT
			                             FROM dbo.FinalClaimsHeader CH
			                             JOIN DBO.FinalClaimsHeaderCode CD ON CD.ClaimNumber = CH.ClaimNumber
			                             JOIN dbo.FinalClaimsDetail FCD ON FCD.ClaimNumber = CH.ClaimNumber
			                            WHERE CH.StatementFromDate >= DATEADD(DAY,-90,GetDate())
			                              --AND ISNULL(CH.[EmergencyIndicator],0) = 1
			                              AND FCD.RevenueCode LIKE ('045%')
			                              AND ISNULL(CH.[DischargeStatusCode],'01') = '01'
			                              AND CD.CodeType = 'DIAG' 
			                              AND CD.ICDVersion = '0' 
				                          AND CD.CodeValue NOT IN (
'297', '2970', '2971', '2972', '2973', '2978', '2979', '299', '2990', '29900', '29901', '2991', '29910', '29911', '2998', '29980', '29981', '2999', '29990', '29991', '317', 'F01', 'F015', 'F0150', 'F0151', 'F02', 
'F028', 'F0280', 'F0281', 'F03', 'F039', 'F0390', 'F0391', 'F04', 'F05', 'F06', 'F060', 'F061', 'F062', 'F063', 'F0630', 'F0631', 'F0632', 'F0633', 'F0634', 'F064', 'F068', 'F07', 'F070', 'F078', 'F0781', 'F0789', 
'F079', 'F09', 'F10', 'F101', 'F1010', 'F1011', 'F1012', 'F10120', 'F10121', 'F10129', 'F1014', 'F1015', 'F10150', 'F10151', 'F10159', 'F1018', 'F10180', 'F10181', 'F10182', 'F10188', 'F1019', 'F102', 'F1020', 
'F1021', 'F1022', 'F10220', 'F10221', 'F10229', 'F1023', 'F10230', 'F10231', 'F10232', 'F10239', 'F1024', 'F1025', 'F10250', 'F10251', 'F10259', 'F1026', 'F1027', 'F1028', 'F10280', 'F10281', 'F10282', 'F10288', 
'F1029', 'F109', 'F1092', 'F10920', 'F10921', 'F10929', 'F1094', 'F1095', 'F10950', 'F10951', 'F10959', 'F1096', 'F1097', 'F1098', 'F10980', 'F10981', 'F10982', 'F10988', 'F1099', 'F11', 'F111', 'F1110', 'F1111', 
'F1112', 'F11120', 'F11121', 'F11122', 'F11129', 'F1114', 'F1115', 'F11150', 'F11151', 'F11159', 'F1118', 'F11181', 'F11182', 'F11188', 'F1119', 'F112', 'F1120', 'F1121', 'F1122', 'F11220', 'F11221', 'F11222', 
'F11229', 'F1123', 'F1124', 'F1125', 'F11250', 'F11251', 'F11259', 'F1128', 'F11281', 'F11282', 'F11288', 'F1129', 'F119', 'F1190', 'F1192', 'F11920', 'F11921', 'F11922', 'F11929', 'F1193', 'F1194', 'F1195', 
'F11950', 'F11951', 'F11959', 'F1198', 'F11981', 'F11982', 'F11988', 'F1199', 'F12', 'F121', 'F1210', 'F1211', 'F1212', 'F12120', 'F12121', 'F12122', 'F12129', 'F1215', 'F12150', 'F12151', 'F12159', 'F1218', 
'F12180', 'F12188', 'F1219', 'F122', 'F1220', 'F1221', 'F1222', 'F12220', 'F12221', 'F12222', 'F12229', 'F1223', 'F1225', 'F12250', 'F12251', 'F12259', 'F1228', 'F12280', 'F12288', 'F1229', 'F129', 'F1290', 'F1292', 
'F12920', 'F12921', 'F12922', 'F12929', 'F1293', 'F1295', 'F12950', 'F12951', 'F12959', 'F1298', 'F12980', 'F12988', 'F1299', 'F13', 'F131', 'F1310', 'F1311', 'F1312', 'F13120', 'F13121', 'F13129', 'F1314', 'F1315', 
'F13150', 'F13151', 'F13159', 'F1318', 'F13180', 'F13181', 'F13182', 'F13188', 'F1319', 'F132', 'F1320', 'F1321', 'F1322', 'F13220', 'F13221', 'F13229', 'F1323', 'F13230', 'F13231', 'F13232', 'F13239', 'F1324',
'F1325', 'F13250', 'F13251', 'F13259', 'F1326', 'F1327', 'F1328', 'F13280', 'F13281', 'F13282', 'F13288', 'F1329', 'F139', 'F1390', 'F1392', 'F13920', 'F13921', 'F13929', 'F1393', 'F13930', 'F13931', 'F13932', 
'F13939', 'F1394', 'F1395', 'F13950', 'F13951', 'F13959', 'F1396', 'F1397', 'F1398', 'F13980', 'F13981', 'F13982', 'F13988', 'F1399', 'F14', 'F141', 'F1410', 'F1411', 'F1412', 'F14120', 'F14121', 'F14122', 'F14129', 
'F1414', 'F1415', 'F14150', 'F14151', 'F14159', 'F1418', 'F14180', 'F14181', 'F14182', 'F14188', 'F1419', 'F142', 'F1420', 'F1421', 'F1422', 'F14220', 'F14221', 'F14222', 'F14229', 'F1423', 'F1424', 'F1425', 
'F14250', 'F14251', 'F14259', 'F1428', 'F14280', 'F14281', 'F14282', 'F14288', 'F1429', 'F149', 'F1490', 'F1492', 'F14920', 'F14921', 'F14922', 'F14929', 'F1494', 'F1495', 'F14950', 'F14951', 'F14959', 'F1498', 
'F14980', 'F14981', 'F14982', 'F14988', 'F1499', 'F15', 'F151', 'F1510', 'F1511', 'F1512', 'F15120', 'F15121', 'F15122', 'F15129', 'F1514', 'F1515', 'F15150', 'F15151', 'F15159', 'F1518', 'F15180', 'F15181', 
'F15182', 'F15188', 'F1519', 'F152', 'F1520', 'F1521', 'F1522', 'F15220', 'F15221', 'F15222', 'F15229', 'F1523', 'F1524', 'F1525', 'F15250', 'F15251', 'F15259', 'F1528', 'F15280', 'F15281', 'F15282', 'F15288', 
'F1529', 'F159', 'F1590', 'F1592', 'F15920', 'F15921', 'F15922', 'F15929', 'F1593', 'F1594', 'F1595', 'F15950', 'F15951', 'F15959', 'F1598', 'F15980', 'F15981', 'F15982', 'F15988', 'F1599', 'F16', 'F161', 'F1610', 
'F1611', 'F1612', 'F16120', 'F16121', 'F16122', 'F16129', 'F1614', 'F1615', 'F16150', 'F16151', 'F16159', 'F1618', 'F16180', 'F16183', 'F16188', 'F1619', 'F162', 'F1620', 'F1621', 'F1622', 'F16220', 'F16221', 
'F16229', 'F1624', 'F1625', 'F16250', 'F16251', 'F16259', 'F1628', 'F16280', 'F16283', 'F16288', 'F1629', 'F169', 'F1690', 'F1692', 'F16920', 'F16921', 'F16929', 'F1694', 'F1695', 'F16950', 'F16951', 'F16959', 
'F1698', 'F16980', 'F16983', 'F16988', 'F1699', 'F17', 'F172', 'F1720', 'F17200', 'F17201', 'F17203', 'F17208', 'F17209', 'F1721', 'F17210', 'F17211', 'F17213', 'F17218', 'F17219', 'F1722', 'F17220', 'F17221', 
'F17223', 'F17228', 'F17229', 'F1729', 'F17290', 'F17291', 'F17293', 'F17298', 'F17299', 'F18', 'F181', 'F1810', 'F1811', 'F1812', 'F18120', 'F18121', 'F18129', 'F1814', 'F1815', 'F18150', 'F18151', 'F18159', 
'F1817', 'F1818', 'F18180', 'F18188', 'F1819', 'F182', 'F1820', 'F1821', 'F1822', 'F18220', 'F18221', 'F18229', 'F1824', 'F1825', 'F18250', 'F18251', 'F18259', 'F1827', 'F1828', 'F18280', 'F18288', 'F1829', 'F189', 
'F1890', 'F1892', 'F18920', 'F18921', 'F18929', 'F1894', 'F1895', 'F18950', 'F18951', 'F18959', 'F1897', 'F1898', 'F18980', 'F18988', 'F1899', 'F19', 'F191', 'F1910', 'F1911', 'F1912', 'F19120', 'F19121', 'F19122', 
'F19129', 'F1914', 'F1915', 'F19150', 'F19151', 'F19159', 'F1916', 'F1917', 'F1918', 'F19180', 'F19181', 'F19182', 'F19188', 'F1919', 'F192', 'F1920', 'F1921', 'F1922', 'F19220', 'F19221', 'F19222', 'F19229', 
'F1923', 'F19230', 'F19231', 'F19232', 'F19239', 'F1924', 'F1925', 'F19250', 'F19251', 'F19259', 'F1926', 'F1927', 'F1928', 'F19280', 'F19281', 'F19282', 'F19288', 'F1929', 'F199', 'F1990', 'F1992', 'F19920', 
'F19921', 'F19922', 'F19929', 'F1993', 'F19930', 'F19931', 'F19932', 'F19939', 'F1994', 'F1995', 'F19950', 'F19951', 'F19959', 'F1996', 'F1997', 'F1998', 'F19980', 'F19981', 'F19982', 'F19988', 'F1999', 'F20', 
'F200', 'F201', 'F202', 'F203', 'F205', 'F208', 'F2081', 'F2089', 'F209', 'F21', 'F22', 'F23', 'F24', 'F25', 'F250', 'F251', 'F258', 'F259', 'F28', 'F29', 'F30', 'F301', 'F3010', 'F3011', 'F3012', 'F3013', 
'F302', 'F303', 'F304', 'F308', 'F309', 'F31', 'F310', 'F311', 'F3110', 'F3111', 'F3112', 'F3113', 'F312', 'F313', 'F3130', 'F3131', 'F3132', 'F314', 'F315', 'F316', 'F3160', 'F3161', 'F3162', 'F3163', 'F3164',
'F317', 'F3170', 'F3171', 'F3172', 'F3173', 'F3174', 'F3175', 'F3176', 'F3177', 'F3178', 'F318', 'F3181', 'F3189', 'F319', 'F32', 'F320', 'F321', 'F322', 'F323', 'F324', 'F325', 'F328', 'F3289', 'F329', 'F33', 
'F330', 'F331', 'F332', 'F333', 'F334', 'F3340', 'F3341', 'F3342', 'F338', 'F339', 'F34', 'F340', 'F341', 'F348', 'F3481', 'F3489', 'F349', 'F39', 'F40', 'F400', 'F4000', 'F4001', 'F4002', 'F401', 'F4010', 'F4011', 
'F402', 'F4021', 'F40210', 'F40218', 'F4022', 'F40220', 'F40228', 'F4023', 'F40230', 'F40231', 'F40232', 'F40233', 'F4024', 'F40240', 'F40241', 'F40242', 'F40243', 'F40248', 'F4029', 'F40290', 'F40291', 'F40298', 
'F408', 'F409', 'F41', 'F410', 'F411', 'F413', 'F418', 'F419', 'F42', 'F422', 'F423', 'F424', 'F428', 'F429', 'F43', 'F430', 'F431', 'F4310', 'F4311', 'F4312', 'F432', 'F4320', 'F4321', 'F4322', 'F4323', 'F4324', 
'F4325', 'F4329', 'F438', 'F439', 'F44', 'F440', 'F441', 'F442', 'F444', 'F445', 'F446', 'F447', 'F448', 'F4481', 'F4489', 'F449', 'F45', 'F450', 'F451', 'F452', 'F4520', 'F4521', 'F4522', 'F4529', 'F454', 'F4541', 
'F4542', 'F458', 'F459', 'F48', 'F481', 'F482', 'F488', 'F489', 'F50', 'F500', 'F5000', 'F5001', 'F5002', 'F502', 'F508', 'F5081', 'F5082', 'F5089', 'F509', 'F51', 'F510', 'F5101', 'F5102', 'F5103', 'F5104', 'F5105', 
'F5109', 'F511', 'F5111', 'F5112', 'F5113', 'F5119', 'F513', 'F514', 'F515', 'F518', 'F519', 'F52', 'F520', 'F521', 'F522', 'F5221', 'F5222', 'F523', 'F5231', 'F5232', 'F524', 'F525', 'F526', 'F528', 'F529', 'F53', 
'F530', 'F531', 'F54', 'F55', 'F550', 'F551', 'F552', 'F553', 'F554', 'F558', 'F59', 'F60', 'F600', 'F601', 'F602', 'F603', 'F604', 'F605', 'F606', 'F607', 'F608', 'F6081', 'F6089', 'F609', 'F63', 'F630', 'F631', 
'F632', 'F633', 'F638', 'F6381', 'F6389', 'F639', 'F64', 'F640', 'F641', 'F642', 'F648', 'F649', 'F65', 'F650', 'F651', 'F652', 'F653', 'F654', 'F655', 'F6550', 'F6551', 'F6552', 'F658', 'F6581', 'F6589', 'F659',
'F66', 'F68', 'F681', 'F6810', 'F6811', 'F6812', 'F6813', 'F688', 'F68A', 'F69', 'F70', 'F71', 'F72', 'F73', 'F78', 'F79', 'F80', 'F800', 'F801', 'F802', 'F804', 'F808', 'F8081', 'F8082', 'F8089', 'F809', 'F81',
'F810', 'F812', 'F818', 'F8181', 'F8189', 'F819', 'F82', 'F84', 'F840', 'F842', 'F843', 'F845', 'F848', 'F849', 'F88', 'F89', 'F90', 'F900', 'F901', 'F902', 'F908', 'F909', 'F91', 'F910', 'F911', 'F912', 'F913',
'F918', 'F919', 'F93', 'F930', 'F938', 'F939', 'F94', 'F940', 'F941', 'F942', 'F948', 'F949', 'F95', 'F950', 'F951', 'F952', 'F958', 'F959', 'F98', 'F980', 'F981', 'F982', 'F9821', 'F9829', 'F983', 'F984', 'F985', 
'F988', 'F989', 'F99'                                            )                       
						                GROUP BY CH.MVDID
							           HAVING COUNT(DISTINCT CH.[StatementFromDate]) > 3
							          ) a			
							  )
		)
		    SELECT MVDID 
			  FROM cteMembers m
             WHERE NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = m.MVDID)

ProcedureEnd:

	RETURN

END