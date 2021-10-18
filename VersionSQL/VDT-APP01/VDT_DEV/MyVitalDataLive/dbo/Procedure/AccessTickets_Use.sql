/****** Object:  Procedure [dbo].[AccessTickets_Use]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[AccessTickets_Use]
	@ticket uniqueidentifier,
	@minutesToExpire int = 10,
	@iceGrp varchar(15) OUTPUT,
	@iceNum varchar(15) OUTPUT,
	@result int OUTPUT
AS
	BEGIN TRAN
	
	DECLARE @dateCreated datetime
	DECLARE @dateUsed datetime
	SELECT @dateCreated = a.DateCreated, @dateUsed = a.DateUsed, @iceGrp = m.ICEGROUP, @iceNum = a.ICENUMBER
	FROM AccessTickets a JOIN MainICENUMBERGroups m ON
		a.ICENUMBER = m.ICENUMBER
	WHERE TicketNumber = @ticket

	IF @dateCreated is null
		SET @result = 1	-- Ticket not found
	ELSE IF @dateUsed is not null
		SET @result = 2	-- Ticket used already
	ELSE IF DATEDIFF(minute, @dateCreated, GETUTCDATE()) > ABS(@minutesToExpire)
		SET @result = 3	-- Ticket expired
	ELSE
		SET @result = 0	-- No errors
	
	IF @result > 0 OR @minutesToExpire < 0
		ROLLBACK TRAN
	ELSE
	BEGIN
		UPDATE AccessTickets
		SET DateUsed = GETUTCDATE()
		WHERE TicketNumber = @ticket
		COMMIT TRAN
	END