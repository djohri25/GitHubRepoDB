/****** Object:  Procedure [dbo].[Set_OrderDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/7/2010
-- Description:	Store transaction info entered by user on 3rd party 
--	transaction processing site (currently paypal) and activate the account (create record with number of available profiles)
--
-- =============================================
create PROCEDURE [dbo].[Set_OrderDetails]
	@TransactionID varchar(50),
	@Email varchar(50),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(100),
	@State varchar(100),
	@Zip varchar(10),
	@GrossAmount money,
	@FeeAmount money,
	@SubscriptionName varchar(50),
	@SubscriptionLength int,
	@NewAccountURL varchar(1000),
	@Result int out			-- 0 - success, -1 - error, -2 - user already created an account
AS
BEGIN
	SET NOCOUNT ON;

	set @Result = -1

	if not exists(select transactionID from MVD_SubscriptionOrder where TransactionID = @TransactionID)
	begin
		INSERT INTO dbo.MVD_SubscriptionOrder
			   ([TransactionID]
			   ,Email
			   ,[FirstNameOnCard]
			   ,[LastNameOnCard]
			   ,[BillingAddress1]
			   ,[BillingAddress2]
			   ,[BillingCity]
			   ,[BillingState]
			   ,[BillingZip]
			   ,GrossAmount
			   ,FeeAmount
			   ,SubscriptionName
			   ,SubscriptionLength
			   ,NewAccountURL)
		 VALUES
			   (@TransactionID 				
			   ,@Email
			   ,@FirstName
			   ,@LastName
			   ,@Address1
			   ,@Address2
			   ,@City
			   ,@State
			   ,@Zip
			   ,@GrossAmount
			   ,@FeeAmount
			   ,@SubscriptionName
			   ,@SubscriptionLength
			   ,@NewAccountURL)
	end
	
	if not exists (select OrderTransactionID from AccountActivation where OrderTransactionID = @TransactionID)
	begin
	
		declare @AdditionalProfileCount int
		
		if(@SubscriptionName like '%individual%')
		begin
			select top 1 @AdditionalProfileCount = AdditionalProfileCount from MVD_SubscriptionType where Name like '%individual%'
		end
		else if(@SubscriptionName like '%couple%')
		begin
			select top 1 @AdditionalProfileCount = AdditionalProfileCount from MVD_SubscriptionType where Name like '%couple%'
		end
		else if(@SubscriptionName like '%family%')
		begin
			select top 1 @AdditionalProfileCount = AdditionalProfileCount from MVD_SubscriptionType where Name like '%family%'
		end			
	
		EXEC IncreaseAccountActivation 
			@Email = @Email,
			@Accounts = 1,
			@Profiles = @AdditionalProfileCount,
			@Years = @SubscriptionLength,
			@OrderTransactionID = @TransactionID
			
		set @Result = 0
	end
	
	
	-- Check if user already created an account
	if exists(select PrimaryKey from AccountActivation 
			where Email = @Email and [TYPE] = 'A' and Delta = -1 )	
	begin
		set @Result = -2
	end
END