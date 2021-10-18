/****** Object:  Table [dbo].[UserRole]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserRole](
	[UserRoleID] [uniqueidentifier] NOT NULL,
	[InternalID] [int] IDENTITY(1,1) NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [varchar](50) NULL,
	[Updated] [datetime] NOT NULL,
	[UpdatedBy] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[InternalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[UserRole] ADD  DEFAULT (newid()) FOR [UserRoleID]
ALTER TABLE [dbo].[UserRole] ADD  DEFAULT (getdate()) FOR [Created]
ALTER TABLE [dbo].[UserRole] ADD  DEFAULT (getdate()) FOR [Updated]
ALTER TABLE [dbo].[UserRole] ADD  DEFAULT ((1)) FOR [IsActive]