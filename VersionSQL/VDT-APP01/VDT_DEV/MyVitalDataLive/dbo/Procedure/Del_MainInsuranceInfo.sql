/****** Object:  Procedure [dbo].[Del_MainInsuranceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_MainInsuranceInfo]

@RecNum int

AS

SET NOCOUNT ON

DELETE MainInsurance WHERE RecordNumber = @RecNum