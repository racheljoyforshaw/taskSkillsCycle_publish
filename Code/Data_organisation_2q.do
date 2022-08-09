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
 qrtr* ///
 w1yr* ///
 wneft*

		
****************** define time *************************************************


* create a date variable


*** quarter *** of when first seen
gen quarter ="."
replace quarter = "q1" if qrtr==1
replace quarter = "q2" if qrtr==2
replace quarter = "q3" if qrtr==3 
replace quarter = "q4" if qrtr==4



*** year ***

split source, p("_") gen(stub)
gen year = "."

replace year = "00" if substr(stub2,-2,2)=="01" & w1yr==0
replace year = "01" if w1yr==1 & (substr(stub2,-2,2)=="01" |  substr(stub2,-2,2)=="02") 
replace year = "02" if w1yr==2 & (substr(stub2,-2,2)=="02" |  substr(stub2,-2,2)=="03") 
replace year = "03" if w1yr==3 & (substr(stub2,-2,2)=="03" |  substr(stub2,-2,2)=="04") 
replace year = "04" if w1yr==4 & (substr(stub2,-2,2)=="04" |  substr(stub2,-2,2)=="05") 
replace year = "05" if w1yr==5 & (substr(stub2,-2,2)=="05" |  substr(stub2,-2,2)=="06") 
replace year = "06" if w1yr==6 & (substr(stub2,-2,2)=="06" |  substr(stub2,-2,2)=="07") 
replace year = "07" if w1yr==7 & (substr(stub2,-2,2)=="07" |  substr(stub2,-2,2)=="08") 
replace year = "08" if w1yr==8 & (substr(stub2,-2,2)=="08" |  substr(stub2,-2,2)=="09") 
replace year = "09" if w1yr==9 & (substr(stub2,-2,2)=="09" |  substr(stub2,-2,2)=="10") 
replace year = "10" if w1yr==0 & (substr(stub2,-2,2)=="10" |  substr(stub2,-2,2)=="11") 
replace year = "11" if w1yr==1 & substr(stub2,-2,2)=="11" 


replace year = "00" if year=="." & w1yr==0 & (substr(stub3,-2,2)=="00" |  substr(stub3,-2,2)=="01")
replace year = "01" if year=="." & w1yr==1 & substr(stub3,-2,2)=="01"
replace year = "99" if year=="." & w1yr==9 & substr(stub3,-2,2)=="00"

replace year = "10" if year=="." & w1yr==0 & substr(stub4,-2,2)=="11"
replace year = "11" if year=="." & w1yr==1 & (substr(stub4,-2,2)=="11" |  substr(stub4,-2,2)=="12")
replace year = "12" if year=="." & w1yr==2 & (substr(stub4,-2,2)=="12" |  substr(stub4,-2,2)=="13")
replace year = "13" if year=="." & w1yr==3 & (substr(stub4,-2,2)=="13" |  substr(stub4,-2,2)=="14")
replace year = "14" if year=="." & w1yr==4 & (substr(stub4,-2,2)=="14" |  substr(stub4,-2,2)=="15")
replace year = "15" if year=="." & w1yr==5 & (substr(stub4,-2,2)=="15" |  substr(stub4,-2,2)=="16")
replace year = "16" if year=="." & w1yr==6 & (substr(stub4,-2,2)=="16" |  substr(stub4,-2,2)=="17")
replace year = "17" if year=="." & w1yr==7 & (substr(stub4,-2,2)=="17" |  substr(stub4,-2,2)=="18")
replace year = "18" if year=="." & w1yr==8 & (substr(stub4,-2,2)=="18" |  substr(stub4,-2,2)=="19")
replace year = "19" if year=="." & w1yr==9 & (substr(stub4,-2,2)=="19" |  substr(stub4,-2,2)=="20")
replace year = "20" if year=="." & w1yr==0 & (substr(stub4,-2,2)=="20" |  substr(stub4,-2,2)=="21")
replace year = "21" if year=="." & w1yr==1 & substr(stub4,-2,2)=="21" 

replace year =  "20" + year
replace year = "1999" if year=="2099"

* fix incorrect quarter coding for 2006 & 2021

*replace quarter = substr(stub2,4,2) if year=="2006"
replace quarter = substr(stub2,4,2) if year=="2005"

* all together
gen date= year+quarter
gen qtime1= quarterly(date, "YQ")
gen qtime2=qtime1+1
format qtime1 %tq
format qtime2 %tq
drop date
drop quarter
rename qtime1 date1
rename qtime2 date2
drop stub*
drop year



gen date = date1
format date %tq
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
replace lgwt = lgwt18 if date>yq(2010,3) & lgwt==.
replace lgwt =lgwt20 if date>yq(2018,4) & lgwt==.


save Data/LFS_2q_dates.dta, replace


		 
