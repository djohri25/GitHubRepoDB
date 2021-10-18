/****** Object:  Procedure [dbo].[Set_Immunization]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_Immunization]

@ICENUMBER varchar(15),
@ImmunId int,
@DateDone datetime,
@DateDue datetime,
@DateApproximate bit

as

Set NoCount On
            
Insert Into MainImmunization (ICENUMBER, ImmunId, DateDone, DateDue, DateApproximate, CreationDate, ModifyDate)
Values (@ICENUMBER, @ImmunId, @DateDone, @DateDue, @DateApproximate, GETUTCDATE(), GETUTCDATE())