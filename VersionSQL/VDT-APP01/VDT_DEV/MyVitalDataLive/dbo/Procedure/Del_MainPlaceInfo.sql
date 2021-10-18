/****** Object:  Procedure [dbo].[Del_MainPlaceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_MainPlaceInfo]

@RecNum int

as

set nocount on

DELETE MainPlaces
WHERE RecordNumber = @RecNum