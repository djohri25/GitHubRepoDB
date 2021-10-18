/****** Object:  Procedure [dbo].[Del_MainHealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_MainHealthTest]

@MonId int,
@IceNumber varchar(15)

as

SET NOCOUNT ON

DELETE MainHealthTest WHERE TestId = @MonId AND ICENUMBER = @IceNumber