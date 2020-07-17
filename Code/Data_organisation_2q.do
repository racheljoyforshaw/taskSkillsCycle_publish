********************************************************************************
*********************** DATA CLEANING  *****************************************
********************************************************************************

use Data/LFS_all_raw_2q.dta, clear

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
 publicr* ///
 inecacr* /* -> selfe */ ///
 incac05* /* -> selfe */ ///
 hiqua* /* -> edulevel */ ///
 uresmc* ///
 redylft2 /* -> f_v_retire */  ///
 lkwfwm* /* -> seek_method */ ///

		
****************** define time *************************************************

split source, p("Extracted_2q/") gen(stub)
split stub2, p("_") gen(stib)

*** quarter ***
* ->2009
gen quarter = substr(stib1,1,2)
* 2010s
replace quarter = substr(stib3,1,2) if substr(stib1,1,2)=="tw"
* all together
replace quarter = "q1" if quarter=="ws" | quarter=="jm"
replace quarter = "q2" if quarter=="ss" | quarter=="aj"
replace quarter = "q3" if quarter=="sa" | quarter=="js"
replace quarter = "q4" if quarter=="aw" | quarter=="od"

*** year ***
gen year = substr(stib1,3,2)
* ->2009
replace year = substr(stib1,5,2) if substr(stib1,1,2)=="lg"
replace year = stib2 if year =="" 
* 2010s
replace year = substr(stib3,3,2) if substr(stib1,1,2)=="tw"
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
drop source

* drop any non-2000s data
keep if date>= yq(2000,1) & date<yq(2010,4)


****************** variables ***************************************************

* empmon (months employed)
replace empmon1=. if empmon1==-9 | empmon1==-8
replace empmon2=. if empmon2==-9 | empmon2==-8

* industry
gen industry=inds92m1 if date<=yq(2008,4) & inds92m1!=.
label variable industry "Industry category, 1-21"
replace industry= inds07m1 if date>yq(2008,4) & inds07m1!=.
replace industry=. if industry==-8| industry==-9
drop inds*

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
label variable mar_cohab "Maried/cohabitating, 1=yes, 0=no/na"
replace mar_cohab=1 if (marsta1==2 & marstt1==. ) | ( marsta1==6 & marstt1==.)| (marstt1==2 & marsta1==.) /*married/cohabitating*/
replace mar_cohab=0 if (marsta1==1 | marsta1==3 | marsta1==4 | marsta1==5 | marsta1==7 | marsta1==8 | marsta1==9 ) & marstt1==. /*not married/cohabitating*/
replace mar_cohab=0 if (marstt1==1 | marstt1==3 | marstt1==4 | marstt1==5 ) & marsta1==. /*not married/cohabitating*/
drop marsta* marstt*


* part/full-time work
gen fpt_job1=1 if ftptwk1==1 /*fulltime*/
label variable fpt_job1 "Full-time/part-time job, 1=FT, 0=PT, .=dk/na"
replace fpt_job1=0 if ftptwk1==2 /* parttime*/
replace fpt_job1=. if ftptwk1==-9 |ftptwk1==-8 /* missing */
gen fpt_job2=1 if ftptwk2==1 /*fulltime*/
label variable fpt_job2 "Full-time/part-time job, 1=FT, 0=PT, .=dk/na"
replace fpt_job2=0 if ftptwk2==2 /* parttime*/
replace fpt_job2=. if ftptwk2==-9 |ftptwk2==-8 /* missing */
drop ftptwk*


* temporary 
gen temporary1= 1 if jobtyp1==2 /* temporary */
label variable temporary1 "Temporary/permanent job, 1=T, 0=P, .=dk/na"
replace temporary1= 0 if jobtyp1==1 /* permanent */
replace temporary1=. if jobtyp1==-9 | jobtyp1==-8 /* missing */
gen temporary2= 1 if jobtyp2==2 /* temporary */
label variable temporary2 "Temporary/permanent job, 1=T, 0=P, .=dk/na"
replace temporary2= 0 if jobtyp2==1 /* permanent */
replace temporary2=. if jobtyp2==-9 | jobtyp2==-8 /* missing */
drop jobtyp*


* public/private sector

gen public1 = . if publicr1==-9 | publicr1==-8 /*missing*/
label variable public1 "Public/private job, 1=Pub, 0=Pri, .=dk/na"
replace public1=0 if publicr1==1 /* private */
replace public1=1 if publicr1==2 /* public */
gen public2 = . if publicr2==-9 | publicr2==-8 /*missing*/
label variable public2 "Public/private job, 1=Pub, 0=Pri, .=dk/na"
replace public2=0 if publicr2==1 /* private */
replace public2=1 if publicr2==2 /* public */
drop publicr*


* self-employed or not
gen selfe1=. /*missing*/
label variable selfe1 "Self-employed, 1=Yes, 0=No, .=dk/na"
replace selfe1=0 if inecacr1==1| inecacr1==3 | incac051==1 | incac051==3 /*not self-employed*/
replace selfe1=1 if inecacr1==2 | incac051==2 /*self-employed*/
gen selfe2 =.
label variable selfe2 "Self-employed, 1=Yes, 0=No, .=dk/na"
replace selfe2=0 if inecacr2==1| inecacr2==3 | incac052==1 | incac052==3 /*not self-employed*/
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


* why left last job
gen f_v_retire2=. if (redylft2==-9 | redylft2==-8 ) 
label variable edulevel1 "Why left last job, 1=involuntary, 2=voluntary, 3=other"
replace f_v_retire2=1 if (redylft2==1| redylft2==2| redylft2==3 | redylft2==5) /*involuntary */
replace f_v_retire2=2 if (redylft2==4 | redylft2==8) & date>=yq(1995,1) /*voluntary */
replace f_v_retire2=3 if (redylft2==6 | redylft2==7 | redylft2==9) /*retired, health, other*/
drop redylft*

* methods of seeking job
gen seek_method=.  /*missing*/
label variable seek_method "Methods of seeking job, 1=Agency, 2=Ad, 3=Direct, 4=Friend, 5=Other"
replace seek_method=1 if (lkwfwm2>0 & lkwfwm2<=4 & date>=137) | (lkwfwm2>0 & lkwfwm2<=3 & date<137) // Agency
replace seek_method=2 if (lkwfwm2>4 & lkwfwm2<=7 & date>=137) | (lkwfwm2>3 & lkwfwm2<=6 & date<137) // Ad
replace seek_method=3 if (lkwfwm2>7 & lkwfwm2<=8 & date>=137) | (lkwfwm2>6 & lkwfwm2<=7 & date<137) // Direct
replace seek_method=4 if (lkwfwm2>8 & lkwfwm2<=9 & date>=137) | (lkwfwm2>7 & lkwfwm2<=8 & date<137) // Friend/rel
replace seek_method=5 if (lkwfwm2>9 & lkwfwm2<=14 & date>=137) | (lkwfwm2>8 & lkwfwm2<=13 & date<137) //other
replace seek_method=0 if (lkwfwm2==15 & date>=137) | (lkwfwm2==15 & date<137) //not looking
drop lkwfwm*

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




****************** CHECKED TO HERE *************************************************





*occupation variables

* use the 4 digit SOC where the 1 digit is missing
tostring soc2km1, generate(soc2km1_string)
tostring socmain1, generate(socmain1_string)
tostring soc10m1, generate(soc10m1_string)
replace soc2km1_string="." if soc2km1_string=="-9"|soc2km1_string=="-8"
replace socmain1_string="." if socmain1_string=="-9"|soc2km1_string=="-8"
replace soc10m1_string="." if soc10m1_string=="-9"|soc10m1_string=="-8"
gen socmajm1_string = substr(soc2km1_string,1,1)
replace socmajm1_string = substr(socmain1_string,1,1) if socmajm1_string=="."
replace socmajm1_string = substr(soc10m1_string,1,1) if socmajm1_string=="."
replace socmajm1_string="." if socmajm1_string=="-"
destring socmajm1_string, replace
replace socmajm1 = socmajm1_string if socmajm1==.
replace socmajm1 = . if socmajm1 ==-8 | socmajm1 ==-9
drop socmajm1_string
drop soc2km1_string
drop socmain1_string
drop soc10m1_string

tostring soc2km2, generate(soc2km2_string)
tostring socmain2, generate(socmain2_string)
tostring soc10m2, generate(soc10m2_string)
replace soc2km2_string="." if soc2km2_string=="-9"|soc2km2_string=="-8"
replace socmain2_string="." if socmain2_string=="-9"|soc2km2_string=="-8"
replace soc10m2_string="." if soc10m2_string=="-9"|soc10m2_string=="-8"
gen socmajm2_string = substr(soc2km2_string,1,1)
replace socmajm2_string = substr(socmain2_string,1,1) if socmajm2_string=="."
replace socmajm2_string = substr(soc10m2_string,1,1) if socmajm2_string=="."
replace socmajm2_string="." if socmajm2_string=="-"
destring socmajm2_string, replace
replace socmajm2 = socmajm2_string if socmajm2==.
replace socmajm2 = . if socmajm2 ==-8 | socmajm2 ==-9
drop socmajm2_string
drop soc2km2_string
drop socmain2_string
drop soc10m2_string



* generate an unecessary variable
gen all=99


* variable lookfor *
gen lookfor1=.
replace lookfor1=0 if lkwfwm1== 15
replace lookfor1=1 if lkwfwm1>0 & lkwfwm1<15
replace lookfor1=0 if lkwfwm1==16

* variable edulevel1  1 = HIGH 3=low*

gen edulevel1=. if (hiquap1==-9| hiquap1>=33) & date>yq(1992,4) & date< yq(1996,3)
replace edulevel1=1 if hiquap1>0 & hiquap1<=12 & date>yq(1992,4) & date< yq(1996,3)
replace edulevel1=2 if hiquap1>12 & hiquap1<=31 & date>yq(1992,4) & date< yq(1996,3)
replace edulevel1=3 if hiquap1==32 & date>yq(1992,4) & date< yq(1996,3)

replace edulevel1=. if (hiqual1==-9| hiqual1==-8 |hiqual1==41) & date>yq(1996,1) & date< yq(2004,2)
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


* variable why left last job *
gen f_v_retire2=. if (redylft2==-9 | redylft2==-8 ) & date>=yq(1995,1) & date<=yq(2010,3)
replace f_v_retire2=1 if (redylft2==1| redylft2==2| redylft2==3 | redylft2==5) & date>=yq(1995,1) & date<=yq(2010,3)  /*involuntary */
replace f_v_retire2=2 if (redylft2==4 | redylft2==8) & date>=yq(1995,1) & date<=yq(2010,3) /*voluntary */
replace f_v_retire2=3 if (redylft2==6 | redylft2==7 | redylft2==9) & date>=yq(1995,1) & date<=yq(2010,3)

replace f_v_retire2=. if (redyl112==-9 |redyl112==-8)& date>=yq(2010,4) & date<=yq(2012,4)
replace f_v_retire2=1 if (redyl112==1 |redyl112==2 |redyl112==3 | redyl112==5 )& date>=yq(2010,4) & date<=yq(2012,4) /*involuntary */
replace f_v_retire2=2 if (redyl112==4 | redyl112==8| redyl112==9) & date>=yq(2010,4) & date<=yq(2012,4) /*voluntary */
replace f_v_retire2=3 if (redyl112==10 |redyl112==6|redyl112==7)  & date>=yq(2010,4) & date<=yq(2012,4) /*other reason */

replace f_v_retire2=. if (redyl132==-9 |redyl132==-8)& date>=yq(2013,2) 
replace f_v_retire2=1 if (redyl132==1 |redyl132==2 | redyl132==3 | redyl132==4 | redyl132==6)& date>=yq(2013,2)
replace f_v_retire2=2 if (redyl132==5 | redyl132==9 | redyl132==10) & date>=yq(2013,2) 
replace f_v_retire2=3 if (redyl132==11 | redyl132==7 | redyl132==8) & date>=yq(2013,2) 

* variable part/full-time
gen fpt_job1=1 if ftptwk1==1 /*fulltime*/
replace fpt_job1=0 if ftptwk1==2 /* parttime*/
replace fpt_job1=. if ftptwk1==-9 |ftptwk1==-8 /* missing */
gen fpt_job2=1 if ftptwk2==1 /*fulltime*/
replace fpt_job2=0 if ftptwk2==2 /* parttime*/
replace fpt_job2=. if ftptwk2==-9 |ftptwk2==-8 /* missing */




* create 2d and 3d occupations 
*** soc2010s ***
tostring soc10m1, gen(soc10_string1)
tostring soc10m2, gen(soc10_string2)

	* 2 digit
	* 1st period
	gen soc10_2d_1 = substr(soc10_string1,1,2)
	replace soc10_2d_1 = "." if soc10_2d_1=="-9" | soc10_2d_1=="-8"
	destring soc10_2d_1, replace
	* 2nd period
	gen soc10_2d_2 = substr(soc10_string2,1,2)
	replace soc10_2d_2 = "." if soc10_2d_2=="-9" | soc10_2d_2=="-8"
	destring soc10_2d_2, replace

	* 3 digit
	* 1st period
	gen soc10_3d_1 = substr(soc10_string1,1,3)
	replace soc10_3d_1 = "." if soc10_3d_1=="-9" | soc10_3d_1=="-8"
	destring soc10_3d_1, replace
	* 2nd period
	gen soc10_3d_2 = substr(soc10_string2,1,3)
	replace soc10_3d_2 = "." if soc10_3d_2=="-9" | soc10_3d_2=="-8"
	destring soc10_3d_2, replace

*** soc2000s ***
tostring soc2km1, gen(soc2k_string1)
tostring soc2km2, gen(soc2k_string2)

	* 2 digit
	* 1st period
	gen soc2k_2d_1 = substr(soc2k_string1,1,2)
	replace soc2k_2d_1 = "." if soc2k_2d_1=="-9" | soc2k_2d_1=="-8"
	destring soc2k_2d_1, replace
	* 2nd period
	gen soc2k_2d_2 = substr(soc2k_string2,1,2)
	replace soc2k_2d_2 = "." if soc2k_2d_2=="-9" | soc2k_2d_2=="-8"
	destring soc2k_2d_2, replace

	* 3 digit
	* 1st period
	gen soc2k_3d_1 = substr(soc2k_string1,1,3)
	replace soc2k_3d_1 = "." if soc2k_3d_1=="-9" | soc2k_3d_1=="-8"
	destring soc2k_3d_1, replace
	* 2nd period
	gen soc2k_3d_2 = substr(soc2k_string2,1,3)
	replace soc2k_3d_2 = "." if soc2k_3d_2=="-9" | soc2k_3d_2=="-8"
	destring soc2k_3d_2, replace


*** soc1990s ***
tostring socmain1, gen(soc90_string1)
tostring socmain2, gen(soc90_string2)

	
	* 2 digit
	* 1st period
	gen soc90_2d_1 = substr(soc90_string1,1,2)
	replace soc90_2d_1 = "." if soc90_2d_1=="-9" | soc90_2d_1=="-8"
	destring soc90_2d_1, replace
	* 2nd period
	gen soc90_2d_2 = substr(soc90_string2,1,2)
	replace soc90_2d_2 = "." if soc90_2d_2=="-9" | soc90_2d_2=="-8"
	destring soc90_2d_2, replace


	* 3 digit
	* 1st period
	gen soc90_3d_1 = substr(soc90_string1,1,3)
	replace soc90_3d_1 = "." if soc90_3d_1=="-9" | soc90_3d_1=="-8"
	destring soc90_3d_1, replace
	* 2nd period
	gen soc90_3d_2 = substr(soc90_string2,1,3)
	replace soc90_3d_2 = "." if soc90_3d_2=="-9" | soc90_3d_2=="-8"
	destring soc90_3d_2, replace
	

drop soc10_string1 soc10_string2 soc2k_string1 soc2k_string2 soc90_string1 soc90_string2


*** 1 variable for all time period of 1 digit, 2 digit, 3 digit, 4 digit ***

** 4 digit **
* 1st period
gen soc_4digit_1 = soc10m1 
replace soc_4digit_1 = soc2km1 if date<yq(2011,1) & date> yq(2001,2)
* no 4 digit in 90s
replace soc_4digit_1  = . if date<yq(2001,1)
replace soc_4digit_1 = . if soc_4digit_1==-9|soc_4digit_1==-8
* 2nd period
gen soc_4digit_2 = soc10m2
replace soc_4digit_2 = soc2km2 if date<yq(2011,1) & date> yq(2001,2)
* no 4 digit in 90s
replace soc_4digit_2  = . if date<yq(2001,1)
replace soc_4digit_2 = . if soc_4digit_2==-9|soc_4digit_2==-8

** 3 digit **
* 1st period
gen soc_3digit_1 = soc10_3d_1
replace soc_3digit_1 = soc2k_3d_1 if date<yq(2011,1) & date> yq(2001,2)
replace soc_3digit_1  = soc90_3d_1 if date<yq(2001,1)
replace soc_3digit_1 = . if soc_3digit_1==-9|soc_3digit_1==-8
* 2nd period
gen soc_3digit_2 = soc10_3d_2
replace soc_3digit_2 = soc2k_3d_2 if date<yq(2011,1) & date> yq(2001,2)
replace soc_3digit_2  = soc90_3d_2 if date<yq(2001,1)
replace soc_3digit_2 = . if soc_3digit_2==-9|soc_3digit_2==-8

** 2 digit **
* 1st period
gen soc_2digit_1 = soc10_2d_1
replace soc_2digit_1 = soc2k_2d_1 if date<yq(2011,1) & date> yq(2001,2)
replace soc_2digit_1  = soc90_2d_1 if date<yq(2001,1)
replace soc_2digit_1 = . if soc_2digit_1==-9|soc_2digit_1==-8
* 2nd period
gen soc_2digit_2 = soc10_2d_2
replace soc_2digit_2 = soc2k_2d_2 if date<yq(2011,1) & date> yq(2001,2)
replace soc_2digit_2  = soc90_2d_2 if date<yq(2001,1)
replace soc_2digit_2 = . if soc_2digit_2==-9|soc_2digit_2==-8

** 1 digit **

* 1st period
gen soc_1digit_1 = socmajm1
replace soc_1digit_1 = . if soc_1digit_1==-9|soc_1digit_1==-8
* 2nd period
gen soc_1digit_2 = socmajm2
replace soc_1digit_2 = . if soc_1digit_2==-9|soc_1digit_2==-8

********* Recession Indicator *******************
* OECD recession indicator for UK: data downloaded from FRED

preserve 
insheet using Inputs/UKQRecessionIndicator_2000s.csv, clear /* hard-coded to just 2008 recession as so many `recessions' in FRED data */
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
rename gbrrecdm2 recession2


* reason looking for work (1 = wants to change job, 0= some other reason .= pay - this could be occupation or job specific)

gen look = .
* 1993q1 -> 2007q3
gen lookm11_temp = .
replace lookm11_temp = 1 if lookm11==1| lookm11==2 |lookm11==4|lookm11==5|lookm11==6|lookm11==7 /* job unsatisfactory */
replace lookm11_temp = 0 if lookm11==7 | lookm11==8/*something else */
replace lookm11_temp = . if lookm11==-8| lookm11==-9 |lookm11==3 /* DK,NA and pay unsatisfactory */
replace look = lookm11_temp 
* 2008q1 -> 2010q3
gen lookm811_temp = .
replace lookm811_temp = 1 if lookm811==1| lookm811==2 | lookm811==4|lookm811==5|lookm811==6 |lookm811==7/* job unsatisfactory */
replace lookm811_temp = 0 if lookm811== 8 | lookm811== 9 /*something else */
replace lookm811_temp = . if lookm811==-8| lookm811==-9 |lookm811==3 /* DK,NA and pay unsatisfactory */
replace look = lookm811_temp if date>yq(2007,3) & date<yq(2010,4)
* 2010q4 -> end
gen lokm1111_temp = .
replace lokm1111_temp = 1 if lokm1111==8 | lokm1111==9 | lokm1111==10/* something else */
replace lokm1111_temp = 0 if lokm1111==1 | lokm1111==2 | lokm1111==4 | lokm1111==5 | lokm1111==6 | lokm1111==7 /* job unsatisfactory */
replace lokm1111_temp = . if lokm1111==-8| lokm1111==-9 |lokm1111==3 /* DK,NA and pay unsatisfactory */
replace look = lokm1111_temp if date>yq(2010,3)

drop lookm11_temp lookm811_temp lokm1111_temp 


* whether on the job searching

gen onJobSearch = 0
replace onJobSearch=1 if addjob1==1 | addjob1==2


* create strings for types of flows 
	 
	 forvalues i=1/2{
	 
	 gen q`i'_status ="." 
	 gen q`i'_dummy = .
	 replace q`i'_status ="E" if ilodefr`i'==1
	 replace q`i'_dummy = 1 if ilodefr`i'==1
	 replace q`i'_status = "U" if ilodefr`i'==2
	 replace q`i'_status = "I" if ilodefr`i'==3
	 replace q`i'_dummy = 0 if ilodefr`i'==2 | ilodefr`i'==3
	
}	 
	
gen status = q1_status + q2_status
drop q1_status q2_status



save $my_data_path/LFS_2q.dta, replace
erase UKQRecessionIndicator_2000s.dta 

clear


		 
