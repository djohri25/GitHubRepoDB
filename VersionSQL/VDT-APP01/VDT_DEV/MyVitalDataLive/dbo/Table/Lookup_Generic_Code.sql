/****** Object:  Table [dbo].[Lookup_Generic_Code]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_Generic_Code](
	[CodeID] [int] IDENTITY(1,1) NOT NULL,
	[CodeTypeID] [int] NULL,
	[Cust_ID] [int] NULL,
	[Label] [varchar](100) NULL,
	[Label_Desc] [varchar](500) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[PRODUCTID] [int] NULL,
	[IsDeleted] [bit] NULL,
	[UpdatedBy] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL,
 CONSTRAINT [PK__Lookup_G__C6DE2C354A388B5C] PRIMARY KEY CLUSTERED 
(
	[CodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_Lookup_Generic_Code] UNIQUE NONCLUSTERED 
(
	[CodeTypeID] ASC,
	[Cust_ID] ASC,
	[Label] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Lookup_Generic_Code] ADD  CONSTRAINT [DF_Lookup_Generic_Code_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[Lookup_Generic_Code] ADD  CONSTRAINT [DF_Lookup_Generic_Code_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[Lookup_Generic_Code]  WITH NOCHECK ADD  CONSTRAINT [FK__Lookup_Ge__PRODU__799F8910] FOREIGN KEY([PRODUCTID])
REFERENCES [dbo].[Products] ([ID])
ALTER TABLE [dbo].[Lookup_Generic_Code] CHECK CONSTRAINT [FK__Lookup_Ge__PRODU__799F8910]
ALTER TABLE [dbo].[Lookup_Generic_Code]  WITH NOCHECK ADD  CONSTRAINT [FK_Lookup_Generic_Code_Lookup_Generic_Code_Type] FOREIGN KEY([CodeTypeID])
REFERENCES [dbo].[Lookup_Generic_Code_Type] ([CodeTypeID])
ALTER TABLE [dbo].[Lookup_Generic_Code] CHECK CONSTRAINT [FK_Lookup_Generic_Code_Lookup_Generic_Code_Type]