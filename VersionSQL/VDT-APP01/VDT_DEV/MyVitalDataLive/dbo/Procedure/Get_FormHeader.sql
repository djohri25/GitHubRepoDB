/****** Object:  Procedure [dbo].[Get_FormHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author:		BDW 
-- Create date: 7/12/2016
-- Description:	Get form header values based on MVDID aka ICENUMBER
-- COMMENTS: Staff Interviewing is currently logged in user
-- EXEC [Get_FormHeader] 'CB324534', '13'
-- ========================================================

CREATE PROCEDURE [dbo].[Get_FormHeader]
@MVDID varchar(20), @CustID VARCHAR(20)=NULL
AS
BEGIN
	SET NOCOUNT ON;

SELECT  ICENUMBER,	
		b.InsMemberId,
		b.Cust_ID,
		LastName,
		FirstName,
		MiddleName,
		(Select GenderName From LookupGenderId Where
		GenderId = ISNULL(a.GenderId, 0)) As GenderName,				
		DOB				
FROM	MainPersonalDetails a
inner join Link_MVDID_CustID b on a.ICENUMBER = b.MVDId
inner join dbo.UserAdditionalInfo c on a.ICENUMBER = c.MVDID
WHERE ICENUMBER = @MVDID AND b.Cust_ID = @CustID
END