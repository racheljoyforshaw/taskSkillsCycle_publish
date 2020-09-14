********************************************************************************
*********************** DATA CLEANING  *****************************************
********************************************************************************

use Data/LFS_all_raw_5q.dta, clear

******************  keep only these variables needed ***************************
 
keep lgwt ///
 ilodefr* ///
 source* /* -> date */ ///
 grsswk* /* -> wages */ ///
 hiqual* /* -> edulevel */ ///
 soc2km* /* -> socCode */ ///
 age* ///
 sex ///
 publicr* ///
 ftptwk* /* fpt_job1 */ ///
 jobtyp* ///
 lkwfwm* ///
 marsta* ///
 marstt1* ///
 inecacr* ///
 incac05* ///
 empmon* /* months employed */
 

		
****************** define time *************************************************

split source, p("Extracted_5q/") gen(stub)
split stub2, p("_") gen(stib)
split stib1, p("/") gen(stob)

*** quarter ***
gen quarter = substr(stob3,1,2)

*** year ***
gen year = substr(stob3,3,2)
replace year = stib2 if year==""
* format the year
replace year = "20" + year


* all together
gen date= year+quarter
gen qtime= quarterly(date, "YQ")
format qtime %tq
drop date
rename qtime date
drop stib*
drop stub*
drop stob*
drop source

* drop any non-2000s data
keep if date>= yq(2000,1) & date<yq(2010,4)


****************** variables ***************************************************
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
drop hiqual*
char edulevel1[omit] 3

* age - drop u-16s o-64s
drop if age1>64 | age1>64
drop if age1<16 | age1<16

* create age squared
gen age1_sq= age1*age1
label variable age1_sq "Age squared"

* empmon (months employed)
replace empmon1=. if empmon1==-9 | empmon1==-8

* part/full-time work
gen fpt_job1=1 if ftptwk1==1 /*fulltime*/
label variable fpt_job1 "Full-time, 1=yes, 0=no"
replace fpt_job1=0 if ftptwk1==2 /* parttime*/
gen fpt_job5=1 if ftptwk5==1 /*fulltime*/
label variable fpt_job5 "Full-time, 1=yes, 0=no"
replace fpt_job5=0 if ftptwk5==2 /* parttime*/
drop ftptwk*


* create strings for types of flows 
	 
	 forvalues i=1/5{
	 
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
	
gen status = q1_status + q2_status + q3_status + q4_status + q5_status


* get rid of missing transitions

drop if strpos(status, ".")!=0


* create transition dummies

forvalues i=1/5{
replace empmon`i' = . if empmon`i'==-8 | empmon`i'==-9
}

gen EEE = 0
replace EEE = 1 if status=="EEEEE" & empmon5<=12
gen EUE = 0 
replace EUE = 1 if status=="EEEUE" | status=="EEUEE" | status=="EEUUE" | status=="EUEEE"| status=="EUUEE" | status=="EUUUE" & empmon5<=12
gen EIE = 0 
replace EIE = 1 if status=="EEEIE" | status=="EEIEE" | status=="EEIIE" | status=="EIEEE"| status=="EIIEE" | status=="EIIIE" & empmon5<=12
gen EUIE = 0
replace EUIE =1 if EUE ==1 | EIE==1

gen EEE_stayers = 0
replace EEE_stayers = 1 if status=="EEEEE" & empmon5>12


* public/private sector


gen public1 =0
label variable public1 "Public job, 1=Yes, 0=No"
replace public1=0 if publicr1==1 /* private */
replace public1=1 if publicr1==2 /* public */
gen public5 = . if publicr5==-9 | publicr5==-8 /*missing*/
label variable public5 "Public job, 1=Yes, 0=No"
replace public5=0 if publicr5==1 /* private */
replace public5=1 if publicr5==2 /* public */
drop publicr*


save Data/LFS_5q.dta, replace

/*
****************** variables ***************************************************

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
drop hiqual*
char edulevel1[omit] 3


* why left last job
gen f_v_retire2=. if (redylft2==-9 | redylft2==-8 ) 
label variable edulevel1 "Why left last job, 1=involuntary, 2=voluntary, 3=other"
replace f_v_retire2=1 if (redylft2==1| redylft2==2| redylft2==3 | redylft2==5) /*involuntary */
replace f_v_retire2=2 if (redylft2==4 | redylft2==8) & date>=yq(1995,1) /*voluntary */
replace f_v_retire2=3 if (redylft2==6 | redylft2==7 | redylft2==9) /*retired, health, other*/
drop redylft*
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


* recession indicator

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

save Data/LFS_2q.dta, replace


		 
