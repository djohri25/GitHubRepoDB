/****** Object:  Table [dbo].[MainICEGROUP]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainICEGROUP](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICEGROUP] [varchar](15) NOT NULL,
	[GroupMax] [int] NOT NULL,
	[GroupName] [varchar](50) NULL,
	[SoftwareKey] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainICEGROUP] PRIMARY KEY CLUSTERED 
(
	[ICEGROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]