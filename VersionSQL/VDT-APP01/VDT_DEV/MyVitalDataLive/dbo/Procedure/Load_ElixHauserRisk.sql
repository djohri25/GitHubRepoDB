/****** Object:  Procedure [dbo].[Load_ElixHauserRisk]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Load_ElixHauserRisk]
(@Cust_id int )
AS
BEGIN
	--Declare @Cust_ID int
	Declare @StartDate	date, @EndDate	Date, @MonthID_Single varchar(6)

	Drop table If exists #Temp_Elix
	Create Table #Temp_Elix
	(
	ID	Int Identity(1,1) NOT NULL,
	Elix_Score	INT, 
	MVDID	Varchar(30),
	MONTHID		Varchar(6),
	ELX_GRP_1	bit,
	ELX_GRP_2	bit,
	ELX_GRP_3	bit,
	ELX_GRP_4	bit,
	ELX_GRP_5	bit,
	ELX_GRP_6	bit,
	ELX_GRP_7	bit,
	ELX_GRP_8	bit,
	ELX_GRP_9	bit,
	ELX_GRP_10	bit,
	ELX_GRP_11	bit,
	ELX_GRP_12	bit,
	ELX_GRP_13	bit,
	ELX_GRP_14	bit,
	ELX_GRP_15	bit,
	ELX_GRP_16	bit,
	ELX_GRP_17	bit,
	ELX_GRP_18	bit,
	ELX_GRP_19	bit,
	ELX_GRP_20	bit,
	ELX_GRP_21	bit,
	ELX_GRP_22	bit,
	ELX_GRP_23	bit,
	ELX_GRP_24	bit,
	ELX_GRP_25	bit,
	ELX_GRP_26	bit,
	ELX_GRP_27	bit,
	ELX_GRP_28	bit,
	ELX_GRP_29	bit,
	ELX_GRP_30	bit,
	ELX_GRP_31	bit
	)

	DECLARE @v_same_day_month_offset datetime = DATEADD( MONTH, -1, GetDate() );
	DECLARE @v_first_day_month_offset datetime =
		DATEFROMPARTS( YEAR( @v_same_day_month_offset ), MONTH( @v_same_day_month_offset ), 1 );

	Declare @MonthID Table 
	( ID int IDENTITY(1,1), 
	  MonthID	varchar(6)
	 ) 
	INSERT INTO @MonthID (MonthID)
		Select DISTINCT REPLACE(LEFT(CONVERT(Date, H.StatementThroughDate,120),7),'-','') as MonthID from [dbo].[FinalClaimsHeaderCode] C JOIN [dbo].[FinalClaimsHeader] H on H.ClaimNumber = C.ClaimNumber and H.CurrentBatchID = C.CurrentBatchID
		Where C.CUstId = @Cust_id and CONVERT(Date, H.StatementThroughDate,120) >= @v_first_day_month_offset
		ORDER BY REPLACE(LEFT(CONVERT(Date, H.StatementThroughDate,120),7), '-','')

	While Exists (Select 1 from @MonthID)
	BEGIN				

	Select 	@MonthID_Single = MonthID from @MonthID ORDER BY ID desc
	--SELECT   @MonthID_Single

	set @StartDate = null
	Set @EndDate = null
	Select @StartDate = @MonthID_Single+'01'
			Select @EndDate = Case When RIGHT(CAST(@MonthID_Single as varchar(6)),2) = '02' and ISDATE(CAST(@MonthID_Single AS char(6)) + '29') = 0 then @MonthID_Single+'28'
								   When RIGHT(CAST(@MonthID_Single as varchar(6)),2) = '02' and ISDATE(CAST(@MonthID_Single AS char(6)) + '29') = 1 then @MonthID_Single+'29'	
								   When ISDATE(CAST(@MonthID_Single AS char(6)) + '31') = 1 then @MonthID_Single+'31'	
								   Else @MonthID_Single+'30' END 
	--Select @StartDate as '@StartDate', @EndDate, '@EndDate'

	Truncate table #Temp_Elix
	INSERT INTO #Temp_Elix(Elix_Score, MVDID, MONTHID, ELX_GRP_1, ELX_GRP_2,ELX_GRP_3 ,ELX_GRP_4 ,ELX_GRP_5 ,ELX_GRP_6 ,ELX_GRP_7 ,ELX_GRP_8 ,ELX_GRP_9 ,ELX_GRP_10 ,
							ELX_GRP_11 ,ELX_GRP_12 ,ELX_GRP_13 ,ELX_GRP_14 ,ELX_GRP_15 ,ELX_GRP_16 ,ELX_GRP_17 ,ELX_GRP_18 ,ELX_GRP_19 ,ELX_GRP_20 ,
							ELX_GRP_21 ,ELX_GRP_22 ,ELX_GRP_23 ,ELX_GRP_24 ,ELX_GRP_25 ,ELX_GRP_26 ,ELX_GRP_27 ,ELX_GRP_28 ,ELX_GRP_29 ,ELX_GRP_30 ,ELX_GRP_31)

	select ELX_GRP_1 +ELX_GRP_2 +ELX_GRP_3 +ELX_GRP_4 +ELX_GRP_5 +ELX_GRP_6 +ELX_GRP_7 +ELX_GRP_8 +ELX_GRP_9 +ELX_GRP_10 +
			ELX_GRP_11 +ELX_GRP_12 +ELX_GRP_13 +ELX_GRP_14 +ELX_GRP_15 +ELX_GRP_16 +ELX_GRP_17 +ELX_GRP_18 +ELX_GRP_19 +ELX_GRP_20 +
			ELX_GRP_21 +ELX_GRP_22 +ELX_GRP_23 +ELX_GRP_24 +ELX_GRP_25 +ELX_GRP_26 +ELX_GRP_27 +ELX_GRP_28 +ELX_GRP_29 +ELX_GRP_30 +ELX_GRP_31 as Elix_Score
	,MVDID,
	@MonthID_Single,
	ELX_GRP_1 ,ELX_GRP_2 ,ELX_GRP_3 ,ELX_GRP_4 ,ELX_GRP_5 ,ELX_GRP_6 ,ELX_GRP_7 ,ELX_GRP_8 ,ELX_GRP_9 ,ELX_GRP_10 ,
	ELX_GRP_11 ,ELX_GRP_12 ,ELX_GRP_13 ,ELX_GRP_14 ,ELX_GRP_15 ,ELX_GRP_16 ,ELX_GRP_17 ,ELX_GRP_18 ,ELX_GRP_19 ,ELX_GRP_20 ,
	ELX_GRP_21 ,ELX_GRP_22 ,ELX_GRP_23 ,ELX_GRP_24 ,ELX_GRP_25 ,ELX_GRP_26 ,ELX_GRP_27 ,ELX_GRP_28 ,ELX_GRP_29 ,ELX_GRP_30 ,ELX_GRP_31
	from (
	SELECT C.MVDID, 
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493')
				or CodeValue between '4254' and '4259999'
				or CodeValue like '428%'
			)
			)
			or
			(ICDVersion = '0'
			 and ( CodeValue in ('I099','I110','I130','I132','I255','I420','P290') 
				or CodeValue between 'I425' and 'I429999' 
				or CodeValue like 'I43%'
				or CodeValue like 'I50%' 
				)
			) then 1 else 0 end) as [ELX_GRP_1], -- Congestive Heart Failure
		max(case when
			(ICDVersion = '9'
			 and ( CodeValue in ('4260','42613','4267','4269','42610','42612','7850','99601','99604','V450','V533') 
				or CodeValue between '4270' and '4274'
				or CodeValue between '4276' and '4279' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and ( CodeValue in ('I456','I459','ROO0','ROO1','ROO8','T821','Z450','Z950')
				or CodeValue between 'I441' and 'I443'
				or CodeValue between 'I47' and 'I49999' 
				)
			) then 1 else 0 end) as [ELX_GRP_2], -- Cardiac Arrhythmia
		max(case when
			(ICDVersion = '9'
			 and ( CodeValue in ('0932','V422','V433')
				or CodeValue between '394' and '3979999'
				or CodeValue like '424%' 
				or CodeValue between '7463' and '7466' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('A520','I091','I098','Z952','Z954') 
				or CodeValue between 'I34' and 'I399999'
				or CodeValue between 'I05' and 'I089999'
				or CodeValue between 'Q23O' and 'Q233' 
				)
			) then 1 else 0 end) as [ELX_GRP_3], -- Valvular Disease

		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('4150','4151','4170','4178','4179') 
				or CodeValue like '416%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('I280','I288','I289') 
				or CodeValue like 'I26%'
				or CodeValue like 'I27%'  
				)
			) then 1 else 0 end) as [ELX_GRP_4], -- Pulmonary Circulation Disorders
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('0930','4373','4471','5571','5579','V434')
				or CodeValue between '440' and '4419999' 
				or CodeValue between '4431' and '4439'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('I731','I738','I739','I771','I790','I792','K551','K558','K559','Z958','Z959') 
				or CodeValue like 'I70%'
				or CodeValue like 'I71%' 
				)
			) then 1 else 0 end) as [ELX_GRP_5], -- Peripheral Vascular Disorders
		max(case when
			(ICDVersion = '9'
			 and (CodeValue like '401%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue like 'I10%'
				)
			) then 1 else 0 end) as [ELX_GRP_6], -- Hypertension Uncomplicated
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '402' and '4059999' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'I11' and 'I139999'
				or CodeValue like 'I15%' 
				)
			) then 1 else 0 end) as [ELX_GRP_7], -- Hypertension Complicated
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('3341','3449') 
				or CodeValue like '342%'
				or CodeValue like '343%'
				or CodeValue between '3440' and '3446' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('G041','G114','G801','G802','G839') 
				or CodeValue like 'G81%'
				or CodeValue like 'G82%'
				or CodeValue between 'G830' and 'G834' 
				)
			) then 1 else 0 end) as [ELX_GRP_8], -- Paralysis
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('3319','3320','3321','3334','3335','33392','3362','3481','3483','7803','7843') 
				or CodeValue like '340%'
				or CodeValue like '341%'
				or CodeValue like '345%'
				or CodeValue between '334' and '3359999'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('G254','G255','G312','G318','G319','G931','G934','R470') 
				or CodeValue like 'R56%' 
				or CodeValue like 'G32%'  
				or CodeValue between 'G35' and 'G379999' 
				or CodeValue like 'G40%'  
				or CodeValue like 'G41%'  
				or CodeValue between 'G10' and 'G139999'  
				or CodeValue between 'G20' and 'G229999'  
				)
			) then 1 else 0 end) as [ELX_GRP_9], -- Other Neurological Disorders
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('4168','4169','5064','5081','5088')
				or CodeValue between '490' and '5059999' 
  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('I278','1279','J684','J701','J703') 
				or CodeValue between 'J40' and 'J479999'
				or CodeValue between 'J60' and 'J679999'
				)
			) then 1 else 0 end) as [ELX_GRP_10], -- Chronic Pulmonary Disease
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '2500' and '2503'
				or CodeValue = '6480' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('E100','E101','E109','E110','E111','E119','E120','E121','E129','E130','E131','E139','E140','E141','E149') 
				)
			) then 1 else 0 end) as [ELX_GRP_11], -- Diabetes Uncomplicated
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '2504' and '2509'
				or CodeValue = '7751' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'E102' and 'E108'
				or CodeValue between 'E112' and 'E118'
				or CodeValue between 'E122' and 'E128'
				or CodeValue between 'E132' and 'E138'
				or CodeValue between 'E142' and 'E148' 
				)
			) then 1 else 0 end) as [ELX_GRP_12], -- Diabetes Complicated
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('2409','2468','2461')
				or CodeValue like '243%'
				or CodeValue like '244%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'E00' and 'E039999'
				or CodeValue = 'E890' 
				)
			) then 1 else 0 end) as [ELX_GRP_13], -- Hypothyroidism
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('40301','40311','40391','40402','40403','40412','40413','40492','40493','5880','V420','V451')
				or CodeValue like '585%'
				or CodeValue like '586%'
				or CodeValue like 'V56%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('I120','I131','N250','Z940','Z1992') 
				or CodeValue like 'N18%'
				or CodeValue like 'NI9%'
				or CodeValue between 'Z490' and 'Z492' 
				)
			) then 1 else 0 end) as [ELX_GRP_14], -- Renal Failure
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('07022','07023','07032','07033','07044','07054','0706','0709','5733','5734','5738','5739','V427') 
				or CodeValue between '4560' and '4562' 
				or CodeValue like '570%'
				or CodeValue like '571%'
				or CodeValue between '5722' and '5728' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('I864','I982','Z944','K711','K717','K760')
				or CodeValue like 'B18%'
				or CodeValue like 'I85%'
				or CodeValue like 'K70%'
				or CodeValue between 'K713' and 'K715'
				or CodeValue between 'K72' and 'K749999'
				or CodeValue between 'K762' and 'K769'
				)
			) then 1 else 0 end) as [ELX_GRP_15], -- Liver Disease
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('5317','5319','5327','5329','5337','5339','5347','5349')  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('K257','K259','K267','K269','K277','K279','K287','K289') 
				)
			) then 1 else 0 end) as [ELX_GRP_16], -- Peptic Ulcer Disease excluding bleeding
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '042' and '0449999'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'B20' and 'B229999'
				or CodeValue like 'B24%'
				)
			) then 1 else 0 end) as [ELX_GRP_17], -- AIDS/HIV
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('2030', '2386')  
				or CodeValue between '200' and '2029999'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'C81' and 'C859999'
				or CodeValue like 'C88%'
				or CodeValue like 'C96%'
				or CodeValue in ('C900','C902') 
				)
			) then 1 else 0 end) as [ELX_GRP_18], -- Lymphoma
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '196' and '1999999'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'C77' and 'C809999'
				)
			) then 1 else 0 end) as [ELX_GRP_19], -- Metastatic Cancer
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '140' and '1729999' 
				or CodeValue between '174' and '1959999'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'C00' and 'C269999'
				or CodeValue between 'C30' and 'C349999'
				or CodeValue between 'C37' and 'C419999'
				or CodeValue like 'C43%'
				or CodeValue between 'C45' and  'C589999'
				or CodeValue between 'C60' and 'C769999'
				or CodeValue like 'C97%'
				)
			) then 1 else 0 end) as [ELX_GRP_20], -- Solid Tumor without Metastasis
		max(case when
			(ICDVersion = '9'
			 and (CodeValue like '446%'
				or CodeValue in ('7010','7108','7109','7112','7285','72889','72930','7193')  
				or CodeValue between '7100' and '7104' 
				or CodeValue like '714%'
				or CodeValue like '720%'
				or CodeValue like '725%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('L940','L941','L943','M461','M468','M469','M120','M123')  
				or CodeValue like 'M05%'
				or CodeValue like 'M06%'
				or CodeValue like 'M08%'
				or CodeValue like 'M30%'
				or CodeValue between 'M310' and 'M3139999' 
				or CodeValue between 'M32' and 'M359999'
				or CodeValue like 'M45%'
				)
			) then 1 else 0 end) as [ELX_GRP_21], -- Rheumatoid Arthritis/collagen
		max(case when
			(ICDVersion = '9'
			 and (CodeValue like '286%'
				or CodeValue = '2871'
				or CodeValue between '2873' and '2875'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'D65' and 'D689999'
				or CodeValue = 'D691' 
				or CodeValue between 'D693' and 'D696'
				)
			) then 1 else 0 end) as [ELX_GRP_22], -- Coagulopathy
		max(case when
			(ICDVersion = '9'
			 and (CodeValue = '2780' 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue like 'E66%'
				)
			) then 1 else 0 end) as [ELX_GRP_23], -- Obesity
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '260' and '2639999'
				or CodeValue in ('7832','7994') 
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'E40' and 'E469999'
				or CodeValue in ('R634','R64') 
				)
			) then 1 else 0 end) as [ELX_GRP_24], -- Weight Loss
		max(case when
			(ICDVersion = '9'
			 and (CodeValue = '2536'
				or CodeValue like '276%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue = 'E222'
				or CodeValue like 'E86%'
				or CodeValue like 'E87%'
				)
			) then 1 else 0 end) as [ELX_GRP_25], -- Fluid and Electrolyte Disorders
		max(case when
			(ICDVersion = '9'
			 and (CodeValue = '2800'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue = 'D500'
				)
			) then 1 else 0 end) as [ELX_GRP_26], -- Blood Loss Anemia
		max(case when
			(ICDVersion = '9'
			 and (CodeValue between '2801' and '2809'
				or CodeValue like '281%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('D508', 'D509')
				or CodeValue between 'D51' and 'D539999'
				)
			) then 1 else 0 end) as [ELX_GRP_27], -- Deficiency Anemia
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('2652','3030','3039','3050','3575','4255','5353','V113') 
				or CodeValue between '2911' and '2913'  
				or CodeValue between '2915' and '2919' 
				or CodeValue between '5710' and '5713' 
				or CodeValue like '980%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('F10','E52','G621','I426','K292','K700','K703','K709','Z502','Z714','Z721') 
				or CodeValue like 'T51%'
				)
			) then 1 else 0 end) as [ELX_GRP_28], -- Alcohol Abuse
		max(case when
			(ICDVersion = '9'
			 and (CodeValue like '292%'
				or CodeValue like '304%'
				or CodeValue between '3052' and '3059'  
				or CodeValue = 'V6542'  
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue between 'F11' and 'F169999'
				or CodeValue like 'F18%'
				or CodeValue like 'F19%'
				or CodeValue in ('Z715','Z722')
				)
			) then 1 else 0 end) as [ELX_GRP_29], -- Drug Abuse
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('2938','29604','29614','29644','29654') 
				or CodeValue like '297%'
				or CodeValue like '295%'
				or CodeValue like '298%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue like 'F20%'
				or CodeValue between 'F22' and 'F259999'
				or CodeValue like 'F28%'
				or CodeValue like 'F29%'
				or CodeValue in ('F302','F312','F315') 
				)
			) then 1 else 0 end) as [ELX_GRP_30], -- Psychoses
		max(case when
			(ICDVersion = '9'
			 and (CodeValue in ('2962','2963','2965','3004','311')  
				or CodeValue like '309%'
 			 )
			)
			or
			(ICDVersion = '0'
			 and (CodeValue in ('F204','F341','F412','F432') 
				or CodeValue between 'F313' and 'F315' 
				or CodeValue like 'F32%'
				or CodeValue like 'F33%'
				)
			) then 1 else 0 end) as [ELX_GRP_31] -- Depression
	  FROM [dbo].[FinalClaimsHeaderCode] C JOIN [dbo].[FinalClaimsHeader] H on H.ClaimNumber = C.ClaimNumber and H.CurrentBatchID = C.CurrentBatchID
	  Where C.CustId = @Cust_id and CONVERT(Date,H.StatementThroughDate, 120) between CONVERT(Date, @StartDate, 120) and CONVERT(Date, @EndDate, 120)
	  group by C.MVDID ) a
	  order by MVDID
	
	Delete from ElixMemberRisk Where MVDID in (Select MVDID from #Temp_Elix) and MonthID = @MonthID_Single 
	INSERT INTO ElixMemberRisk ([MVDID], MonthID, [Elixhauser_Score], GroupID)
	  SELECT distinct 
			MVDID,
			MonthID,
			Elix_Score,
			Elix_Group as GroupID
	--Select * 
	FROM
	  (SELECT	MVDID, MONTHID, Elix_SCore,
				ELX_GRP_1, ELX_GRP_2, ELX_GRP_3, ELX_GRP_4, ELX_GRP_5, ELX_GRP_6, ELX_GRP_7, ELX_GRP_8, ELX_GRP_9, ELX_GRP_10, 
				ELX_GRP_11, ELX_GRP_12, ELX_GRP_13, ELX_GRP_14, ELX_GRP_15, ELX_GRP_16, ELX_GRP_17, ELX_GRP_18, ELX_GRP_19, ELX_GRP_20, 
				ELX_GRP_21, ELX_GRP_22, ELX_GRP_23, ELX_GRP_24, ELX_GRP_25, ELX_GRP_26, ELX_GRP_27, ELX_GRP_28, ELX_GRP_29, ELX_GRP_30, ELX_GRP_31
	   FROM #Temp_Elix --where MonthID = '201401' and MVDID = '16AA240103'--'16AA239077'--'16AA240103'
	   ) D  
	UNPIVOT 
	(
	  Elix_Group FOR GroupID IN (ELX_GRP_1, ELX_GRP_2, ELX_GRP_3, ELX_GRP_4, ELX_GRP_5, ELX_GRP_6, ELX_GRP_7, ELX_GRP_8, ELX_GRP_9, ELX_GRP_10, 
				ELX_GRP_11, ELX_GRP_12, ELX_GRP_13, ELX_GRP_14, ELX_GRP_15, ELX_GRP_16, ELX_GRP_17, ELX_GRP_18, ELX_GRP_19, ELX_GRP_20, 
				ELX_GRP_21, ELX_GRP_22, ELX_GRP_23, ELX_GRP_24, ELX_GRP_25, ELX_GRP_26, ELX_GRP_27, ELX_GRP_28, ELX_GRP_29, ELX_GRP_30, ELX_GRP_31)
 
	) AS upvt
	Where upvt.Elix_Score = 0 --and upvt.Elix_Group <> 0

	UNION

	SELECT distinct 
			MVDID,
			MonthID,
			Elix_Score
			--, Elix_Group
			, CASE GroupID WHEN 'ELX_GRP_1' then 1 
						   WHEN 'ELX_GRP_2' then 2
						   WHEN 'ELX_GRP_3' then 3
						   WHEN 'ELX_GRP_4' then 4
						   WHEN 'ELX_GRP_5' then 5
						   WHEN 'ELX_GRP_6' then 6
						   WHEN 'ELX_GRP_7' then 7
						   WHEN 'ELX_GRP_8' then 8
						   WHEN 'ELX_GRP_9' then 9
						   WHEN 'ELX_GRP_10' then 10
						   WHEN 'ELX_GRP_11' then 11
						   WHEN 'ELX_GRP_12' then 12
						   WHEN 'ELX_GRP_13' then 13
						   WHEN 'ELX_GRP_14' then 14
						   WHEN 'ELX_GRP_15' then 15
						   WHEN 'ELX_GRP_16' then 16
						   WHEN 'ELX_GRP_17' then 17
						   WHEN 'ELX_GRP_18' then 18
						   WHEN 'ELX_GRP_19' then 19
						   WHEN 'ELX_GRP_20' then 20
						   WHEN 'ELX_GRP_21' then 21
						   WHEN 'ELX_GRP_22' then 22
						   WHEN 'ELX_GRP_23' then 23
						   WHEN 'ELX_GRP_24' then 24
						   WHEN 'ELX_GRP_25' then 25
						   WHEN 'ELX_GRP_26' then 26 
						   WHEN 'ELX_GRP_27' then 27 
						   WHEN 'ELX_GRP_28' then 28 
						   WHEN 'ELX_GRP_29' then 29 
						   WHEN 'ELX_GRP_30' then 30 
						   WHEN 'ELX_GRP_31' then 31 ELSE 0 END as GroupID
	--Select * 
	FROM
	  (SELECT	MVDID, MONTHID, Elix_SCore,
				ELX_GRP_1, ELX_GRP_2, ELX_GRP_3, ELX_GRP_4, ELX_GRP_5, ELX_GRP_6, ELX_GRP_7, ELX_GRP_8, ELX_GRP_9, ELX_GRP_10, 
				ELX_GRP_11, ELX_GRP_12, ELX_GRP_13, ELX_GRP_14, ELX_GRP_15, ELX_GRP_16, ELX_GRP_17, ELX_GRP_18, ELX_GRP_19, ELX_GRP_20, 
				ELX_GRP_21, ELX_GRP_22, ELX_GRP_23, ELX_GRP_24, ELX_GRP_25, ELX_GRP_26, ELX_GRP_27, ELX_GRP_28, ELX_GRP_29, ELX_GRP_30, ELX_GRP_31
	   FROM #Temp_Elix --where MonthID = '201409' and MVDID = '16DB961127'--'16AA239077'--'16AA240103'
	   ) D  
	UNPIVOT 
	(
	  Elix_Group FOR GroupID IN (ELX_GRP_1, ELX_GRP_2, ELX_GRP_3, ELX_GRP_4, ELX_GRP_5, ELX_GRP_6, ELX_GRP_7, ELX_GRP_8, ELX_GRP_9, ELX_GRP_10, 
				ELX_GRP_11, ELX_GRP_12, ELX_GRP_13, ELX_GRP_14, ELX_GRP_15, ELX_GRP_16, ELX_GRP_17, ELX_GRP_18, ELX_GRP_19, ELX_GRP_20, 
				ELX_GRP_21, ELX_GRP_22, ELX_GRP_23, ELX_GRP_24, ELX_GRP_25, ELX_GRP_26, ELX_GRP_27, ELX_GRP_28, ELX_GRP_29, ELX_GRP_30, ELX_GRP_31)
 
	) AS upvt
	Where upvt.Elix_Score <> 0 and upvt.Elix_Group <> 0
	ORDER BY MVDID, MONTHID

	Delete from @MonthID where MonthID = @MonthID_Single
	END
	
END