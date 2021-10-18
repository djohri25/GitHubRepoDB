/****** Object:  Procedure [dbo].[Get_SubscriptionByTxID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SubscriptionByTxID]
@TransactionID VARCHAR (50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @isAccountCreated bit

	if exists( select a.PrimaryKey from AccountActivation a
		inner join MainUserName u on a.Email = u.BillingEmail
		where a.OrderTransactionID = @TransactionID)
	begin
		set @isAccountCreated = 1
	end
	else
	begin
		set @isAccountCreated = 0
	end
	
	SELECT [TransactionID]
	  ,[SubscriptionType]
	  ,[Email]
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
	  ,[BillingZip]
	  ,[ProcessedDate]
	  ,@isAccountCreated as isAccountCreated
  FROM [MVD_SubscriptionOrder]
  where transactionID = @TransactionID	 
END