
*---------------------------------------------------------------------
*	Goal:			Prepare for xxxxx Data

*	Input Data:		_raw   e.g 1) doctor_raw.dta;
					
*	Output Data:	_clean e.g 1) SP_YN_Doc_Clean.do
										
* 	Author(s):      Paiou Wu  paiou_wu@163.com 18813106761
*	Created: 		2017-08-18
* 	Last Modified: 	2017-08-25 XH(检查人姓名)
*---------------------------------------------------------------------


/*-----------------------------------------------------------
 Note: primary steps of this do file
 
	Step 1: Bring in data
		Step 1.1: add label
		Step 1.2: gen clean copy var		
	Step 2: Rename
	Step 3: Clean variables
	    Step 3.1:A section 医生基本信息
        Step 3.2:B section 接诊情况
        Step 3.3:C section 常见病症治疗情况
        Step 3.4:D section 考核情况  
        Step 3.5:E section 收入
        Step 3.6:F section 考核情况
	
-----------------------------------------------------------*/

clear all
set more off
capture log close

/*set directories - XH*/  
global rawdatadir	"/Users/xuehao/Dropbox (REAP)/SP Baseline data Clean/Clean of doctor data/Raw_Data"
global cleandatadir "/Users/xuehao/Dropbox (REAP)/SP Baseline data Clean/Clean of doctor data/Clean_Data"
global outdatadir "/Users/xuehao/Dropbox (REAP)/SP Baseline data Clean/Merge all data/Raw_Data"

/*
/*set directories - paiou*/  
global rawdatadir "C:/Users/pku/dropbox/SP Baseline data Clean/Clean of doctor data/Raw_Data"
global cleandatadir "C:\Users\pku\Dropbox\SP Baseline data Clean\Clean of doctor data\Clean_Data"
*/
/*-------
Step 1: Bring in data
--------*/ 

use "$rawdatadir/doctor_raw.dta",clear

/* or：
global raw_doctor_data ="C:/Users/pku/dropbox/SP Baseline data Clean/Clean of doctor data/Raw_Data"
use "$raw_doctor_data/doctor_raw.dta",clear
*/



**核对问卷编码  no code mistakes
ta form_code, m
duplicates report form_code //surplus==0  no code mistakes


/*-------
Step 1.1: add label
--------*/

*把所有英文翻译的Label都改为中文问卷的Label -XH
label var a2_t1_4  "第一次医学教育：4.获得这次学历的年份 年（例如：1990）"

/*-------
Step 1.2: gen clean copy var
--------*/
**clone var
foreach x of varlist clinic_name - ssSys_IRnd {     
	clonevar `x'_raw = `x'
}


/*-------
Step 2: Rename
--------*/
rename * doc_*
rename doc_gender doc_male


/*-------
Step 3: Clean variables （标黄变量）
--------*/

	/*-------
	Step 3.1:A section 医生基本信息
	--------*/

tostring doc_doctor_phone,format(%100.0g) replace //显示医生电话 记录异常值记录表
codebook doc_doctor_phone

**生成县代码
gen countycode=int(doc_form_code/10000)
order countycode, after(doc_form_code)
ta countycode,m

codebook doc_native
recode doc_native(2=0) //binary dummy var
lab define binary  1"是"  0"否"
lab values doc_native binary  
codebook doc_native

codebook doc_a2_1

list doc_a2_2a doc_form_code if doc_a2_2 ==4
replace doc_a2_2 = 1 if doc_a2_2a == "乡村医生执业证书" | regexm(doc_a2_2a, "乡村医生合格证")
replace doc_a2_2 = 2 if doc_a2_2a == "乡村全科医生职业助理医师" | doc_a2_2a == "职业助理医师"
replace doc_a2_2 = 3 if regexm(doc_a2_2a, "全科医师")
replace doc_a2_2a = "" if doc_a2_2 != 4
replace doc_a2_2 = 0 if doc_a2_2 == 4
ta doc_a2_2, m


codebook doc_a2_3
recode doc_a2_3(2=0) //binary dummy var
lab values doc_a2_3 binary  

codebook doc_med_edu_num //有多少次医学教育：值为0次 该部分备注：跟着师傅学习的
replace doc_a2_3=0 if doc_med_edu_num==0  // 改成没有进行医学教育
tab doc_med_edu_num if doc_a2_3==0,m  // 如果没有进行医学教育，doc_med_edu_num=.
replace doc_med_edu_num=. if doc_med_edu_num==0 //原来0次医学教育改为.

codebook doc_a2_t1_6

codebook doc_a2_t1_7
ta doc_a2_t1_7a if doc_a2_t1_7 == 7
replace doc_a2_t1_7 = 1 	if regexm(doc_a2_t1_7a, "中药")
replace doc_a2_t1_7a = "" 	if regexm(doc_a2_t1_7a, "中药")
replace doc_a2_t1_7 = 2 	if regexm(doc_a2_t1_7a, "临床") | regexm(doc_a2_t1_7a, "全科医生，西医") ///
							| regexm(doc_a2_t1_7a, "医师") | regexm(doc_a2_t1_7a, "医士") | regexm(doc_a2_t1_7a, "全科医生，西医") ///
							| regexm(doc_a2_t1_7a, "药剂学")| regexm(doc_a2_t1_7a, "西药")  
replace doc_a2_t1_7a = "" 	if regexm(doc_a2_t1_7a, "临床") | regexm(doc_a2_t1_7a, "全科医生，西医") ///
							| regexm(doc_a2_t1_7a, "医师") | regexm(doc_a2_t1_7a, "医士") | regexm(doc_a2_t1_7a, "全科医生，西医") ///
							| regexm(doc_a2_t1_7a, "药剂学")| regexm(doc_a2_t1_7a, "西药")  

replace doc_a2_t1_7 = 4 	if regexm(doc_a2_t1_7a, "卫生")
replace doc_a2_t1_7a = "" 	if regexm(doc_a2_t1_7a, "卫生")

replace doc_a2_t1_7 = 6 	if regexm(doc_a2_t1_7a, "全科") | regexm(doc_a2_t1_7a, "乡村") | regexm(doc_a2_t1_7a, "社区") | regexm(doc_a2_t1_7a, "农村") 
replace doc_a2_t1_7a = ""  	if regexm(doc_a2_t1_7a, "全科") | regexm(doc_a2_t1_7a, "乡村") | regexm(doc_a2_t1_7a, "社区") | regexm(doc_a2_t1_7a, "农村") 


codebook doc_a3_1
recode doc_a3_1(2=0) //binary dummy var
lab values doc_a3_1 binary  
codebook doc_a3_1

codebook doc_a3_4
recode doc_a3_4(2=0) //binary dummy var
lab values doc_a3_4 binary  
codebook doc_a3_4

codebook doc_a3_24  //36 missing即36个不想参加培训 已核对 原数据no mistakes
lab var doc_a3_24 "24.对于最希望接受的培训，您最希望以哪种方式进行？（单选）（不包括远程或在线培训）1=专题讲座  2=互动教学 3=情景模拟法 4=临床实践 5=其他，请说明" //加上选项标签

codebook doc_a3_27
lab var doc_a3_27 "27.对于最希望接受的培训，您是否愿意自己承担交通食宿费用？1=是，0=否" //加上选项标签
lab var doc_a3_28 "28.2013-2015年这三年内，您是否参加过县级及以上的培训？1=是，0=否" //加上选项标签
lab var doc_a3_29 "29.2013-2016年这四年内，您是否在上级医院进修实习过（不包括之前提到的培训）？ 1=是，0=否" //加上选项标签

codebook doc_a3_30,m
lab var doc_a3_30 "30.2016年，您是否参与过任何形式的和村诊所工作相关的远程在线培训？ 1=是，0=否" //加上选项标签
recode doc_a3_30(2=0) //binary dummy var
lab values doc_a3_30 binary  
codebook doc_a3_30
codebook doc_a3_31

codebook doc_a3_42
codebook doc_a3_42a //其他请说明是 "认为自己能力可以了，不需要培训了"和"资料" 改成不想参加任何培训
replace doc_a3_42=4 if doc_a3_42==5
replace doc_a3_42a="" if doc_a3_42a== "认为自己能力可以了，不需要培训了"|doc_a3_42a=="资料" 


********************Step 3.2:B接诊情况   无标黄


********************Step 3.3:C常见病症治疗情况  可见excel异常值核对更详细  

**Step 3.3.1拉肚子：a.过去1个月，您接诊了多少人次有该症状的病人？（人次，没有填0）  
tab doc_c_a_d1 ,m // 100 130 150 200 450 600
tabstat doc_c_a_d1 , by(countycode) stat(mean med min max)
tab doc_form_code if doc_c_a_d1==100 //20013 上个月看病人次数：530
tab doc_form_code if doc_c_a_d1==130 //13043 上个月看病人次数：1300
tab doc_form_code if doc_c_a_d1==150 //18094 上个月看病人次数：887
tab doc_form_code if doc_c_a_d1==200 //11071 18063 20023 20075 上个月看病人次数：310、800、1130、1900
tab doc_form_code if doc_c_a_d1==450 //18064 上个月看病人次数：1400
tab doc_form_code if doc_c_a_d1==600 //20021 上个月看病人次数：1500
replace doc_c_a_d1=.o if doc_form_code ==110712 //因为占上个月诊所看病总人数的值为65% 处理大于50%

**Step 3.3.2呼吸困难：a.过去1个月，您接诊了多少人次有该症状的病人？（人次，没有填0）  
tab doc_c_a_d2,m  //
tab doc_form_code if doc_c_a_d2==100 // 上个月看病人次数：800
tab doc_form_code if doc_c_a_d2==110 // 上个月看病人次数：2800
tab doc_form_code if doc_c_a_d2==145 // 上个月看病人次数：538
tab doc_form_code if doc_c_a_d2==150 //上个月看病人次数：1500
tab doc_form_code if doc_c_a_d2==200 // 上个月看病人次数：430
tab doc_form_code if doc_c_a_d2==300 // 上个月看病人次数：560、902、650
tab doc_form_code if doc_c_a_d2==350 // 上个月看病人次数：861
replace doc_c_a_d2=.o if doc_form_code == 140921 //因为占上个月诊所看病总人数的值为54% 处理大于50%

**Step 3.3.3同时头疼，脸有些发烫：a.过去1个月，您接诊了多少人次有该症状的病人？（人次，没有填0）  
tab doc_c_a_d3,m
tabstat doc_c_a_d3 , by(countycode) stat(mean med min max)
tab doc_form_code if doc_c_a_d3==200 // 上个月看病人次数：945、980、469、340、1215
tab doc_form_code if doc_c_a_d3==250 // 上个月看病人次数：1130
tab doc_form_code if doc_c_a_d3==260 // 上个月看病人次数：495
tab doc_form_code if doc_c_a_d3==300 //上个月看病人次数：1267、2635、472
tab doc_form_code if doc_c_a_d3==315 // 上个月看病人次数：1350
tab doc_form_code if doc_c_a_d3==400 // 上个月看病人次数：902
replace doc_c_a_d3=.o if doc_form_code == 180431 //因为占上个月诊所看病总人数的值为64% 处理大于60%

**Step 3.3.4同时流鼻涕，咳嗽，全身无力：a.过去1个月，您接诊了多少人次有该症状的病人？（人次，没有填0）  
tab doc_c_a_d4,m
tabstat doc_c_a_d4 , by(countycode) stat(mean med min max)
tab doc_form_code if doc_c_a_d4==500 // 上个月看病人次数：1560、1509、2635、1500
tab doc_form_code if doc_c_a_d4==550 // 上个月看病人次数：1900
tab doc_form_code if doc_c_a_d4==600 // 上个月看病人次数：890、820
tab doc_form_code if doc_c_a_d4==620 //上个月看病人次数：900
tab doc_form_code if doc_c_a_d4==750 // 上个月看病人次数：1215、1350
tab doc_form_code if doc_c_a_d4==800 // 上个月看病人次数：1416
tab doc_form_code if doc_c_a_d4==1000 // 上个月看病人次数：1980、1400
replace doc_c_a_d4=.o if doc_form_code == 180641 //因为占上个月诊所看病总人数的值为71%  处理大于70%

********************Step 3.4:D考核情况  no mistakes  


********************Step 3.5:E收入  可见excel异常值核对更详细 
**2016年，您当医生的基本工资，基本工资是指上级机构给村医发的固定工资，和工作量不相关、不需要考核的是多少？
tab doc_e_1,m //异常值处理有：-999999999,72,200,250,450,500,550,600,660,700,900,1440
tabstat doc_e_1, by(countycode) stat(mean med min max)
tab doc_e_1 if doc_form_code==140811 //这个是王爱琴组那个-999999999 2016年底才到诊所，对16年的情况不清楚
replace doc_e_1=.n if doc_form_code==140811 //不清楚换成.n
codebook doc_e_1 
tab doc_form_code if doc_e_1==72 //110961
recode doc_e_1(72=7200) // 县11基本工资均值 6580.124，中位数6600
tab doc_form_code if doc_e_1==200 //190312 县19的基本工资均值 4727.5，中位数 6000
tab doc_e_1 if countycode==19 //1个200、2个2400等（共32个）7200居多10个
recode doc_e_1(200=2400) // 怀疑是做表人按月计算，因为也有2400的 
tab doc_form_code if doc_e_1==250 //200511  县20的基本工资均值5585.611，中位数 6000 
recode doc_e_1(250=3000) // 怀疑是做表人按月计算，因为也有3000的(3个)
tab doc_form_code if doc_e_1==450 //150311  县15的基本工资均值7458，中位数7200 
recode doc_e_1(450=5400) // 怀疑是做表人按月计算，因为也有5400的(4个)
tab doc_form_code if doc_e_1==500 
//111412 县11的基本工资均值 6580.124 ，中位数 6600   
//111642 县11的基本工资均值 6580.124 ，中位数 6600  
//160121 县16的基本工资均值  5903.2 ，中位数  7560 
//180321 县18的基本工资均值  5800.345 ，中位数 6600 
recode doc_e_1(500=6000) // 怀疑是做表人按月计算，因为也有6000的(61个)
tab doc_form_code if doc_e_1==550 //1180911 县11的基本工资均值 6580.124 ，中位数 6600   
recode doc_e_1(550=6600) //怀疑是做表人按月计算 ；县工资中位数  6600
tab doc_form_code if doc_e_1==600 //12个
//县11的基本工资均值 6580.124，中位数 6600，县13的基本工资均值7187.071 中位数7200，县20的基本工资均值5585.611，中位数 6000 
recode doc_e_1(600=7200) // 怀疑是做表人按月计算，因为也有7200的(178个)
tab doc_form_code if doc_e_1==660 //16031 县16的基本工资均值  5903.2 ，中位数  7560
recode doc_e_1(660=7920)  // 怀疑是做表人按月计算 ；县工资中位数  7560
tab doc_form_code if doc_e_1==700 //140711 县14的基本工资均值3148 ，中位数  900 (零值比较多占44%)
tab doc_e_1 if countycode==14
sum doc_e_1 if countycode==14 & doc_e_1>0,de //除去零加上上面改完的中位数是5750，均值5621.4
recode doc_e_1(700=5500) //若按700*12=7940 值太大，县14大于7500的只有两个8000、18000（这个还被怀疑异常值）取比5600和5700小因为后面对900修改会使均值中位数增高 所以稍微缩小取值
tab doc_form_code if doc_e_1==900 //140552 县14的基本工资均值3148 ，中位数  900 (零值比较多占44%) （没改上面700之前）
sum doc_e_1 if countycode==14 & doc_e_1>0,de //除去零加上上面改完的中位数是5750，均值5621.4（没改上面700之前，改完700后均值中位数变化不大）
recode doc_e_1(900=5500) //若按900*12=10800 值太大，县14大于10000的只有18000（这个还被怀疑异常值）
recode doc_e_1(72000=7200) //怀疑做表人多打0
//还有14000、17280、18000、21600、31700 共7个样本没处理----—----------------------------注意！待薛浩处理



tab doc_e_2,m
tabstat doc_e_2, by(countycode) stat(mean med min max)
replace doc_e_2=.n if doc_form_code==140811 //不清楚换成.n  王爱琴组那个-999999999 2016年底才到诊所，对16年的情况不清楚

tab doc_e_3,m
tabstat doc_e_3, by(countycode) stat(mean med min max)
replace doc_e_3=.n if doc_form_code==140811 //不清楚换成.n  王爱琴组那个-999999999 2016年底才到诊所，对16年的情况不清楚

********************Step 3.6:F考核情况  no mistakes  

***描述统计 生成医生年龄变量
gen doc_age=2017- doc_birthdate_year
sum doc_age



/*-------
Step 4: Clean variables （其余未标黄变量）
--------*/

tab  doc_a3_m1_t1_7 ,m
tab  doc_a3_m1_t2_7 ,m
recode doc_a3_m1_t1_7 doc_a3_m1_t2_7 (2=0) //binary dummy var
lab values doc_a3_m1_t1_7 binary  
lab values doc_a3_m1_t2_7 binary  
*a3_m1_t3_7--a3_m5_t5_7  无异常值


qui compress

save "$cleandatadir/doctor_clean",replace

****

keep 	doc_form_code doc_male doc_nationality doc_other_nationality doc_birthdate_year doc_birthdate_month doc_native ///
		doc_a1_6 doc_a1_7 doc_a1_8 doc_a1_12 doc_a1_13 ///
		doc_a2_1 doc_a2_2 doc_a2_3 doc_a2_t1_6 doc_a2_t1_7 ///
		doc_a3_1 doc_a3_4 doc_a3_24 doc_a3_25 doc_a3_26 doc_a3_27 doc_a3_28 doc_a3_29 doc_a3_30 doc_a3_40 ///
		doc_c_a_d1 doc_c_a_d2 doc_c_a_d3 doc_c_a_d4 ///
		doc_d_1 doc_d_4 doc_e_1 doc_e_2 doc_e_3 doc_f_3 doc_f_4 doc_f_6 ///
		doc_maindoctor doc_doctor_name doc_doctor_phone
		
save "$outdatadir/doctor_clean_score",replace




