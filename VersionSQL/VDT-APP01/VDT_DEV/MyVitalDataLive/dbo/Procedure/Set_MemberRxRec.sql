/****** Object:  Procedure [dbo].[Set_MemberRxRec]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MemberRxRec]

@MedRecs [dbo].[MedRecExt] READONLY 

AS

BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from

-- interfering with SELECT statements.

SET NOCOUNT ON;



BEGIN TRY 

-- Reenabled the DeDup section to take out duplicates JPG 7/22/2019 1230pm

WITH dedupe AS (SELECT DISTINCT CustID,

MVDID,

ReconDateTime,

NDC,

RxStartDate,

ReconStatus,

Quantity,

DaysSupply,

CreatedBy,

SessionID FROM @MedRecs)

MERGE dbo.MainMedRec WITH (HOLDLOCK) AS T

USING dedupe AS S --USING @MedRecs AS S

ON T.CustID = S.CustID 

AND T.MVDID = S.MVDID 

AND T.SessionID = S.SessionID 

AND T.NDC = S.NDC 

AND T.RxStartDate = S.RxStartDate 

--AND T.ReconDateTime = S.ReconDateTime

--AND T.ReconStatus = S.ReconStatus

WHEN MATCHED AND 

(

-- T.CustID <> S.CustID

--OR T.MVDID <> S.MVDID

--OR T.SessionID <> S.SessionID

--OR T.NDC <> S.NDC

--OR T.RxStartDate <> S.RxStartDate

--OR 

T.ReconDateTime <> S.ReconDateTime

OR T.ReconStatus <> S.ReconStatus

)

THEN 

UPDATE SET 

T.ReconDateTime = S.ReconDateTime,

T.ReconStatus = S.ReconStatus,

T.CreatedBy = S.CreatedBy

WHEN NOT MATCHED THEN

INSERT (

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

DECLARE @ErrorMessage varchar(max); 

DECLARE @ErrorSeverity INT; 

DECLARE @ErrorState INT; 



SELECT 

@ErrorMessage = ERROR_MESSAGE(), 

@ErrorSeverity = ERROR_SEVERITY(), 

@ErrorState = ERROR_STATE(); 



-- Use RAISERROR inside the CATCH block to return error 

-- information about the original error that caused 

-- execution to jump to the CATCH block. 

RAISERROR (@ErrorMessage, -- Message text. 

@ErrorSeverity, -- Severity. 

@ErrorState -- State. 

); 

END CATCH





END