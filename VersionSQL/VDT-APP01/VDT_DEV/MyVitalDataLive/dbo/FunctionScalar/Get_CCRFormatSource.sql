/****** Object:  Function [dbo].[Get_CCRFormatSource]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/17/2009
-- Description:	Returns XML Source node
--	formated according to CCR standard
-- =============================================
CREATE FUNCTION [dbo].[Get_CCRFormatSource]
(	@ActorID varchar(50), @ActorRole varchar(50)
)
RETURNS XML
AS
BEGIN
	DECLARE @XML xml

	set @XML =
	(	select (select @ActorID as ActorID,
			@ActorRole as 'ActorRole/Text'
			for xml path('Actor'),type,elements
		) 
		for xml path('Source'),type,elements
	)

	RETURN @XML

END