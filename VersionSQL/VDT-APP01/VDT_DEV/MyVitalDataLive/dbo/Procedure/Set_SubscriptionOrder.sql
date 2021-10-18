/****** Object:  Procedure [dbo].[Set_SubscriptionOrder]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_SubscriptionOrder]
@SubscriptionType VARCHAR (50), @Email VARCHAR (50), @FirstNameOnCard VARCHAR (50), @LastNameOnCard VARCHAR (50), @CardType VARCHAR (50), @CardNumber VARCHAR (50), @CardVerificationCode VARCHAR (10), @CardExpirationMonth INT, @CardExpirationYear INT, @BillingAddress1 VARCHAR (50), @BillingAddress2 VARCHAR (50), @BillingCity VARCHAR (100), @BillingState VARCHAR (100), @BillingZip VARCHAR (10), @TransactionID VARCHAR (50) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	declare @newTransactionID uniqueidentifier,
		@additionalProfileCount int,
		@subscriptionYears int
	set @newTransactionID = newID()

	select @additionalProfileCount = additionalProfileCount,
		@subscriptionYears = DurationValue
	from MVD_SubscriptionType where ID = @SubscriptionType

	INSERT INTO MVD_SubscriptionOrder
           ([TransactionID]
           ,[SubscriptionType]
		   ,Email
           ,[FirstNameOnCard]
           ,[LastNameOnCard]
           ,[CardType]
           ,[CardNumber]
           ,[CardVerificationCode]
           ,[CardExpirationMonth]
           ,[CardExpirationYear]
           ,[BillingAddress1]
           ,[BillingAddress2]
           ,[BillingCity]
           ,[BillingState]
           ,[BillingZip])
     VALUES
           (@newTransactionID
           ,@SubscriptionType
		   ,@Email
           ,@FirstNameOnCard
           ,@LastNameOnCard
           ,@CardType
           ,@CardNumber
           ,@CardVerificationCode
           ,@CardExpirationMonth
           ,@CardExpirationYear
           ,@BillingAddress1
           ,@BillingAddress2
           ,@BillingCity
           ,@BillingState
           ,@BillingZip)

	EXEC IncreaseAccountActivation 
		@Email = @Email,
		@Accounts = 1,
		@Profiles = @additionalProfileCount,
		@Years = @subscriptionYears,
		@OrderTransactionID = @newTransactionID

	if exists ( select id from mvd_SubscriptionOrder where transactionID = @newTransactionID)
	begin
		set @TransactionID = @newTransactionID
	end
	else
	begin
		set @TransactionID = 0
	end
END