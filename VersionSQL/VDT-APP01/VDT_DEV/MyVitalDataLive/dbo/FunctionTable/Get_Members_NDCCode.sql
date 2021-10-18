/****** Object:  Function [dbo].[Get_Members_NDCCode]    Committed by VersionSQL https://www.versionsql.com ******/

Create Function [dbo].[Get_Members_NDCCode]
(
	@MVDID		varchar(30),	@NDCCode	VARCHAR(max)
)
RETURNS @result TABLE (MVDID varchar(50))
AS
BEGIN
	
	INSERT INTO @result
	Select Distinct ICENUMBER from MainMedication WHere ICENUMBER = @MVDID and Code in (select item from  [dbo].[splitstring](@NDCCode,',')) GROUP BY ICENUMBER HAVING COUNT(*) >= 1

Return
END