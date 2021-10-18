/****** Object:  Table [dbo].[Lookup_HPActionType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_HPActionType](
	[ActionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ActionTypeDescription] [varchar](255) NOT NULL,
	[Cust_ID] [int] NULL,
	[LobId] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ActionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Lookup_HPActionType] ADD  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[Lookup_HPActionType] ADD  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[Lookup_HPActionType]  WITH CHECK ADD  CONSTRAINT [FK_HPActionType_Generic_Code_Type_LOB] FOREIGN KEY([LobId])
REFERENCES [dbo].[Lookup_Generic_Code] ([CodeID])
ALTER TABLE [dbo].[Lookup_HPActionType] CHECK CONSTRAINT [FK_HPActionType_Generic_Code_Type_LOB]