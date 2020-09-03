********************************************************************************
*********************** SUMMARY STATS  *****************************************
********************************************************************************


use Data/regressionData_2q.dta, clear



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
 label variable fpt_job1 "Full Time in Previous Job"
 label variable fpt_job2 "Full Time in Current Job"
 label variable temporary1 "Temporary in Previous Job"
 label variable temporary2 "Temporary in Current Job"
 label variable selfe1 "Self Employed in Previous Job"
 label variable selfe2 "Self Employed in Current Job"
 label variable public1 "Public Sector in Previous Job"
 label variable public2 "Public Sector in Current Job"
 label variable edu1 "High Education"
 label variable edu2 "Medium Education"
 label variable edu3 "Low Education"
 label variable seek1 "Search Method: Not Looking"
 label variable seek2 "Search Method: Job Centre"
 label variable seek3 "Search Method: Applying to Ads"
 label variable seek4 "Search Method: Direct Application to Employers"
 label variable seek5 "Search Method: Ask Friends/Relatives"
 label variable seek6 "Other Job Search Method"
 label variable retire1 "Involuntary Separation"
 label variable retire2 "Voluntary Separation"
 label variable retire3 "Other Separation"
 label variable empmon1 "Tenure (months)"
 label variable sex "Female"
 label variable recession1 "UK recession"
 

* since the variances between the recession and non-recession samples are different, we'll use the Satterthwaite approximation *
	local varlist "sex age1 mar_cohab empmon1 fpt_job1 fpt_job2 temporary1 temporary2 selfe1 selfe2 public1 public2 edu1 edu2 edu3 seek1 seek2 seek3 seek4 seek5 seek6 retire1 retire2 retire3"	
	local condition "angSep_CASCOT!=. & modOfMod_CASCOT!=. & (date<yq(2010,4)|date>yq(2012,3)) & ilodefr1==1 & ilodefr2==1 & empmon2>=0 & empmon2<=2 & sex!=. & age1!=. & mar_cohab!=. & empmon1!=. & fpt_job1!=. & fpt_job2!=. & selfe1!=. & selfe2!=. & public1!=. & public2!=. & edu1!=. & edu2!=. & edu3!=. & seek1!=. & seek2!=. & seek3!=. & seek4!=. & seek5!=. & seek6!=. & retire1!=. & retire2!=. & retire3!=. " 
	dmout `varlist' if `condition' using "Results/t_test_temp" , by(recession1) replace tex
	
	shell $my_python_path Code/format_t_test.py



clear

* Do skills predict wages?

* import skill totals 

insheet using Inputs/skillTotal_SOC2000.csv
sort soc2000
rename soc2000 soc2km
save skillTotal_SOC2000.dta, replace
clear


*merge with 5q

use Data/LFS_5q.dta, clear

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

gen logWage = log(rl_grsswk)
label variable logWage "log real gross wage for last quarter job"

* mincerian regression
xi: reg logWage skillTotal i.date i.edulevel1 age1 age1_sq sex empmon1 if fpt_job1 ==1
estimates store returns_skills

	* output to latex file 
	    esttab returns_skills using Results/returns_skill_2000s_temp.tex, replace  star(* 0.10 ** 0.05 *** 0.01) mtitles se nogaps pr2 r2 margin  ///
		b(2) ///
		unstack compress keep(skillTotal age1 age1_sq sex _Iedul* empmon1) ///
		order(skillTotal age1 age1_sq sex empmon1 edulevel1)  /// 
		varwidth(15) modelwidth(8) coeflabels(skillTotal "Skill Level" date date age1 Age age1_sq "Age$^{2}$" sex Female empmon1 "Months Tenure" _Iedulevel1_1 "High Education" _Iedulevel1_2 "Medium Education") nonumbers 
	
	shell $my_python_path Code/format_returns_skill_2000s.py
	
	* output coefficent on skillTotal to tex file 
	 scalar beta_skillTotal = round(_b[skillTotal],0.01)*100
			file open beta_skillTotal using "Results/beta_skillTotal.txt", write replace
			file write beta_skillTotal (beta_skillTotal)
			file close beta_skillTotal
estimates clear








   

	
