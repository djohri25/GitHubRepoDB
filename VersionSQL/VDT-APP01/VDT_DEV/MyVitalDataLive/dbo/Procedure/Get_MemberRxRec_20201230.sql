/****** Object:  Procedure [dbo].[Get_MemberRxRec_20201230]    Committed by VersionSQL https://www.versionsql.com ******/

-- Returns the list of medication reconcilitaiton for the member / date provided

CREATE PROCEDURE [dbo].[Get_MemberRxRec_20201230]
--Declare
@MVDID varchar(30),
@RecDate datetime = null
AS
BEGIN
SET NOCOUNT ON

--set @ICENUMBER=N'16MW824027'
DECLARE @ErrorMessage varchar(max); 
DECLARE @ErrorSeverity INT; 
DECLARE @ErrorState INT; 

declare @tempMedRec table (
ID int,
CustID int,
[MVDID] [varchar](30),
[ReconDateTime] [datetime],
[NDC] [varchar](20),
[RxStartDate] [datetime],
[ReconStatus] int,
[Quantity] [varchar](50) NULL,
[DaysSupply] [varchar](50) NULL,
[CreatedBy] [nvarchar](250) NULL,
[SessionID] [nvarchar](40) NULL
)

declare @date1 datetime = null;

if (IsNull(@RecDate,0) = 0)
select @date1 = max(ReconDateTime) from MainMedRec where MVDID = @MVDID
else
set @date1 = @RecDate

BEGIN TRY

MERGE @tempMedRec AS T
USING dbo.MainMedRec AS S
ON T.CustID = S.CustID 
AND T.MVDID = S.MVDID 
AND T.SessionID = S.SessionID 
AND T.NDC = S.NDC 
AND T.RxStartDate = S.RxStartDate 
WHEN MATCHED AND 
(
T.CustID <> S.CustID
OR T.MVDID <> S.MVDID
OR T.SessionID <> S.SessionID
OR T.NDC <> S.NDC
OR T.RxStartDate <> S.RxStartDate
)
THEN 
UPDATE SET 
T.CustID = S.CustID,
T.MVDID = S.MVDID,
T.ReconDateTime = S.ReconDateTime,
T.NDC = S.NDC,
T.RxStartDate = S.RxStartDate,
T.ReconStatus = S.ReconStatus,
T.Quantity = S.Quantity,
T.DaysSupply = S.DaysSupply,
T.CreatedBy = S.CreatedBy,
T.SessionID = S.SessionID
WHEN NOT MATCHED THEN
INSERT ([ID],
[CustID],
[MVDID],
[ReconDateTime],
[NDC],
[RxStartDate],
[ReconStatus],
[Quantity],
[DaysSupply],
[CreatedBy],
[SessionID])
VALUES
(
S.[ID],
S.[CustID],
S.[MVDID],
S.[ReconDateTime],
S.[NDC],
S.[RxStartDate],
S.[ReconStatus],
S.[Quantity],
S.[DaysSupply],
S.[CreatedBy],
S.[SessionID]
);

END TRY
BEGIN CATCH
SELECT 
@ErrorMessage = ERROR_MESSAGE(), 
@ErrorSeverity = ERROR_SEVERITY(), 
@ErrorState = ERROR_STATE(); 

RAISERROR (@ErrorMessage, @ErrorSeverity,@ErrorState); 
END CATCH;

select
CustID,
MVDID,
ReconDateTime,
NDC,
RxStartDate,
ReconStatus,
Quantity,
DaysSupply,
CreatedBy,
SessionID
from @tempMedRec
WHERE MVDID =@MVDID

END