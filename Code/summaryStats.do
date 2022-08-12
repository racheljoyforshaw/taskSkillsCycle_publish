********************************************************************************
*********************** SUMMARY STATS  *****************************************
********************************************************************************


*use Data/regressionData_2q_5q.dta, clear

use Data/regressionData_2q_5q_post.dta, clear
keep if used_ALL


* get most recent date
egen min_date = min(date)
egen max_date = max(date)
format min_date %tq
format max_date %tq
export delimited max_date using "Results/max_date.txt", novarnames datafmt replace
export delimited min_date using "Results/min_date.txt", novarnames datafmt replace
* format in python
shell $my_python_path Code/get_max_min_date.py




* Calculate difference in means between recession/non-recession samples
* 1. Check that they have the same variance:

* make some dummies for the sum stats

 
 tab edulevel1, gen(edu)
 tab seek_method, gen(seek)
 tab uresmc1, gen(region)
 tab f_v_retire2, gen(retire)
 
 label variable age1 "Age"	
 label variable angSep_CASCOT "$\Delta$ Task Composition"
 label variable modOfMod_CASCOT "$\Delta$ Skill Level"
 label variable mar_cohab "Married"
 label variable fpt_job1 "Full Time, Previous Job"
 label variable fpt_job2 "Full Time, Current Job"
 label variable temporary1 "Temporary, Previous Job"
 label variable temporary2 "Temporary, Current Job"
 label variable selfe1 "Self Employed, Previous Job"
 label variable selfe2 "Self Employed, Current Job"
 label variable public1 "Public Sector, Previous Job"
 label variable public2 "Public Sector, Current Job"
 label variable edu1 "High Education"
 label variable edu2 "Medium Education"
 label variable edu3 "Low Education"
 label variable seek1 "Method of Seeking: Not Looking"
 label variable seek2 "Method of Seeking: Job Centre"
 label variable seek3 "Method of Seeking: Ads"
 label variable seek4 "Method of Seeking: Direct Application"
 label variable seek5 "Method of Seeking: Family/Friend"
 label variable seek6 "Method of Seeking: Other"
 label variable retire1 "Involuntary Separation"
 label variable retire2 "Voluntary Separation"
 label variable retire3 "Other Separation"
 label variable durats1 "Previous Employment Duration"
 label variable sex "Female"
 label variable recession1 "UK recession"
 label variable n_child "Number of Children"
 label variable lookfor1 "Looking for Job"
 
 * unemployment rate mean
 egen unemp_mean = mean(Aggre_Ur_pct)
 gen unemp_above = 0
 replace unemp_above = 1 if Aggre_Ur_pct>=unemp_mean

* since the variances between the recession and non-recession samples are different, we'll use the Satterthwaite approximation *
	local varlist "sex age1 mar_cohab n_child edu1 edu2 edu3 durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 retire1 retire2 retire3 seek1 seek2 seek3 seek4 seek5 seek6 "	
	local condition "jobMover==1 & angSep_CASCOT!=. & Aggre_Ur_pct!=. & Devia_Ur_pct!=. & sex!=. & age1!=. & age1_sq & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & n_child!=. & lookfor1!=." 
	dmout `varlist' if `condition' using "Results/t_test_temp" , by(unemp_above) replace tex
	
	shell $my_python_path Code/format_t_test.py
	/*erase Results/t_test_temp.tex */


clear

* Do skills predict wages?

* import skill totals 

insheet using Inputs/skillTotal_SOC2000.csv
sort soc2000
rename soc2000 soc2km
save skillTotal_SOC2000.dta, replace
clear


*merge with 5q

use Data/LFS_all_raw_5q_dates.dta, clear

rename date1 date

* create variable skillTotal
gen soc2km = .
replace soc2km = soc2km1 if soc2km1!=.

sort soc2km
merge m:m soc2km using skillTotal_SOC2000.dta
drop if _merge==2
drop _merge

gen skillTotal =.
replace skillTotal = sum2000 if sum2000!=. & soc2km!=.

* normalise skillTotal for ease of interpretation
summarize skillTotal
gen skillTotal_std= ((skillTotal- r(mean))/r(sd))
drop skillTotal
rename skillTotal_std skillTotal

* deflate wages

**Import the CPI data in order to obtain "real wage" from "nominal wage"

	merge m:1 date using Inputs/CPI_uk_base_2015.dta , keepusing(cpi) 
	  replace cpi=cpi/100
	  drop if _merge!=3
	 drop _merge

* use first period wage 
replace grsswk1 = . if grsswk1<0
gen rl_grsswk1 = .	 
replace rl_grsswk1= grsswk1/cpi

gen logWage = log(rl_grsswk1)
label variable logWage "log real gross wage for last quarter job"

* convert months tenure to years
gen empyear1 = empmon1/12

* age squared
gen age1_sq = age1^2
replace age1_sq = age1_sq/1000


* edulevel 
gen edulevel1=. if (hiqual1==-9| hiqual1==-8 |hiqual1==41) & date>yq(1996,1) & date< yq(2004,2)
label variable edulevel1 "Education level, 1=high, 2=med, 3=low"
replace edulevel1=1 if hiqual1>0 & hiqual1<=4 & date>yq(1996,1) & date< yq(2004,2)
replace edulevel1=2 if hiqual1>4 & hiqual1<=39 & date>yq(1996,1) & date< yq(2004,2)
replace edulevel1=3 if hiqual1==40 & date>yq(1996,1) & date< yq(2004,2)

replace edulevel1=. if (hiqual41==-9| hiqual41==-8 |hiqual41==46) & date>=yq(2004,1) & date< yq(2005,2)
replace edulevel1=1 if hiqual41>0 & hiqual41<=4 & date>=yq(2004,1) & date< yq(2005,2)
replace edulevel1=2 if hiqual41>4 & hiqual41<=44 & date>=yq(2004,1) & date< yq(2005,2)
replace edulevel1=3 if hiqual41==45 & date>=yq(2004,1) & date< yq(2005,2)

replace edulevel1=. if (hiqual51==-9| hiqual51==-8 |hiqual51==49) & date>=yq(2005,1) & date< yq(2008,1)
replace edulevel1=1 if hiqual51>0 & hiqual51<=4 & date>=yq(2005,1) & date< yq(2008,1)
replace edulevel1=2 if hiqual51>4 & hiqual51<48 & date>=yq(2005,1) & date< yq(2008,1)
replace edulevel1=3 if hiqual51==48 & date>=yq(2005,1) & date< yq(2008,1)

replace edulevel1=. if (hiqual81==-9 | hiqual81==-8 | hiqual81==50) & date>yq(2007,4) & date <yq(2011,1)
replace edulevel1=1 if hiqual81>0 & hiqual81<=4 & date>yq(2007,4) & date< yq(2011,1)
replace edulevel1=2 if hiqual81>4 & hiqual81<=48 & date>yq(2007,4) & date< yq(2011,1)
replace edulevel1=3 if hiqual81==49 & date>yq(2007,4) & date< yq(2011,1)

replace edulevel1=. if (hiqua111==-9 | hiqua111==-8 | hiqua111==71) & date>=yq(2011,1) & date <yq(2015,3)
replace edulevel1=1 if hiqua111>0 & hiqua111<=9 & date>=yq(2011,1) & date <yq(2015,3)
replace edulevel1=2 if hiqua111>9 & hiqua111<=69  & date>=yq(2011,1) & date <yq(2015,3)
replace edulevel1=3 if hiqua111==70  & date>=yq(2011,1) & date <yq(2015,3)

replace edulevel1=. if (hiqua151==-9 | hiqua151==-8 | hiqua151==75) & date>=yq(2015,3)
replace edulevel1=1 if hiqua151>0 & hiqua151<=9 & date>=yq(2015,3)
replace edulevel1=2 if hiqua151>9 & hiqua151<=73  & date>=yq(2015,3)
replace edulevel1=3 if hiqua151==74 & date>yq(2007,4) & date>=yq(2015,3)

char edulevel1[omit] 3

* part/full-time work
gen fpt_job1=1 if ftptwk1==1 /*fulltime*/
*label variable fpt_job1 "Full-time/part-time job, 1=FT, 0=PT, .=dk/na"
label variable fpt_job1 "Full-time, 1=yes, 0=no"
replace fpt_job1=0 if ftptwk1==2 /* parttime*/
*replace fpt_job1=. if ftptwk1==-9 |ftptwk1==-8 /* missing */
gen fpt_job2=1 if ftptwk2==1 /*fulltime*/
label variable fpt_job2 "Full-time, 1=yes, 0=no"
replace fpt_job2=0 if ftptwk2==2 /* parttime*/
*replace fpt_job2=. if ftptwk2==-9 |ftptwk2==-8 /* missing */
drop ftptwk*



* mincerian regression
xi: reg logWage skillTotal i.edulevel1 age1 age1_sq sex empyear1 if fpt_job1 ==1
estimates store returns_skills

	* output to latex file 
	    esttab returns_skills using Results/returns_skill_2000s_temp.tex, replace  star(* 0.10 ** 0.05 *** 0.01) mtitles se nogaps pr2 r2 margin  ///
		b(2) ///
		unstack compress keep(skillTotal age1 age1_sq sex _Iedul* empyear1) ///
		order(skillTotal age1 age1_sq sex empmon1 _Iedul*)  /// 
		varwidth(15) modelwidth(8) coeflabels(skillTotal "Task Complexity Level" age1 Age age1_sq "Age$^{2}$" sex Female empyear1 "Years Tenure" _Iedulevel1_1 "High Education" _Iedulevel1_2 "Medium Education") nonumbers 
	
	shell $my_python_path Code/format_returns_skill_2000s.py
	erase  Results/returns_skill_2000s_temp.tex
	
	* output coefficent on skillTotal to tex file 
	 scalar beta_skillTotal = round(_b[skillTotal],0.01)*100
			file open beta_skillTotal using "Results/beta_skillTotal.txt", write replace
			file write beta_skillTotal (beta_skillTotal)
			file close beta_skillTotal
estimates clear

erase skillTotal_SOC2000.dta







   

	
