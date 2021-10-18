/****** Object:  Procedure [dbo].[Get_ComputedMemberAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- 10/31/2019 ezanelli modified to load from FinalMember

CREATE PROCEDURE
[dbo].[Get_ComputedMemberAlert] 
AS
BEGIN 
	SET NOCOUNT ON

	TRUNCATE TABLE  [dbo].[ComputedMemberAlert]

	INSERT INTO [dbo].[ComputedMemberAlert]
	(
		MVDID,
		PersonalHarm
	)
	SELECT DISTINCT
	MVDID,
	CASE
	WHEN PersonalHarm = 'Y' THEN 1
	ELSE 0
	END
	FROM
	FinalMemberETL;

END;