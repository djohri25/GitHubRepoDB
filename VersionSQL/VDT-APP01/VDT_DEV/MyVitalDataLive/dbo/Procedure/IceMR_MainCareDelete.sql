/****** Object:  Procedure [dbo].[IceMR_MainCareDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_MainCareDelete]

@ICENUMBER varchar(15)

as

set nocount on
Delete MainCareInfo
Where ICENUMBER = @ICENUMBER