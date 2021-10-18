/****** Object:  Table [dbo].[TempCISMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempCISMember](
	[MVDID] [varchar](20) NOT NULL,
	[DOB] [datetime] NULL,
	[InsMemberID] [varchar](20) NULL,
	[DTaP_Complete] [bit] NULL,
	[IPV_Complete] [bit] NULL,
	[MMR_Complete] [bit] NULL,
	[HiB_Complete] [bit] NULL,
	[HepatitisB_Complete] [bit] NULL,
	[VZV_Complete] [bit] NULL,
	[Pneumococcal_Complete] [bit] NULL,
	[HepatitisA_Complete] [bit] NULL,
	[Rotavirus_Complete] [bit] NULL,
	[Influenza_Complete] [bit] NULL,
 CONSTRAINT [PK_TempCISMember] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [DTaP_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [IPV_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [MMR_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [HiB_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [HepatitisB_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [VZV_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [Pneumococcal_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [HepatitisA_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [Rotavirus_Complete]
ALTER TABLE [dbo].[TempCISMember] ADD  DEFAULT ((0)) FOR [Influenza_Complete]