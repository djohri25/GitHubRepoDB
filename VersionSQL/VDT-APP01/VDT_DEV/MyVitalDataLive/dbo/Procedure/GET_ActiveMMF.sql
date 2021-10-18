/****** Object:  Procedure [dbo].[GET_ActiveMMF]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Raghu C
-- Create date: 08/29/19
-- Description:	This SP returns the all active MMF's which has Member Assignment. 
-- exec Get_ActiveMMF '16577456118885332'
-- =============================================
CREATE PROCEDURE [dbo].[GET_ActiveMMF]
	
	@MVDID varchar(30) null	

AS
BEGIN
	DECLARE @v_assignment_type_code_mmf int;
		SELECT
			@v_assignment_type_code_mmf = CodeID
			FROM
			Lookup_Generic_Code_Type lgct
			INNER JOIN Lookup_Generic_Code lgc
			ON lgc.CodeTypeID = lgct.CodeTypeID
			AND lgc.Label = 'MMF'
			WHERE
			lgct.CodeType = 'AssignmentType';
	
	SELECT mmf.CaseProgram,fmo.*
	FROM ABCBS_MemberManagement_Form mmf
	INNER JOIN Final_MemberOwner fmo
	on fmo.MVDID = mmf.MVDID
	and
	(
		fmo.OwnerName = mmf.q16CareQ
		or  fmo.OwnerName = mmf.q1CaseOwner
		or  fmo.OwnerName = mmf.q19AssignedUser
	)
	and AssignmentTypeCodeID = @v_assignment_type_code_mmf
	where
	mmf.SectionCompleted < 3
	and isNull(mmf.CaseProgram,'') != ''
	and isNull(mmf.q15AssignTo, '') != ''
	and mmf.MVDID=@MVDID
	and fmo.IsDeactivated = 0;
END