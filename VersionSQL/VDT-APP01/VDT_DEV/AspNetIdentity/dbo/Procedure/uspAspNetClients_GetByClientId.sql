/****** Object:  Procedure [dbo].[uspAspNetClients_GetByClientId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		nelanwer
-- Create date: 06/19/2019
-- Description:	Gets the Clients data by ClientId
-- =============================================
CREATE PROCEDURE [dbo].[uspAspNetClients_GetByClientId]
	-- Add the parameters for the stored procedure here
	@ClientId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * 
	FROM AspNetClients
	WHERE ClientId=@ClientId
END