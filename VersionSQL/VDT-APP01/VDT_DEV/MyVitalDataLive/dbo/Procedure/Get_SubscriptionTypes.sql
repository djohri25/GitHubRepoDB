/****** Object:  Procedure [dbo].[Get_SubscriptionTypes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SubscriptionTypes]

AS
BEGIN
	SET NOCOUNT ON;

	select ID, Name + ' - ' + convert(varchar(10),DurationValue) + ' ' + convert(varchar(10),DurationUnit) + ' $' + convert(varchar(10),Price) as Name 
	from dbo.MVD_SubscriptionType
	
END