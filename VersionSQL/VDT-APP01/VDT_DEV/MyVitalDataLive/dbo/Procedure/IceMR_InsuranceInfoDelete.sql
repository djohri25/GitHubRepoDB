/****** Object:  Procedure [dbo].[IceMR_InsuranceInfoDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_InsuranceInfoDelete]

@ICENUMBER varchar(15)

as

set nocount on

DELETE MainInsurance WHERE ICENUMBER = @ICENUMBER