/****** Object:  Procedure [dbo].[Get_MemberName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 10/6/2009
-- Modify date: 1/12/2010
-- Description:	Returns member's ID, name and DOB having the specified customer and either ID or Name and DOB.
-- =============================================
CREATE PROCEDURE [dbo].[Get_MemberName] 
	@id nvarchar(20) = null, 
	@cust int,
	@firstName varchar(50) = null,
	@lastName varchar(50) = null,
	@dob smalldatetime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF ISNULL(@id, '') <> ''
		SELECT	l.InsMemberId, m.FirstName, m.LastName, m.DOB
		FROM	MainPersonalDetails AS m INNER JOIN
				Link_MVDID_CustID AS l ON m.ICENUMBER = l.MVDId
		WHERE	Cust_ID = @cust AND InsMemberId = @id
	ELSE
		SELECT	TOP 2 l.InsMemberId, m.FirstName, m.LastName, m.DOB
		FROM	MainPersonalDetails AS m INNER JOIN
				Link_MVDID_CustID AS l ON m.ICENUMBER = l.MVDId
		WHERE	Cust_ID = @cust AND 
				(m.FirstName LIKE ISNULL(@firstName, '') + '%') AND 
				(m.LastName LIKE ISNULL(@lastName, '') + '%') AND 
				(m.DOB = @DOB OR @DOB IS NULL)
END