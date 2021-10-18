/****** Object:  Procedure [dbo].[uspUpdateMiscellaneousTables]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE proc [dbo].[uspUpdateMiscellaneousTables] 

as

SET NOCOUNT ON

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/11/2019
-- Description: Synch NurseLicense, LookUp and Batch Header Tables between IMPORT01 and APP01
-- =============================================

Declare @TableName varchar(50)
Declare @RunSql varchar(8000)

If Object_ID('TempDB.dbo.#TableNames','U') is not null
Drop Table #TableNames

set rowcount 0

Select *
Into #TableNames
From (values 
('ABCBS_NurseLicense'),
('BatchHeader'),
 ('LookUpAdjustmentReason'),
('LookUpAdmitType'),
('LookUpBillType'),
('LookUpClaimStatus'),
('LookUpRXClaimStatus'),
('LookUpCompanyName'),
('LookUpCountyName'),
('LookUpDataSource'),
('LookUpDrugDEA'),
('LookUpRXMultiSource'),
('LookUpDrugSet'),
('LookUpDrugTierAca'),
('LookUpDrugTierComm'),
('LookUpDrugTierGovt'),
('LookUpDischargeStatus'),
('LookUpGroup'),
('LookUpHierbenefitLOB'),
('LookUpHierNet'),
('LookUpHierProd'),
('LookUpHierRateTypeCode'),
('LookUpMemberTerminateCode'),
('LookUpMemberRelationship'),
('LookUpLOB'),
('LookUpLineReasonCode'),
('LookUpSubgroup')) T(TableName)

Set RowCount 1
Select Top 1 @TableName = TableName From #TableNames

While @@RowCount <> 0
Begin
	Set RowCount 0
	
	Set @RunSql= 'Truncate Table dbo.'+@TableName+'
	Insert Into dbo.'+@TableName+'
	Select *
	From [VDT-IMPORT01].BatchImportABCBS.dbo.'+@TableName
	Print @RunSql
	Exec(@RunSql)

	Delete From #TableNames Where TableName =@TableName

	
	Set RowCount 1
	
	Select Top 1 @TableName = TableName From #TableNames
End