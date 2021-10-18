/****** Object:  Procedure [dbo].[AccessTickets_Create]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.AccessTickets_Create
@iceNum varchar(15)
AS
	DECLARE @ticket uniqueidentifier
	DECLARE @rowcount INT
	SET @rowcount = 1
	BEGIN TRANSACTION
		WHILE @rowcount > 0
		BEGIN
			SET @ticket = NewID()
			SELECT @rowcount = count(*)
			FROM AccessTickets
			WHERE TicketNumber = @ticket
		END
		INSERT AccessTickets(ICENUMBER, TicketNumber)
		VALUES (@iceNum, @ticket)
	COMMIT TRANSACTION
	SELECT @ticket 'Ticket'