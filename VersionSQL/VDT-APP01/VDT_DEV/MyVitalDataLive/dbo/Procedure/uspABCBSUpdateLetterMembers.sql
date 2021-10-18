/****** Object:  Procedure [dbo].[uspABCBSUpdateLetterMembers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sunil Nokku
-- Create date: 07/15/2019
-- Description:	To flag the Members for the generation of Batch Letters for (ABCBS) (N,B for Batch)(Y,C for Cancel)
-- Changes:		
-- =============================================
CREATE PROCEDURE [dbo].[uspABCBSUpdateLetterMembers]
	@ID						INT,
	@LetterDelete			VARCHAR(5)	,
	@LetterFlag				VARCHAR(20)	
AS
BEGIN
	SET NOCOUNT ON
		
		BEGIN    /* Update Letter Members */
			
			UPDATE dbo.LetterMembers
			SET LetterDelete	= @LetterDelete,
				LetterFlag		= @LetterFlag,
				Processed		= 'N',
				BatchID         = 0
			FROM dbo.LetterMembers
			WHERE ID			= @ID

		END

END