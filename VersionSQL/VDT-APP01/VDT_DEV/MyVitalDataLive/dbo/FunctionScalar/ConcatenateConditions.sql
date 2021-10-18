/****** Object:  Function [dbo].[ConcatenateConditions]    Committed by VersionSQL https://www.versionsql.com ******/

--dbo.Rpt_MemberDiseaseCondition S79YR53GW6
--CREATE
--
CREATE 
FUNCTION dbo.ConcatenateConditions(@ICeNumber varchar(15),@DiseaseID int)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @Output VARCHAR(8000)
	SELECT @Output = COALESCE(@Output+', ', '') + CONVERT(varchar(50), LDC.DiseaseCondName)
	FROM	dbo.MainDiseaseCond MDC
	JOIN dbo.[LookupDiseaseCond] LDC
	ON LDC.DiseaseId = MDC.DiseaseId
	WHERE	MDC.ICENUMBER = @ICeNumber
	AND MDC.DiseaseCondID = LDC.DiseaseCondID
	AND LDC.DiseaseID = @DiseaseID
	ORDER BY LDC.DiseaseCondName
	RETURN @Output
END