/****** Object:  Procedure [dbo].[Get_MemberRxRec]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberRxRec]
--Declare
@MVDID varchar(30),
@RecDate datetime = null
AS
-- Modified by ezanelli,jpons on 2020-12-30 to streamline by removing MERGE; and also, use readuncommitted hint
BEGIN
	SET NOCOUNT ON

SELECT
	CustID,
	MVDID,
	ReconDateTime,
	NDC,
	RxStartDate,
	cast(ReconStatus as int) ReconStatus,
	Quantity,
	DaysSupply,
	CreatedBy,
	SessionID
	FROM
	MainMedRec (readuncommitted)
	WHERE
	MVDID = @MVDID;

END