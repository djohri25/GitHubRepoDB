/****** Object:  Procedure [dbo].[Set_ActionTypes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Priya,Petluri>
-- Create date: <09/07/2016>
-- Description:	<Get all ActionTypes for specific Cust_id or ActionTypeD>
-- =============================================

CREATE PROCEDURE [dbo].[Set_ActionTypes]
@Cust_ID	INT,
@ActionTypeID	INT	= NULL	,
@ActionTypeDescription	VARCHAR(255),
@LOBID	INT,
@IsActive	BIT ,
@ReturnValue INT OUTPUT

AS
BEGIN
	SET NOCOUNT ON;
	/*
	Declare @LOBID	INT
	Select @LOBID = G.CodeID FROM Lookup_Generic_Code  G JOIN Lookup_Generic_Code_Type GT ON GT.CodeTypeID = G.CodeTypeID 
	WHERE Cust_ID = @Cust_ID and Label = @LOB and GT.CodeType = 'LOB'
	*/
	IF @ActionTypeID is NULL
	BEGIN
		IF NOT EXISTS (Select 1 From Lookup_HPActionType Where Cust_ID = @Cust_ID and LOBID = @LOBID and ActionTypeDescription = LTRIM(RTRIM(@ActionTypeDescription)))
		BEGIN
			INSERT INTO Lookup_HPActionType (ActionTypeDescription, Cust_ID, LOBID, IsActive, UpdatedDate)
			Select LTRIM(RTRIM(@ActionTypeDescription)), @Cust_ID, @LOBID, @IsActive, GETDATE()
		END
		SET @ReturnValue = SCOPE_IDENTITY();
		RETURN;
	END
	ELSE
	BEGIN
		UPDATE  Lookup_HPActionType
		SET ActionTypeDescription = LTRIM(RTRIM(@ActionTypeDescription)), LOBID = @LOBID, IsActive = @IsActive, UpdatedDate = GETDATE()
		WHERE Cust_ID = @Cust_ID and ActionTypeID = @ActionTypeID
	END
END