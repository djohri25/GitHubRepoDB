/****** Object:  Table [dbo].[DischargeReportFacility_Unknown]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DischargeReportFacility_Unknown](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FacilityName] [varchar](100) NULL,
	[VisitSourceName] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_DischargeReportFacility_Unknown] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[DischargeReportFacility_Unknown] ADD  CONSTRAINT [DF_DischargeReportFacility_Unknown_Created]  DEFAULT (getdate()) FOR [Created]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/29/2015
-- Description:	<Description,,>
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE TRIGGER [dbo].[SendNotificationTrigger]
   ON  [dbo].[DischargeReportFacility_Unknown]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

    declare @FacilityName varchar(100), @visitSourceName varchar(50), @EmailBody varchar(max)

	set @FacilityName = (select FacilityName from inserted)
	set @visitSourceName = (select VisitSourceName from inserted)

	SELECT @EmailBody =
	'<h2>Discharge Report contains unknown facility</h2>
	<b>Facility Name:</b> ' + @FacilityName + '<br/>
	<b>Record source:</b> ' + @visitSourceName +
	'<h3>Please update table DischargeReportFacility with name and NPI of the new facility</h3>'

	EXEC msdb.dbo.sp_send_dbmail 
	@profile_name='VD-APP01',
--	@recipients='MGrigoriev@vitaldatatech.com;WRodriguez@vitaldatatech.com;',
	@recipients='alerts@vitaldatatech.com',
	@body_format='HTML',
	@subject='Unknown Discharge Facility',
	@body= @EmailBody


END

ALTER TABLE [dbo].[DischargeReportFacility_Unknown] DISABLE TRIGGER [SendNotificationTrigger]