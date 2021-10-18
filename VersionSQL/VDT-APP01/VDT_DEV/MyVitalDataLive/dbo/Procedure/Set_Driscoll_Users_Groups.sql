/****** Object:  Procedure [dbo].[Set_Driscoll_Users_Groups]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_Driscoll_Users_Groups]
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tin (tin varchar(100))

	INSERT #tin
	SELECT DISTINCT(TIN)
	FROM dbo.MainSpecialist ms
	JOIN dbo.Link_MemberId_MVD_Ins mi
		ON ms.ICENUMBER = mi.MVDId
	WHERE mi.Cust_ID = 11
		AND mi.Active = 1
		AND ms.TIN != '' AND ms.TIN IS NOT NULL
		AND ms.NPI != '' AND ms.NPI IS NOT NULL
		AND ms.roleid = 1


	-- ***** GROUPS (TINS) *****

	--Add New Groups
	INSERT MDGroup (GroupName, Active, CreationDate, ModifyDate, IsNoteAlertGroup, CustID_Import)
	SELECT TIN, 1, GETDATE(), GETDATE(), 0, 11
	FROM #tin
	WHERE TIN NOT IN
		(
			SELECT GroupName
			FROM dbo.MDGroup
			WHERE CustID_Import = 11
		)

	--Update Secondary Names
	DECLARE @DateCreated Date
	SELECT @DateCreated = (SELECT TOP 1 CONVERT(DATE, created) FROM [VD-RPT01].[HPM_Import].[dbo].[DriscollProvider] ORDER BY id DESC)
	UPDATE [dbo].[MDGroup]  
	SET SecondaryName = dp.business_name
	FROM [dbo].[MDGroup] md
	INNER JOIN [VD-RPT01].[HPM_Import].[dbo].[DriscollProvider] dp
		ON md.GroupName = dp.tin
	WHERE md.CustID_Import = 11
		AND CONVERT(DATE, dp.Created) = @DateCreated

	--Activate Inactive Groups
	UPDATE MDGroup
	SET Active = 1 
	WHERE GroupName IN
		(
			SELECT TIN
			FROM #tin
		)
		AND CustID_Import = 11

	--DeActivate OLD Groups
	UPDATE MDGroup
	SET Active = 0 
	WHERE GroupName NOT IN
		(
			SELECT TIN
			FROM #tin
		)
		AND CustID_Import = 11


  	-- ***** NPIs *****

	CREATE TABLE #NPIs (npi varchar(100))

	DECLARE @tin varchar(100), @groupid int

	WHILE EXISTS (SELECT * FROM #tin)
	BEGIN
		SELECT TOP 1 @tin = tin
		FROM #tin

		SELECT @groupid = [ID]
		FROM [dbo].[MDGroup]
		WHERE GroupName = @tin
		
		IF EXISTS (
					SELECT npi
					FROM dbo.MainSpecialist ms
					JOIN dbo.Link_MemberId_MVD_Ins mi
						ON ms.ICENUMBER = mi.MVDId
					WHERE tin = @tin
						AND RoleID = 1
						AND mi.Active = 1
						AND ms.NPI IS NOT NULL
				)
		BEGIN
			INSERT #NPIs
			SELECT DISTINCT(npi)
			FROM MainSpecialist ms
			JOIN dbo.Link_MemberId_MVD_Ins mi
				ON ms.ICENUMBER = mi.MVDId
			WHERE tin = @tin
				AND RoleID = 1
				AND mi.Active = 1
				AND ms.NPI IS NOT NULL
		
			DELETE Link_MDGroupNPI
			WHERE MDGroupID = @groupid
			
			INSERT Link_MDGroupNPI
			SELECT @groupid, npi
			FROM #NPIs
		END

		DELETE #tin
		WHERE tin = @tin

		DELETE #NPIs
	END

	-- ***** USERS *****

	--Add New TIN Users
	INSERT dbo.MDUser (Username, [Password], Active, CreationDate, ModifyDate, AccountName, ForcePasswordReset, Organization)
	SELECT GroupName, 'Vml0YWxEYXRhMTIz', 1, GETDATE(), GETDATE(), GroupName, 0, 'Driscoll SSO'
	FROM dbo.mdgroup
	WHERE CustID_Import = 11
		AND Active = 1
		AND GroupName NOT IN
			(
				SELECT username 
				FROM dbo.MDUser
			)

	CREATE TABLE #TempID ([aID] int ,[gID] int)

	INSERT #TempID
	SELECT DISTINCT a.ID, g.ID
	FROM mdgroup g
	JOIN MDUser a
		ON g.GroupName = a.username
	WHERE g.Active = 1
		AND g.CustID_Import = 11
	ORDER BY a.ID

	DELETE Link_MDAccountGroup
	WHERE MDGroupID IN
		(
			SELECT gid
			FROM #TempID
		)
		AND MDgroupid NOT IN (16797, 16799, 16800)

	INSERT Link_MDAccountGroup (MDAccountID, MDGroupID)
	SELECT [aID] ,[gID]
	FROM #TempID 
END