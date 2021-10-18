/****** Object:  Procedure [dbo].[Get_MemberRxRecDates]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberRxRecDates]
--Declare
 	@MVDID varchar(30)
AS
BEGIN
SET NOCOUNT ON

--set @ICENUMBER=N'16MW824027'

declare @tempMedRecDates table (
	[ReconDateTime] [datetime]
)

insert into @tempMedRecDates (
	[ReconDateTime]
)

SELECT ReconDateTime
FROM dbo.MainMedRec
WHERE MVDID = @MVDID

select ReconDateTime
from @tempMedRecDates
order by ReconDateTime desc

END