/****** Object:  Table [dbo].[MainCarePlanMemberSignature]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberSignature](
	[SignatureID] [bigint] IDENTITY(1,1) NOT NULL,
	[CarePlanID] [bigint] NOT NULL,
	[SignatureDate] [datetime] NOT NULL,
	[eSignature] [varbinary](3000) NOT NULL,
	[userid] [int] NOT NULL,
	[cpSection] [int] NULL,
	[SignatureInactiveDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_MainCarePlanMemberSignature] PRIMARY KEY CLUSTERED 
(
	[SignatureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]