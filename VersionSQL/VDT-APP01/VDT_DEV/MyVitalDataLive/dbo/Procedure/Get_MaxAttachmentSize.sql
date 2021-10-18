/****** Object:  Procedure [dbo].[Get_MaxAttachmentSize]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/14/2008
-- Description:	Returns the max size (in MB) of all attachements
--		uploaded for MyVitalData profile specified by
--		the argument. Default value is 10Mb
-- =============================================
CREATE Procedure [dbo].[Get_MaxAttachmentSize]
	@IceNumber varchar(15)
As
	SET NOCOUNT ON

	SELECT ISNULL(MaxAttachment/1024.0,10) 
		FROM MainUserName mun join MainICEGROUP mig on mun.ICEGROUP = mig.ICEGROUP
			join MainICENUMBERGroups ming on mig.ICEGROUP = ming.ICEGROUP WHERE ICENUMBER = @IceNumber