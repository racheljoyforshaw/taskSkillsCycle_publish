********************************************************************************
*********************** DATA ORGANISATION 2Q  *****************************************
********************************************************************************

use Data/LFS_all_raw_2q.dta, clear

******************  keep only these variables needed ***************************
 
keep lgwt* ///
 source* /* -> date */ ///
 ilodefr* ///
 empmon* ///
 inds* /* -> industry */ ///
 start* ///
 age* /* -> age_sq */ ///
 marsta* /* -> mar_cohab */ ///
 marstt* /* -> mar_cohab */ ///
 sex* ///
 ftptwk* /* -> fpt_job */ ///
 jobtyp* /* -> temporary */ ///
 publicr* /* -> public */ ///
 inecacr* /* -> selfe */ ///
 incac05* /* -> selfe */ ///
 hiqua* /* -> edulevel */ ///
 uresmc* ///
 redyl* /* -> f_v_retire */  ///
 lkwfwm* /* -> seek_method */ ///
 soc10m* ///
 soc2km* ///
 persid ///
 wait* ///
 hdpch* ///
 wneft*

		
****************** define time *************************************************

split source, p("_") gen(stub)

split stub2, p("/") gen(stib) 

*** quarter ***
gen quarter = "."

replace quarter = substr(stib2,1,2)


replace quarter = "q1" if substr(stub4,1,2)=="jm" 
replace quarter = "q2" if substr(stub4,1,2)=="aj" 
replace quarter = "q3" if substr(stub4,1,2)=="js" 
replace quarter = "q4" if substr(stub4,1,2)=="od" 

*** year ***
gen year = "."
replace year = substr(stib2,3,2)

split stub4, p("-") gen(stob) 
replace year = substr(stob1,3,2) if substr(stib2,3,2)=="wt" | substr(stib2,3,2)=="o"
replace year = stub3 if year ==""
replace year =  "20" + year


* all together
gen date= year+quarter
gen qtime= quarterly(date, "YQ")
format qtime %tq
drop date
drop quarter
rename qtime date


****************** variables ***************************************************
* create strings for types of flows 
* q`quarter'_dummy is 1 for E, 0 otherwise	 
	 forvalues i=1/2{
	 
	 gen q`i'_status ="." 
	 gen q`i'_dummy = 0
	 gen oneminus_q`i'_dummy = .
	 replace q`i'_status ="E" if ilodefr`i'==1
	 replace q`i'_dummy = 1 if ilodefr`i'==1
	 replace oneminus_q`i'_dummy = 0 if ilodefr`i'==1
	 replace q`i'_status = "U" if ilodefr`i'==2
	 replace q`i'_dummy = 0 if ilodefr`i'==2 | ilodefr`i'==3
	 replace oneminus_q`i'_dummy = 1 if ilodefr`i'==2 | ilodefr`i'==3
	 replace q`i'_status = "I" if ilodefr`i'==3
	
}	 
* status string	
gen status = q1_status + q2_status 
gen quarter = quarter(dofm(date))


* lgwt 
replace lgwt = lgwt18 if date>yq(2011,2)
replace lgwt =lgwt20 if date>yq(2019,3)


save Data/LFS_2q_dates.dta, replace


		 
