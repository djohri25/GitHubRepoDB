/****** Object:  Function [dbo].[Get_TinArray]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Misha
-- Create date: 02/28/2017
-- =============================================
CREATE FUNCTION [dbo].[Get_TinArray]
(
	@User varchar(50) = NULL,
    @TIN varchar(250) = 'ALL'
)
RETURNS @TIN_Array TABLE(TIN varchar(50))
BEGIN
	DECLARE @TIN_Temp varchar(250)
	
	IF (@TIN != 'ALL')
	BEGIN
		SELECT @TIN_Temp = @TIN
		INSERT INTO @TIN_Array
		SELECT LTRIM(RTRIM(item))
		FROM [dbo].[splitstring](@TIN_Temp, ',')
	END
	ELSE
	BEGIN
		IF @User IS NOT NULL
		BEGIN
			--SELECT @TIN = '' -- TIN list is specified by the logged in user

			INSERT INTO @TIN_Array
			SELECT GroupName
			FROM [dbo].[MDUser] a
			JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
			JOIN MDGroup c ON b.mdGroupID = c.ID
			WHERE username = @User
		END
	END

    RETURN
END