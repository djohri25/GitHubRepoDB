/****** Object:  Procedure [dbo].[setPDFLabeltextCHF]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[setPDFLabeltextCHF]
@Id int
as


select suddenweightgain as condition from formPatientEducationCHF where suddenweightgain != '' and id = @Id
union
select swollenabdomenankle as condition from formPatientEducationCHF where swollenabdomenankle != '' and id = @Id
union
select worsenshortnessofbreath as condition from formPatientEducationCHF where worsenshortnessofbreath != '' and id = @Id
union
select notsleepingComfortableflat as condition from formPatientEducationCHF where notsleepingComfortableflat != '' and id = @Id
union 
SELECT worseningcough AS condition from formPatientEducationCHF where worseningcough != '' and id = @Id
UNION 
SELECT persistentonsetnauseavomiting AS condition from formPatientEducationCHF where persistentonsetnauseavomiting != '' and id = @Id
 UNION
 SELECT worseningdizziness AS condition from formPatientEducationCHF where worseningdizziness != '' and id = @Id
 UNION
 SELECT NewOnsetFatigue AS condition from formPatientEducationCHF where NewOnsetFatigue != '' and id = @Id