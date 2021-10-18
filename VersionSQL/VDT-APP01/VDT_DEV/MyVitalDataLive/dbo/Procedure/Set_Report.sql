/****** Object:  Procedure [dbo].[Set_Report]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_Report]
	@reportDescription varchar(1000),
	@reportRecipient varchar(2000),			-- multiple emails are separated with ";"
	@reportName varchar(50),
	@reportSubject varchar(100),
	@reportDate varchar(50),
	@reportContent varbinary(max)
AS
BEGIN
	SET NOCOUNT ON;

--	select @reportRecipient = 'swyrzykowski@vitaldatatech.com;w_sylwek@yahoo.com',
--		@reportName = 'Test report',
--		@reportSubject = 'This is report subject',
--		@reportDate = '3/12/2009'

	declare @email varchar(50), @userid uniqueidentifier, @reportRefID int
	declare @recipient table (email varchar(50), isProcessed bit default(0))
	declare @temp table(data varchar(50))
	declare @query varchar(1000)

	if( @reportContent is not null AND len(isnull(@reportRecipient,'')) > 0)
	begin
		BEGIN TRY
			-- Create report record
			insert into SubscriptionReport(name, subject,reportdate,content)
			values(@reportName, @reportSubject,@reportDate,@reportContent)

			set @reportRefID = scope_identity()

			insert into @recipient(email)
			select data from dbo.Split(@reportRecipient,';')

			while exists (select email from @recipient where isProcessed = 0)
			begin
				select top 1 @email = email from @recipient where isProcessed = 0

				set @query = 'select userId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Membership where email = ''' + @email + ''''

				insert into @temp
				exec(@query)

				-- Associate user with the report
				if exists(select data from @temp)
				begin
					select @userid = data from @temp

					insert into Link_ReportUser(reportid,userid,viewed)
					values(@reportRefID,@userid,0)

					EXEC SendMailOnNewSubscriptionReport
						@email = @email,
						@reportName = @reportName,
						@reportDate = @reportDate

					EXEC Del_OldReports @userID = @userid
				end

				delete from @temp
				delete from @recipient where email = @email
			end
		END TRY
		BEGIN CATCH			
			INSERT INTO SubscriptionReportError (Message) 
			VALUES (ERROR_MESSAGE())
		END CATCH
	end
END