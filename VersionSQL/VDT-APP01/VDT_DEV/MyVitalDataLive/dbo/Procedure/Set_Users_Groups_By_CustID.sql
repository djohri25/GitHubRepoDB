/****** Object:  Procedure [dbo].[Set_Users_Groups_By_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_Users_Groups_By_CustID]
(@Cust_ID	INT)
AS
BEGIN
	SET NOCOUNT ON

--DECLARE @Cust_ID	INT
--SET @CUST_ID = 10 
DECLARE @DateCreated Date
DECLARE @tin varchar(100), @groupid int



	IF OBJECT_ID('tempdb.dbo.#tin','U') is not null
	DROP TABLE #tin
	CREATE TABLE #tin (tin varchar(100))

	INSERT #tin
	SELECT DISTINCT(TIN)
	FROM dbo.MainSpecialist ms
	JOIN dbo.Link_MemberId_MVD_Ins mi
		ON ms.ICENUMBER = mi.MVDId
	WHERE mi.Cust_ID = @Cust_ID
		AND mi.Active = 1
		AND ms.TIN != '' AND ms.TIN IS NOT NULL
		AND ms.NPI != '' AND ms.NPI IS NOT NULL
		AND ms.roleid = 1
	UNION
	select distinct(pp.pseudo_TIN) from [VD-RPT01].[HPM_Import].[dbo].[Parklandprovider_PseudoTINS] pp 
	join dbo.MainSpecialist ms ON ms.tin = pp.pseudo_TIN--tin	
	join dbo.Link_MemberId_MVD_Ins mi
	on ms.ICENUMBER = mi.MVDId
	where 
	mi.Cust_ID = @Cust_ID
	and mi.Active = 1
	and ms.TIN != '' and ms.TIN is not null
	and ms.NPI != '' and ms.NPI is not null
	and ms.roleid = 1

	IF OBJECT_ID('tempdb.dbo.#NPIs','U') is not null
	DROP TABLE #NPIs
	CREATE TABLE #NPIs (npi varchar(100))

	IF (@CUST_ID = 10)
	BEGIN
		-- ***** GROUPS (TINS) *****

		--Add New Groups
		INSERT MDGroup (GroupName, Active, CreationDate, ModifyDate, IsNoteAlertGroup, CustID_Import)
		SELECT TIN, 1, GETDATE(), GETDATE(), 0, @Cust_ID
		FROM #tin
		WHERE TIN NOT IN
			(
				SELECT GroupName
				FROM dbo.MDGroup
				WHERE CustID_Import = @Cust_ID
			)

		--Update Secondary Names
		SELECT @DateCreated = (SELECT TOP 1 CONVERT(DATE, created) FROM [VD-RPT01].[HPM_Import].[dbo].[ParklandProvider] ORDER BY id DESC)
		UPDATE [dbo].[MDGroup]  
		SET SecondaryName = dp.business_name
		--Select md.* ,dp.business_name, dp.tin, dp.npi
		FROM [dbo].[MDGroup] md
		INNER JOIN [VD-RPT01].[HPM_Import].[dbo].[ParklandProvider] dp
			ON md.GroupName = dp.tin
		WHERE md.CustID_Import = @Cust_ID
			AND CONVERT(DATE, dp.Created) = @DateCreated
			and Groupname <> ''

		--Activate Inactive Groups
		UPDATE MDGroup
		SET Active = 1 
		WHERE GroupName IN
			(
				SELECT TIN
				FROM #tin
			)
			AND CustID_Import = @Cust_ID

		--DeActivate OLD Groups
		UPDATE MDGroup
		SET Active = 0 
		WHERE GroupName NOT IN
			(
				SELECT TIN
				FROM #tin
			)
			AND CustID_Import = @Cust_ID
			--AND (GroupName not like '%COPC%' or GroupName not like '%PP%' or GroupName not like '%MD%')


  		-- ***** NPIs *****
		WHILE EXISTS (SELECT * FROM #tin)
		BEGIN
			SELECT TOP 1 @tin = tin
			FROM #tin

			SELECT @groupid = [ID]
			FROM [dbo].[MDGroup]
			WHERE GroupName = @tin and Active = 1
		
			IF EXISTS (
						SELECT 1
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
		
				--DELETE Link_MDGroupNPI
				--WHERE MDGroupID = @groupid
			
				INSERT Link_MDGroupNPI
				SELECT @groupid, tn.npi
				FROM #NPIs tn LEFT JOIN Link_MDGroupNPI n on tn.npi = n.NPI and n.MDGroupID = @groupid
				Where n.npi is null
			END

			DELETE #tin
			WHERE tin = @tin

			DELETE #NPIs
		END
	END

	IF (@CUST_ID = 11)
	BEGIN
		-- ***** GROUPS (TINS) *****

		--Add New Groups
		INSERT MDGroup (GroupName, Active, CreationDate, ModifyDate, IsNoteAlertGroup, CustID_Import)
		SELECT TIN, 1, GETDATE(), GETDATE(), 0, @CUST_ID
		FROM #tin
		WHERE TIN NOT IN
			(
				SELECT GroupName
				FROM dbo.MDGroup
				WHERE CustID_Import = @CUST_ID
			)

		--Update Secondary Names
		
		SELECT @DateCreated = (SELECT TOP 1 CONVERT(DATE, created) FROM [VD-RPT01].[HPM_Import].[dbo].[DriscollProvider] ORDER BY id DESC)
		UPDATE [dbo].[MDGroup]  
		SET SecondaryName = dp.business_name
		FROM [dbo].[MDGroup] md
		INNER JOIN [VD-RPT01].[HPM_Import].[dbo].[DriscollProvider] dp
			ON md.GroupName = dp.tin
		WHERE md.CustID_Import = @CUST_ID
			AND CONVERT(DATE, dp.Created) = @DateCreated

		--Activate Inactive Groups
		UPDATE MDGroup
		SET Active = 1 
		WHERE GroupName IN
			(
				SELECT TIN
				FROM #tin
			)
			AND CustID_Import = @CUST_ID

		--DeActivate OLD Groups
		UPDATE MDGroup
		SET Active = 0 
		WHERE GroupName NOT IN
			(
				SELECT TIN
				FROM #tin
			)
			AND CustID_Import = @CUST_ID


  		-- ***** NPIs *****
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
		WHERE CustID_Import = @CUST_ID
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
			AND g.CustID_Import = @CUST_ID
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
END