/****** Object:  Procedure [dbo].[Get_HPDoctorListByMember]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 08/06/2009
-- Description:	 Returns the list of Doctors associated with the member 
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPDoctorListByMember]
	@MemberId varchar(50),
	@Customer varchar(50)
AS
BEGIN

	SET NOCOUNT ON;

	-- Note: As of 8/6/2009 we use NPI for doctor ID. For efficiency purposes store doctor name 
	--	in Link table to avoid join

	declare @mvdid varchar(20)

	select @mvdid = mvdid from Link_MemberId_MVD_Ins
	where insmemberid = @memberid and cust_id = @customer

	select Doctor_Id, 
		isnull(DoctorLastName,'') + isnull(', ' + DoctorFirstName,'') + ' (' + Doctor_Id + ')' as DoctorName, 
		1 as isSelected 
	from dbo.Link_HPMember_Doctor
	where mvdid = @mvdid
END