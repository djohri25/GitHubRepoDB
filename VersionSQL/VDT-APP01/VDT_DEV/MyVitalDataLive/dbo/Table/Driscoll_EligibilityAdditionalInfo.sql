/****** Object:  Table [dbo].[Driscoll_EligibilityAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Driscoll_EligibilityAdditionalInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[Cust_id] [int] NULL,
	[LobID] [int] NULL,
	[Plan_stratid] [varchar](50) NULL,
	[dual] [varchar](50) NULL,
	[MedicareID] [varchar](30) NULL,
	[medicare_effdt] [varchar](50) NULL,
	[medicare_termdt] [varchar](50) NULL,
	[migrant] [varchar](50) NULL,
	[benefit_code] [varchar](50) NULL,
	[waiver_toa] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
 CONSTRAINT [PK_Driscoll_EligibilityAdditionalInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Driscoll_EligibilityAdditionalInfo] ADD  CONSTRAINT [DF_Driscoll_EligibilityAdditionalInfo]  DEFAULT (getdate()) FOR [Created]
ALTER TABLE [dbo].[Driscoll_EligibilityAdditionalInfo]  WITH CHECK ADD  CONSTRAINT [FK_Driscoll_EligibilityAdditionalInfo_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[Driscoll_EligibilityAdditionalInfo] CHECK CONSTRAINT [FK_Driscoll_EligibilityAdditionalInfo_MainPersonalDetails]