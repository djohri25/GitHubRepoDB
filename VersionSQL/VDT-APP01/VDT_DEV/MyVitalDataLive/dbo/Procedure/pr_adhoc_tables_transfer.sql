/****** Object:  Procedure [dbo].[pr_adhoc_tables_transfer]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[pr_adhoc_tables_transfer]
AS
/*

Created by : Sunil Nokku
Purpose	   : To transfer tables daily to adhoc
Date       : 1/4/2020

*/
BEGIN

EXEC [VD-ADHOC].EnterpriseLayerVPNLive.sys.sp_executesql N'TRUNCATE TABLE dbo.FinalMemberETL'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNLive.dbo.FinalMemberETL
SELECT * FROM MyVitalDataLive.dbo.FinalMemberETL

EXEC [VD-ADHOC].EnterpriseLayerVPNUAT.sys.sp_executesql N'TRUNCATE TABLE dbo.FinalMemberETL'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNUAT.dbo.FinalMemberETL
SELECT * FROM MyVitalDataUAT.dbo.FinalMemberETL

EXEC [VD-ADHOC].EnterpriseLayerVPNLive.sys.sp_executesql N'TRUNCATE TABLE dbo.ComputedCareQueue'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNLive.dbo.ComputedCareQueue
SELECT * FROM MyVitalDataLive.dbo.ComputedCareQueue

EXEC [VD-ADHOC].EnterpriseLayerVPNUAT.sys.sp_executesql N'TRUNCATE TABLE dbo.ComputedCareQueue'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNUAT.dbo.ComputedCareQueue
SELECT * FROM MyVitalDataUAT.dbo.ComputedCareQueue

EXEC [VD-ADHOC].EnterpriseLayerVPNLive.sys.sp_executesql N'TRUNCATE TABLE dbo.NurseLicensure'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNLive.dbo.NurseLicensure
SELECT * FROM MyVitalDataLive.dbo.NurseLicensure

EXEC [VD-ADHOC].EnterpriseLayerVPNUAT.sys.sp_executesql N'TRUNCATE TABLE dbo.NurseLicensure'

INSERT INTO [VD-ADHOC].EnterpriseLayerVPNUAT.dbo.NurseLicensure
SELECT * FROM MyVitalDataUAT.dbo.NurseLicensure

END