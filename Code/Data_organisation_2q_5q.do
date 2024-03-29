********************************************************************************
*********************** DATA CLEANING  *****************************************
********************************************************************************


*********************** CREATE SYNTHETIC 2Q DATASET ****************************

****************** keep observations that are in the 2q but not 5q sample ******
clear

*make a text file with all 2q and 5q persids
use Data/LFS_all_raw_2q.dta, clear
keep persid
export delimited using "temp/2q_persid.txt", replace novarnames  
use Data/LFS_all_raw_5q.dta, clear
keep persid
export delimited using "temp/5q_persid.txt", replace  novarnames  
clear

* python code to get list of individuals in the 2q but not 5q data
shell $my_python_path/ Code/Data_2q_not_5q.py
import delimited "temp/2q_not_5q.txt"

rename v1 persid
sort persid
save "temp/2q_not_5q.dta", replace

use Data/LFS_all_raw_2q.dta, clear
sort persid
merge m:1 persid using "temp/2q_not_5q.dta"
keep if _merge==3
drop _merge


******************  keep only these variables needed ***************************
 
keep lgwt ///
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
 redylft* /* -> f_v_retire */  ///
 lkwfwm* /* -> seek_method */ ///
 soc2km* ///
 soc10m* ///
 wait*

		
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
rename qtime date

******************* create labour market status variable in 2q *****************

* create strings for types of flows 
	 
	 forvalues i=1/2{
	 
	 gen q`i'_status ="." 
	 gen q`i'_dummy = .
	 gen oneminus_q`i'_dummy = .
	 replace q`i'_status ="E" if ilodefr`i'==1
	 replace q`i'_dummy = 1 if ilodefr`i'==1
	 replace oneminus_q`i'_dummy = 0 if ilodefr`i'==1
	 replace q`i'_status = "U" if ilodefr`i'==2
	 replace q`i'_dummy = 0 if ilodefr`i'==2 | ilodefr`i'==3
	 replace oneminus_q`i'_dummy = 1 if ilodefr`i'==2 | ilodefr`i'==3
	 replace q`i'_status = "I" if ilodefr`i'==3
	
}	 
	
gen status = q1_status + q2_status

* keep only EE transitions in 2q
keep if status=="EE" 




******************** create U or I spell in 2q *********************************


* variable to count how many quarters unemployed/inactive before finding job 
* in 2q, kept only direct EE transitions so U or I spell length =0
gen UorIspell = .
replace UorIspell = 0



***************** append 5q modified to be 2q format sample ********************

append using LFS_5q.dta




* drop any non-2000s data
*keep if date>= yq(2000,1) & date<=yq(2010,4)

****************** variables ***************************************************

* sex - make 1/0
replace sex = 0 if sex==1
replace sex = 1 if sex==2
label variable sex "Sex, 1=female 0=male"

* empmon (months employed)
replace empmon1=. if empmon1==-9 | empmon1==-8
replace empmon2=. if empmon2==-9 | empmon2==-8

* industry
gen industry_temp=inds92m1 if date<=yq(2008,4) & inds92m1!=.

replace industry_temp= inds07m1 if date>yq(2008,4) & inds07m1!=.
replace industry_temp=. if industry==-8| industry==-9
*keep if industry<20 
gen industry = .
replace industry = 1 if industry_temp>=1 & industry_temp<=2 /* primary */
replace industry = 2 if industry_temp>=3 & industry_temp<=6 /* secondary */
replace industry = 3 if industry_temp>=7  /* tertiary */
label variable industry "Industry category, 1=primary 2=secondary 3=tertiary"

drop inds*
char industry[omit] 1

* available to start work dummy
gen available = 0
label variable available "Available to start work, 1=yes, 0=no/na"
replace available = 1 if start1== 1
drop start*

* age - drop u-16s o-64s
drop if age1>64 | age2>64
drop if age1<16 | age2<16

* create age squared
gen age1_sq= age1*age1
label variable age1_sq "Age squared"

* mar_cohab (marriage status)
gen mar_cohab=. 
label variable mar_cohab "Maried/cohabitating, 1=yes, 0=no"
replace mar_cohab=1 if (marsta1==2 & marstt1==. ) | ( marsta1==6 & marstt1==.)| (marstt1==2 & marsta1==.) /*married/cohabitating*/
replace mar_cohab=0 if (marsta1==1 | marsta1==3 | marsta1==4 | marsta1==5 | marsta1==7 | marsta1==8 | marsta1==9 ) & marstt1==. /*not married/cohabitating*/
replace mar_cohab=0 if (marstt1==1 | marstt1==3 | marstt1==4 | marstt1==5 ) & marsta1==. /*not married/cohabitating*/
drop marsta* marstt*


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


* temporary 
*gen temporary1= 1 if jobtyp1==2 /* temporary */
gen temporary1=0
label variable temporary1 "Temporary job, 1=yes 0=no"
replace temporary1= 1 if jobtyp1==2 /* temporary */
*replace temporary1= 0 if jobtyp1==1 /* permanent */
*replace temporary1=. if jobtyp1==-9 | jobtyp1==-8 /* missing */
*gen temporary2= 1 if jobtyp2==2 /* temporary */
gen temporary2=0
label variable temporary2 "Temporary job, 1=yes 0=no"
replace temporary2= 1 if jobtyp2==2 /* temporary */
*replace temporary2= 0 if jobtyp2==1 /* permanent */
*replace temporary2=. if jobtyp2==-9 | jobtyp2==-8 /* missing */
drop jobtyp*


* public/private sector

*gen public1 = . if publicr1==-9 | publicr1==-8 /*missing*/
gen public1 =0
*label variable public1 "Public/private job, 1=Pub, 0=Pri, .=dk/na"
label variable public1 "Public job, 1=Yes, 0=No"
replace public1=0 if publicr1==1 /* private */
replace public1=1 if publicr1==2 /* public */
gen public2 = . if publicr2==-9 | publicr2==-8 /*missing*/
*label variable public2 "Public/private job, 1=Pub, 0=Pri, .=dk/na"
label variable public2 "Public job, 1=Yes, 0=No"
replace public2=0 if publicr2==1 /* private */
replace public2=1 if publicr2==2 /* public */
drop publicr*


* self-employed or not
*gen selfe1=. /*missing*/
gen selfe1=0
*label variable selfe1 "Self-employed, 1=Yes, 0=No, .=dk/na"
label variable selfe1 "Self-employed, 1=Yes, 0=No"
*replace selfe1=0 if inecacr1==1| inecacr1==3 | incac051==1 | incac051==3 /*not self-employed*/
replace selfe1=1 if inecacr1==2 | incac051==2 /*self-employed*/
*gen selfe2 =.
gen selfe2=0
*label variable selfe2 "Self-employed, 1=Yes, 0=No, .=dk/na"
label variable selfe2 "Self-employed, 1=Yes, 0=No"
*replace selfe2=0 if inecacr2==1| inecacr2==3 | incac052==1 | incac052==3 /*not self-employed*/
replace selfe2=1 if inecacr2==2 | incac052==2 /*self-employed*/
drop inecacr* incac05*


* edulevel 
gen edulevel1=. if (hiqual1==-9| hiqual1==-8 |hiqual1==41) & date>yq(1996,1) & date< yq(2004,2)
label variable edulevel1 "Education level, 1=high, 2=med, 3=low"
replace edulevel1=1 if hiqual1>0 & hiqual1<=4 & date>yq(1996,1) & date< yq(2004,2)
replace edulevel1=2 if hiqual1>4 & hiqual1<=39 & date>yq(1996,1) & date< yq(2004,2)
replace edulevel1=3 if hiqual1==40 & date>yq(1996,1) & date< yq(2004,2)

replace edulevel1=. if (hiqual41==-9| hiqual41==-8 |hiqual41==46) & date>yq(2004,1) & date< yq(2005,2)
replace edulevel1=1 if hiqual41>0 & hiqual41<=4 & date>yq(2004,1) & date< yq(2005,2)
replace edulevel1=2 if hiqual41>4 & hiqual41<=44 & date>yq(2004,1) & date< yq(2005,2)
replace edulevel1=3 if hiqual41==45 & date>yq(2004,1) & date< yq(2005,2)

replace edulevel1=. if (hiqual51==-9| hiqual51==-8 |hiqual51==49) & date>yq(2005,1) & date< yq(2008,1)
replace edulevel1=1 if hiqual51>0 & hiqual51<=4 & date>yq(2005,1) & date< yq(2008,1)
replace edulevel1=2 if hiqual51>4 & hiqual51<48 & date>yq(2005,1) & date< yq(2008,1)
replace edulevel1=3 if hiqual51==48 & date>yq(2005,1) & date< yq(2008,1)

replace edulevel1=. if (hiqual81==-9 & hiqual81==-8 | hiqual81==50) & date>yq(2007,4) & date <yq(2011,1)
replace edulevel1=1 if hiqual81>0 & hiqual81<=4 & date>yq(2007,4) & date< yq(2011,1)
replace edulevel1=2 if hiqual81>4 & hiqual81<=48 & date>yq(2007,4) & date< yq(2011,1)
replace edulevel1=3 if hiqual81==49 & date>yq(2007,4) & date< yq(2011,1)

replace edulevel1=. if (hiqua111==-9 & hiqua111==-8 | hiqua111==71) & date>yq(2010,4) & date <yq(2015,1)
replace edulevel1=1 if hiqua111>0 & hiqua111<=9 & date>yq(2010,4) & date< yq(2015,1)
replace edulevel1=2 if hiqua111>9 & hiqua111<=69 & date>yq(2010,4) & date< yq(2015,1)
replace edulevel1=3 if hiqua111==70 & date>yq(2010,4) & date< yq(2015,1)

replace edulevel1=. if (hiqual151==-9 & hiqual151==-8 | hiqual151==85 ) & date>yq(2014,4) & date<yq(2015,4)
replace edulevel1=1 if hiqual151>0 & hiqual151<=8 & date>yq(2014,4) & date<yq(2015,4)
replace edulevel1=2 if hiqual151>8 & hiqual151<=83  & date>yq(2014,4) & date<yq(2015,4)
replace edulevel1=3 if hiqual151==84  & date>yq(2014,4) & date<yq(2015,4)

replace edulevel =. if (hiqua151==-9 & hiqua151==-8 | hiqua151==75) & date>yq(2015,3)
replace edulevel = 1 if hiqua151>0 & hiqua151<=8 & date>yq(2015,3)
replace edulevel = 2 if hiqua151>8 & hiqua151<=73 & date>yq(2015,3)
replace edulevel = 3 if hiqua151==74 & date>yq(2015,3)

drop hiqual*
char edulevel1[omit] 3


* why left last job
* - 2011q3
gen f_v_retire2=. if (redylft2==-9 | redylft2==-8 ) 
label variable f_v_retire2 "Why left last job, 1=involuntary, 2=voluntary, 3=other"
replace f_v_retire2=1 if (redylft2==1| redylft2==2| redylft2==3 | redylft2==5) /*involuntary */
replace f_v_retire2=2 if (redylft2==4 | redylft2==8) & date>=yq(1995,1) /*voluntary */
replace f_v_retire2=3 if (redylft2==6 | redylft2==7 | redylft2==9) /*retired, health, other*/
* 2011q4 - 2012q4
replace f_v_retire2=. if (redyl112==-9 | redyl112==-8 )  & date>=yq(2011,4)
replace f_v_retire2=1 if (redyl112==1| redyl112==2| redyl112==3 | redyl112==5)  & date>=yq(2011,4) & date<=yq(2012,4)/*involuntary */
replace f_v_retire2=2 if (redyl112==4| redyl112==8) & date>=yq(2011,4) & date<=yq(2012,4)/*voluntary */
replace f_v_retire2=3 if (redylft2==6 | redylft2==7 | redylft2==9|redylft2==10)& date>=yq(2011,4) & date<=yq(2012,4)/*retired, health, other*/
*2013q1 - 
replace f_v_retire2 = . if (redyl132==-9 | redyl132==-8 )  & date>=yq(2013,4)
replace f_v_retire2 = 1 if (redyl132==1 | redyl132==2 | redyl132==3| redyl132==4 )  & date>=yq(2013,1)
replace f_v_retire2 = 3 if (redyl132==5 | redyl132==6 | redyl132==7 | redyl132==8)  & date>=yq(2013,1)
replace f_v_retire2 = 3 if (redyl132==9 | redyl132==10 | redyl132==11 )  & date>=yq(2013,1)

drop redyl*
char f_v_retire2[omit] 2

* methods of seeking job
gen seek_method=.  /*missing*/
label variable seek_method "Methods of seeking job, 1=Agency, 2=Ad, 3=Direct, 4=Friend, 5=Other"
replace seek_method=1 if (lkwfwm2>0 & lkwfwm2<=4 & date>=137) | (lkwfwm2>0 & lkwfwm2<=3 & date<137) // Agency
replace seek_method=2 if (lkwfwm2>4 & lkwfwm2<=7 & date>=137) | (lkwfwm2>3 & lkwfwm2<=6 & date<137) // Ad
replace seek_method=3 if (lkwfwm2>7 & lkwfwm2<=8 & date>=137) | (lkwfwm2>6 & lkwfwm2<=7 & date<137) // Direct
replace seek_method=4 if (lkwfwm2>8 & lkwfwm2<=9 & date>=137) | (lkwfwm2>7 & lkwfwm2<=8 & date<137) // Friend/rel
replace seek_method=5 if (lkwfwm2>9 & lkwfwm2<=14 & date>=137) | (lkwfwm2>8 & lkwfwm2<=13 & date<137) //other
replace seek_method=0 if (lkwfwm2==15 & date>=137) | (lkwfwm2==15 & date<137) //not looking
char seek_method[omit] 0

* employment duration with current employer- follows LFS definition
* of EMPLEN up to 5 yrs
gen durats1=. 
label variable durats1 "Employment duration with current employer, 1-8 steps"
replace durats1=empmon1 if ilodefr1==1 & empmon1>=0 // empmon is in terms of months 
replace durats1=1 if ilodefr1==1 & empmon1>=0 & empmon1<=2 /* less than 3 months */
replace durats1=2 if ilodefr1==1 & empmon1>=3 & empmon1<=5 /* 3- 6 months */
replace durats1=3 if ilodefr1==1 & empmon1>=6 & empmon1<=11 /*6-12 months */
replace durats1=4 if ilodefr1==1 & empmon1>=12 & empmon1<=23 /* 1-2 yrs */
replace durats1=5 if ilodefr1==1 & empmon1>=24 & empmon1<=35 /* 2-3 yrs */
replace durats1=6 if ilodefr1==1 & empmon1>=36 & empmon1<=47 /* 3-4 yrs */
replace durats1=7 if ilodefr1==1 & empmon1>=48 & empmon1<=59 /* 4-5 yrs */
replace durats1=8 if ilodefr1==1 & empmon1>=60 /* 5+ years */
char durats1[omit] 8

* whether looking for a job
*gen lookfor1=.
gen lookfor1=0
label variable lookfor1 "Whether looking for a job, 1=yes 0=no"
*replace lookfor1=0 if lkwfwm1== 15 /* not looking */
replace lookfor1=1 if lkwfwm1>0 & lkwfwm1<15 /* looking */
drop lkwfwm*


* whether waiting to takeup job
gen wait =1 if wait2==1
replace wait=0 if wait2==2 |  wait2==-9
label variable wait "Whether waiting to start job, 1=yes 0=no"

/** recession indicator

preserve 
insheet using Data/UKQRecessionIndicator.csv, clear 
sort qtime1
rename qtime1 time1
rename qtime2 time2
gen qtime1= quarterly(time1, "YQ")
gen qtime2= quarterly(time2, "YQ")
format qtime1 %tq
format qtime2 %tq
drop time*
rename qtime1 date
rename qtime2 date2
save UKQRecessionIndicator_2000s, replace 
clear
restore

sort date
merge m:1 date using UKQRecessionIndicator_2000s.dta 
drop if _merge==2
drop _merge
rename gbrrecdm1 recession1
label variable recession1 "Recession during quarter, 1=yes 0=no "
drop gbrrecdm2
erase UKQRecessionIndicator_2000s.dta 
*/

save Data/LFS_2q_5q.dta, replace


		 
