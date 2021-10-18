/****** Object:  Procedure [dbo].[SET_MMFErrorLog]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Save Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[SET_MMFErrorLog]	
	@MVDID varchar(30) null,
	@FormID int null,
	@CreatedDate datetime null,
	@FieldChanged varchar(30) null,
	@Formdata varchar(max) null

AS
BEGIN
SET NOCOUNT ON;
-- i want to get the ID  MMF table

	Insert into MMFErrorLog (MVDID, FormID, CreateDate, FieldChanged, CopyofFormData)values(@MVDID, @FormID, @CreatedDate, @FieldChanged, @Formdata)
END