/****** Object:  View [dbo].[MobileMVDLink_Device_MVDMemberView]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.MobileMVDLink_Device_MVDMemberView
AS
SELECT ID,DeviceID,MVDID,Created,FirstName,LastName,HPMemberID,SecureQu2,SecureAn2
FROM MobileMVDDev.dbo.Link_Device_MVDMember
WHERE DB_NAME() = 'MyVitalDataDemo_BK_From_Live'
UNION ALL
SELECT ID,DeviceID,MVDID,Created,FirstName,LastName,HPMemberID,SecureQu2,SecureAn2
FROM MobileMVDLive.dbo.Link_Device_MVDMember
WHERE DB_NAME() = 'MyVitalDataLive'