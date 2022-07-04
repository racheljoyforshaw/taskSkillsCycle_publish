********************************************************************************
*********************** DATA ORGANISATION 5Q  *****************************************
********************************************************************************

use Data/LFS_all_raw_5q.dta, clear

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
 soc2km* ///
 soc10m* ///
 wait* ///
 persid ///
 grsswk* ///
 hdpch* ///
 wneft*
****************** define time *************************************************

* create a date variable for first quarter we see you in

split source, p("_") gen(stub)
split stub2, p("/") gen(stib) 


*** quarter ***
gen quarter = "."
replace quarter = substr(stib2,1,2)
replace quarter = "q1" if substr(stub4,1,2)=="jm" 
replace quarter = "q2" if substr(stub4,1,2)=="aj" 
replace quarter = "q3" if substr(stub4,1,2)=="js" 
replace quarter = "q4" if substr(stub4,1,2)=="od"  

split stub5, p("-") gen(stob) 
replace quarter = "q1" if substr(stob1,1,2)=="jm" 
replace quarter = "q2" if substr(stob1,1,2)=="aj" 
replace quarter = "q3" if substr(stob1,1,2)=="js" 
replace quarter = "q4" if substr(stob1,1,2)=="od"  

*** year ***
gen year = "."
replace year = substr(stub3,-2,2)
replace year = substr(stub4,-2,2) if substr(stub3,-2,2)=="5q"

split stub4, p("-") gen(steb) 
replace year = substr(steb1,-2,2) if substr(stub3,-2,2)=="al"

replace year = substr(stub4,-2,2) if stub3=="q"
split stub5, p("-") gen(stab) 
replace year = substr(stab1,-2,2) if substr(stub4,-2,2)=="al"
replace year = substr(stub4,3,2) if stub5=="eul.dta"

replace year =  "20" + year



* all together
gen date= year+quarter
gen qtime1= quarterly(date, "YQ")
gen qtime2=qtime1+1
gen qtime3=qtime1+2
gen qtime4=qtime1+3
gen qtime5=qtime1+4
format qtime1 %tq
format qtime2 %tq
format qtime3 %tq
format qtime4 %tq
format qtime5 %tq
drop date
drop quarter
rename qtime1 date1
rename qtime2 date2
rename qtime3 date3
rename qtime4 date4
rename qtime5 date5
drop stib*
drop stub*
drop stob*
drop year



******************************************************************************************************


* create strings for types of flows 
* q`quarter'_dummy is 1 for E, 0 otherwise	 
	 forvalues i=1/5{
	 
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
gen status = q1_status + q2_status + q3_status + q4_status + q5_status

* generate marker of Es
gen num_E = q1_dummy + q2_dummy + q3_dummy+ q4_dummy + q5_dummy

* get rid of observations with only one quarter employment

drop if num_E<2


gen copyTrans = .
gen firstQTrans = .
gen lastQTrans = .
levelsof status /*if status=="...EE"*/
* loop through unique statuses
foreach lev in `r(levels)' {
	di "`lev'"
	* get number of employed spells for this transition type
	quietly summarize num_E if status=="`lev'"
	* loop through transitions (which is number of Es minus 1)
	local numTrans = r(max)-1
	forvalues i=1/`numTrans' {
		* duplicate the transitions
		local j=`i'-1 /* previous transition counter */
		* does copyTrans1 already exist?
		capture confirm var copyTrans1
		if `i' == 1 { // no, so first loop
			*di "duplicating observations"
			expand 2 if status=="`lev'" , gen(copyTrans1) /* this duplicates the observations and creates a marker = 1 for dup */
			}
		* yes, so create the next variable
		else {
		*di "duplicating observations for the 2+ time"
		expand 2 if status=="`lev'" & copyTrans`j'==1, gen(copyTrans`i') /* this duplicates the observations and creates a marker = 1 for dup */
		}
		}
* create one copyTrans variable and a marker variable for first quarter and last quarter for each transition of interest
	local j=1 /* quarter position */
	* loop through each transition
	forvalues i=1/`numTrans' { /* transition position */
		* make 4 variables into one variable marker with possible values 1-4 of copied transitions
		replace copyTrans = `i' if copyTrans`i'==1
		drop copyTrans`i'
	
		* first & last quarter
		local found1=0
		local found2=0
		* loop through each quarter to find first Q of transition (find the first E)
		while `j'<=5 & `found1'==0{
			*di "`j'"
			quietly summarize q`j'_dummy if status=="`lev'" & copyTrans==`i'
			local q_dummy = r(mean)
			* is this quarter an E?
			if `q_dummy'==1 {
				*di "creating first Q marker"
				*yes - create a marker for first Q of transition
				replace firstQTrans = `j' if status=="`lev'" & copyTrans==`i'
				local found1 = 1
				local k= `j'+ 1 /* first possible position for last Q is the quarter after first Q */
				* now loop through each subsequent quarter to find last Q of transition (find the next E)
				while `k'<=5 & `found2'==0 {
					quietly summarize q`k'_dummy if status=="`lev'" & copyTrans==`i'
					local q_dummy = r(mean)
					* is this quarter an E?
					if `q_dummy'==1{
						* yes - create a marker for last Q of transition
						*di "`k'"
						*di " creating last Q marker"	
						replace lastQTrans = `k' if status=="`lev'" & copyTrans==`i'
						local found2 = 1
						}
					* no - look at next quarter for last Q of transition
					else {
					*di " last Q not here"
					local k = `k' + 1 
					}
					}
				* set j = k because end of previous transition can be start of next
				local j = `k' 
				}
			* no - look at the next quarter for first Q of transition
			else {
			*di "first Q not here"
			local j = `j' + 1	
			}
			}
		}
		drop if copyTrans==. & status=="`lev'" // this drops the original data, so only copied transitions left
	}


* variable to count how many quarters unemployed/inactive before finding job 
* U or I spell length (from quarters observed)
gen UorIspell = .
replace UorIspell = 0 if (firstQTrans ==1 & lastQTrans ==2 & q1_dummy==1 & q2_dummy==1) | (firstQTrans ==2 & lastQTrans ==3 & q2_dummy==1 & q3_dummy==1) | (firstQTrans==3 & lastQTrans ==4 & q3_dummy==1 & q4_dummy==1)| (firstQTrans ==4 & lastQTrans ==5 & q4_dummy==1 & q5_dummy==1)
replace UorIspell = 1 if (firstQTrans ==1 & lastQTrans ==3 & q1_dummy==1 & q2_dummy==0 & q3_dummy==1) | (firstQTrans ==2 & lastQTrans ==4 & q2_dummy==1 & q3_dummy==0 & q4_dummy==1) | (firstQTrans ==3  & lastQTrans ==5 & q3_dummy==1 & q4_dummy==0 & q5_dummy==1)
replace UorIspell = 2 if (firstQTrans ==1 & lastQTrans ==4 & q1_dummy==1 & q2_dummy==0 & q3_dummy==0 & q4_dummy==1) | (firstQTrans ==2 & lastQTrans ==5 & q2_dummy==1 & q3_dummy==0 & q4_dummy==0 & q5_dummy==1 )
replace UorIspell = 3 if (firstQTrans ==1 & lastQTrans ==5 & q1_dummy==1 & q2_dummy==0 & q3_dummy==0 & q4_dummy==0 & q5_dummy==1) 

* drop first & second quarter EEs (because we drop all 1st and 2nd quarter IEs and UEs since no previous E information)
drop if q1_dummy==1 & q2_dummy==1 & firstQTrans==1 & lastQTrans==2
drop if q2_dummy==1 & q3_dummy==1 & firstQTrans==2 & lastQTrans==3
drop if q1_status=="." & q2_dummy==1 & q3_dummy==1 & firstQTrans==2 & lastQTrans==3
drop if q1_status=="." & q3_dummy==1 & q4_dummy==1 & firstQTrans==3 & lastQTrans==4
drop if q1_status=="." &  q2_status=="." & q3_dummy==1 & q4_dummy==1 & firstQTrans==3 & lastQTrans==4
drop if q1_status=="." &  q2_status=="." & q4_dummy==1 & q5_dummy==1 & firstQTrans==4 & lastQTrans==5

drop if q1_status=="." &  q2_status=="." &  q3_status=="." & q4_dummy==1 & q5_dummy==1 & firstQTrans==4 & lastQTrans==5


**** move control variables to 2q format by moving to spaces 1 and 2 ***


*vars that are not specific to the previous job
local vars age marsta marstt hiqual hiqual4 hiqual5 hiqual8 uresmc redylft lkwfwm wait grsswk hdpch19 wneft11 ilodefr
foreach variable of local vars {
*last period of trans
replace `variable'1 = `variable'2 if lastQTrans==3
replace `variable'2 = `variable'3 if lastQTrans==3

replace `variable'1 = `variable'3 if lastQTrans==4
replace `variable'2 = `variable'4 if lastQTrans==4

replace `variable'1 = `variable'4 if lastQTrans==5
replace `variable'2 = `variable'5 if lastQTrans==5

}



* replace vars that need to be taken from the previous job spell
* note that 1st period vars are taken from firstQTrans
local vars1 ftptwk jobtyp publicr inecacr incac05 inds92m inds07m soc10m soc2km empmon
foreach variable of local vars1 {
*2nd transition of interest
replace `variable'1 = `variable'2 if firstQTrans==2
replace `variable'2 = `variable'3 if lastQTrans==3
*3rd transition of interest
replace `variable'1 = `variable'3 if firstQTrans==3
replace `variable'2 = `variable'4 if lastQTrans==4
*4th transition of interest
replace `variable'1 = `variable'4 if firstQTrans==4
replace `variable'2 = `variable'5 if lastQTrans==5
}





* quarter
gen quarter=.
replace quarter = quarter(dofm(date1)) if lastQTrans==2
replace quarter = quarter(dofm(date2)) if lastQTrans==3
replace quarter = quarter(dofm(date3)) if lastQTrans==4
replace quarter = quarter(dofm(date4)) if lastQTrans==5


* date variables - date is quarter prior to last E
gen date = .
replace date = date1 if lastQTrans==2
replace date = date2 if lastQTrans==3
replace date = date3 if lastQTrans==4
replace date = date4 if lastQTrans==5
format date %tq
*tostring quarter, replace
drop date1 date2 date3 date4

* status variable
* generate 5 different status variables
gen status1 = substr(status,1,1)
gen status2 = substr(status,2,1)
gen status3 = substr(status,3,1)
gen status4 = substr(status,4,1)
gen status5 = substr(status,5,1)
drop status
gen status = "."
replace status = status1 + status2 if lastQTrans==2
replace status = status2 + status3 if lastQTrans==3
replace status = status3 + status4 if lastQTrans==4
replace status = status4 + status5 if lastQTrans==5

* replace wneft with UorIspell 
replace wneft112 = 0 
replace wneft112 = 1 if UorIspell==1
replace wneft112 = 2 if UorIspell==2
replace wneft112 = 3 if UorIspell==3

* get rid of 3, 4,5 quarters
drop *3 
drop *4
drop *5
drop copyTrans num_E *_status *_dummy lastQTrans firstQTrans

* lgwt 
replace lgwt = lgwt17 if date>yq(2011,2)
replace lgwt = lgwt18 if date>yq(2018,2)

save Data/LFS_5q_dates.dta, replace

