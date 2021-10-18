/****** Object:  Procedure [dbo].[Get_OutgoingSMS]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/17/2008
-- Description:	Returns the list of SMS messages which need to be sent
-- =============================================
CREATE PROCEDURE [dbo].[Get_OutgoingSMS]
AS
BEGIN
	Select ID, Phone, Text
	from SendSMS
	Where SentDate is null
END