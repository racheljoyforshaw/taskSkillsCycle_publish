/***********************************************************
**Table 7: Real wage changes by the percentile
************************************************************/

clear all
set more off
capture: set memory 500m
*use all_variables_5q_wages, clear
use $my_data_path/all_variables_5q_wages.dta, clear

scalar mult_factor = 10000000
* sort out weights
gen lgwt_int = lgwt*mult_factor



*** Dummies for the channels of transition
**UE transition 
 label variable EUE "Dummy of Transition via Unemployment"
 label define EUE 0 "Not via EUE" 1 "Transition via Unemployment" 
 label values EUE EUE
**IE transition
 label variable EIE "Dummy of Transition via Inactive"
 label define EIE 0 "Not via EIE" 1 "Transition via Inactive" 
 label values EIE EIE
 
  **UE or IE transition
 label variable EUIE "Dummy of Transition via Unemployment or Inactive transition"
 label define EUIE 0 "Not via EUIE" 1 "Transition via Unemployment or Inactive" 
 label values EUIE EUIE

 **Job to Job transition
 label variable EEE "Dummy of Transition via Job to Job transition"
 label define EEE 0 "Not via EEE" 1 "Transition via Job to Job transition" 
 label values EEE EEE

 
** Since Labour force survey uses negative value, -8 or-9, to denote "missing" and "is not applied", we change them into "." to avoid potential mistake. 

  local wage_vars  netwk1 netwk5 grsswk1 grsswk5 jobtyp1 jobtyp5
  foreach wage_var of local wage_vars {
  replace `wage_var'=. if `wage_var'<0
  }
  

**Drop the transition which we do not have informaiton
	drop if (EUE==.) | (EIE==.) | (EEE==.) | (EUIE==.) 
	

gen seek_method=. // methods of seeking job
replace seek_method=1 if (lkwfwm2>0 & lkwfwm2<=4 & date>=137) | (lkwfwm2>0 & lkwfwm2<=3 & date<137)
replace seek_method=2 if (lkwfwm2>4 & lkwfwm2<=7 & date>=137) | (lkwfwm2>3 & lkwfwm2<=6 & date<137)
replace seek_method=3 if (lkwfwm2>7 & lkwfwm2<=8 & date>=137) | (lkwfwm2>6 & lkwfwm2<=7 & date<137)
replace seek_method=4 if (lkwfwm2>8 & lkwfwm2<=9 & date>=137) | (lkwfwm2>7 & lkwfwm2<=8 & date<137)
replace seek_method=5 if (lkwfwm2>9 & lkwfwm2<=14 & date>=137) | (lkwfwm2>8 & lkwfwm2<=13 & date<137)
replace seek_method=0 if (lkwfwm2==15 & date>=137) | (lkwfwm2==15 & date<137)
drop if seek_method==.
  
**Import the CPI data in order to obtain "real wage" from "nominal wage"
  
**for the CPI corresponding initial/previous wage
merge m:1 date using Inputs/CPI_uk_base_2015.dta , keepusing(cpi) 
 drop if _merge!=3
 drop _merge
 rename cpi CPI_start
 replace CPI_start=CPI_start/100
 rename date date_start

 **for the CPI corresponding current wage
gen date=date_start+4
merge m:1 date using Inputs/CPI_uk_base_2015.dta , keepusing(cpi) 
 rename cpi CPI_end
  replace CPI_end=CPI_end/100
  rename date date_end
  drop if _merge!=3
 drop _merge
 
 
 * Keep the 2000s only
destring year, replace
keep if year>1999 & year<=2010
tab year

**Generate the data of real wage
* earn less than min wage (262.5 = £7.5 * 35 hours, full time)
*drop if grsswk1<262.5 & ftptwk1==1
*drop if grsswk5<262.5 & ftptwk5==1

* condition on non-missing
*drop if angSep_CASCOT==. | modOfMod_CASCOT==.
drop if sex==.
drop if age1==.

gen mar_cohab=. // Marriage status
replace mar_cohab=1 if (marsta1==2 & marstt1==. ) | ( marsta1==6 & marstt1==.)| (marstt1==2 & marsta1==.)
replace mar_cohab=0 if (marsta1==1 | marsta1==3 | marsta1==4 | marsta1==5 | marsta1==7 | marsta1==8 | marsta1==9 ) & marstt1==.
replace mar_cohab=0 if (marstt1==1 | marstt1==3 | marstt1==4 | marstt1==5 ) & marsta1==.
drop if mar_cohab==.

gen durats1=. // the employment duration with current employer
replace durats1=empmon1 if ilodefr1==1 & empmon1>=0 // empmon is in terms of months 

replace durats1=1 if ilodefr1==1 & empmon1>=0 & empmon1<=2
replace durats1=2 if ilodefr1==1 & empmon1>=3 & empmon1<=5
replace durats1=3 if ilodefr1==1 & empmon1>=6 & empmon1<=11
replace durats1=4 if ilodefr1==1 & empmon1>=12 & empmon1<=23
replace durats1=5 if ilodefr1==1 & empmon1>=24 & empmon1<=35
replace durats1=6 if ilodefr1==1 & empmon1>=36 & empmon1<=47
replace durats1=7 if ilodefr1==1 & empmon1>=48 & empmon1<=59
replace durats1=8 if ilodefr1==1 & empmon1>=60 

drop if durats1==.

gen durats5=. // the employment duration with current employer
replace durats5=empmon1 if ilodefr1==1 & empmon1>=0 // empmon is in terms of months 

replace durats5=1 if ilodefr1==1 & empmon1>=0 & empmon1<=2
replace durats5=2 if ilodefr1==1 & empmon1>=3 & empmon1<=5
replace durats5=3 if ilodefr1==1 & empmon1>=6 & empmon1<=11
replace durats5=4 if ilodefr1==1 & empmon1>=12 & empmon1<=23
replace durats5=5 if ilodefr1==1 & empmon1>=24 & empmon1<=35
replace durats5=6 if ilodefr1==1 & empmon1>=36 & empmon1<=47
replace durats5=7 if ilodefr1==1 & empmon1>=48 & empmon1<=59
replace durats5=8 if ilodefr1==1 & empmon1>=60 

drop if durats5==.



* variable part/full-time
gen fpt_job1=1 if ftptwk1==1 /*fulltime*/
replace fpt_job1=0 if ftptwk1==2 /* parttime*/
replace fpt_job1=. if ftptwk1==-9 |ftptwk1==-8 /* missing */

gen fpt_job5=1 if ftptwk5==1 /*fulltime*/
replace fpt_job5=0 if ftptwk5==2 /* parttime*/
replace fpt_job5=. if ftptwk5==-9 |ftptwk5==-8 /* missing */

drop if fpt_job1==. | fpt_job5==.

drop if jobtyp1==. | jobtyp5==.

drop if publicr1<0 | publicr5<0

* self-employed or not
gen selfe1=.
replace selfe1=0 if inecacr1==1| inecacr1==3 | incac051==1 | incac051==3
replace selfe1=1 if inecacr1==2 | incac051==2

gen selfe5 =.
replace selfe5=0 if inecacr5==1| inecacr5==3 | incac055==1 | incac055==3
replace selfe5=1 if inecacr5==2 | incac055==2

drop if selfe1==. | selfe5==.

*drop if edulevel
* i.f_v_retire2



* full-time in both only
*drop if ftptwk1!=1 & ftptwk5!=1

* permanent in both only
*drop if jobtyp1!=1 & jobtyp5!=1

* private in both only
*drop if publicr1 & publicr5!=1


 gen rl_grsswk_start=grsswk1/CPI_start
 label variable rl_grsswk_start "real gross wage for previous job"
 gen rl_grsswk_end= grsswk5/CPI_end
 label variable rl_grsswk_end "real gross wage for current job"
	 
	 
	**Generate the data of the difference between previous wage and current wage
  gen rl_diff_grsswk=rl_grsswk_end-rl_grsswk_start
  label variable rl_diff_grsswk "real gross wage for current job"

   gen rl_gw_grwwwk=(rl_grsswk_end-rl_grsswk_start)/rl_grsswk_start // wage growth rate in real term
      label variable rl_gw_grwwwk "real gross wage growth rate "


local majvars rl_gw_grwwwk

			  local colnums=0
			  foreach counts of local majvars {
			  local colnums=`colnums'+1
			  }

cd Results	 

local begin_q=yq(1997,1)
local begin_q1=`begin_q'+1
local end_q=yq(2017,4)

local cases all upskill downskill unchanged
foreach case of local cases {

if "`case'"=="all" {
local filename all_worker
local mov_cond " & modOfMod_CASCOT!=."
}
else if "`case'"=="upskill" {
local filename upskill
local mov_cond "& modOfMod_CASCOT>0 & modOfMod_CASCOT!=."
}
else if "`case'"=="downskill" {
local filename downskill
local mov_cond "& modOfMod_CASCOT<0 & modOfMod_CASCOT!=."
}
else if "`case'"=="unchanged" {
local filename unchanged
local mov_cond "& modOfMod_CASCOT==0 & modOfMod_CASCOT!=."
}
else {
}




*************************************************************************************
**In this section, we will calculate the statistics for all workers, new hires by EEE, EUE and EIE channels.
*************************************************************************************


	**Set conditions 
*****************************************
local job_con "  lgwt_int!=."
*****************************************
local statistics p10 p25 p50 p75 p90 

matrix dis_gw_grs_`case'=J(1,7,.)


forvalues qn=`begin_q1'/`end_q' {
*****************************************
sum  `majvars'  [fw=lgwt_int] if `job_con' `mov_cond' & date_start==`qn', detail
local p10= r(p10)
local p25= r(p25)
local p50= r(p50)
local p75= r(p75)
local p90= r(p90)
local obs=r(N)/lgwt_int

display `qn'
matrix dis_gw_grs_`case' =( dis_gw_grs_`case' \ `qn', `p10', `p25', `p50', `p75' ,`p90' , `obs' )

}
matrix colnames dis_gw_grs_`case' = date p10_`filename'  p25_`filename'  p50_`filename'  p75_`filename'  p90_`filename'  obs_`filename' 
matrix list dis_gw_grs_`case'
****************************************


** for the workers who were hired through EUE, EIE or EEE respectively in all period
	local options U I E //
foreach option of local options {

matrix dis_gw_grs_`case'_E`option'E=J(1,7,.)

forvalues qn=`begin_q1'/`end_q' {
sum  `majvars'  [fw=lgwt_int] if  E`option'E==1 &  `job_con'  `mov_cond' & date_start==`qn' , detail
local p10= r(p10)
local p25= r(p25)
local p50= r(p50)
local p75= r(p75)
local p90= r(p90)
local obs=r(N)/lgwt_int

matrix dis_gw_grs_`case'_E`option'E =(dis_gw_grs_`case'_E`option'E \ `qn', `p10', `p25', `p50', `p75' ,`p90', `obs')

}

matrix colnames dis_gw_grs_`case'_E`option'E = date p10_`filename' p25_`filename' p50_`filename' p75_`filename' p90_`filename' obs_`filename'
matrix list dis_gw_grs_`case'_E`option'E 

 ** the following } is for options
}

	** the following } is for case
}

*********************************************************************
*Final STEPT: Convert the matrix we built into .xml file which can open with Excel.
*********************************************************************
	local options U I E //
foreach option of local options {

matrix dis_gw_grs_modOfMod_E`option'E_ms= (dis_gw_grs_upskill_E`option'E, dis_gw_grs_downskill_E`option'E[1...,2...], dis_gw_grs_unchanged_E`option'E[1...,2...])
matrix dis_gw_grs_modOfMod_E`option'E_ms=dis_gw_grs_modOfMod_E`option'E_ms[2...,1...] // eliminate the first "." row


	**Set the file names
	if "`option'"=="E" {
	local channels EE
	}
	else {
	local channels E`option'E
	}

	**Create the excel files
	local types modOfMod
	foreach type of local types {
		preserve
		clear
  svmat dis_gw_grs_`type'_E`option'E_ms , names(col)

format date %tq
gen str datestr = string( date, "%tq")


mkmat p10_upskill-obs_unchanged , matrix(all_data) rownames(datestr)

xml_tab all_data , save("`type'_wage_distribution_by_channels_skills.xml") append  sheet("`channels'") notes( "Note: The missing value indicates the data unavailabile." )

restore

}

}

*****************************************************
**For all mover and stayer, no matter the channels of transition
*****************************************************	
	**No matter the channels of transition.
matrix dis_gw_grs_modOfMod_ms= (dis_gw_grs_upskill, dis_gw_grs_downskill[1...,2...], dis_gw_grs_unchanged[1...,2...])
matrix dis_gw_grs_modOfMod_ms=dis_gw_grs_modOfMod_ms[2...,1...] // eliminate the first "." row
	local types modOfMod
	foreach type of local types {
	preserve
		clear
  svmat dis_gw_grs_`type'_ms , names(col)

format date %tq
gen str datestr = string( date, "%tq")


mkmat p10_upskill-obs_unchanged , matrix(all_data) rownames(datestr)


xml_tab all_data , save("`type'_wage_distribution_by_channels_skills.xml") append  sheet("all_workers") notes( "Note: The missing value indicates the data unavailabile." )

restore
}
	
cd ..
	
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Use the data provided by this code. Take average of the corresponding series, then We can establish Table 5 by simple operation.
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
