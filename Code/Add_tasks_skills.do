********************************************************************************
*********************** Task & Skill distances  ********************************
********************************************************************************

clear

local types CASCOT CASCOT_AGG 

foreach type of local types {

* Bring angSep scores from .csv file

*** SOC2000  ***
insheet using Data/angSep_2000_`type'.csv
rename soccode1 soc2km1 
rename soccode2 soc2km2
sort soc2km1 soc2km2
rename angsep angSep_2000_`type'
save angSep_2000_`type'.dta, replace
clear

*** SOC2010 ***

insheet using Data/angSep_2010_`type'.csv
rename soccode1 soc10m1 
rename soccode2 soc10m2
sort soc10m1 soc10m2
rename angsep angSep_2010_`type'
save angSep_2010_`type'.dta, replace
clear


* Bring modOfMod scores from .csv file

*** SOC2000  ***
insheet using Data/modOfMod_2000_`type'.csv
rename soccode1 soc2km1 
rename soccode2 soc2km2
sort soc2km1 soc2km2
rename modofmod modOfMod_2000_`type'
save modOfMod_2000_`type'.dta, replace
clear

*** SOC2010  ***

insheet using Data/modOfMod_2010_`type'.csv
rename soccode1 soc10m1 
rename soccode2 soc10m2
sort soc10m1 soc10m2
rename modofmod modOfMod_2010_`type'
save modOfMod_2010_`type'.dta, replace
clear


}
			 
*Step 2: Match angSep and modofMod scores to LFS 

local filenames _2q _5q

foreach filename of local filenames {
use Data/LFS`filename'.dta, clear

foreach type of local types {

*** SOC2000  ***

sort soc2km1 soc2km2
merge m:m soc2km1 soc2km2 using angSep_2000_`type'.dta
drop if _merge==2
drop _merge

merge m:m soc2km1 soc2km2 using modOfMod_2000_`type'.dta
drop if _merge==2
drop _merge

*** SOC2010  ***

sort soc10m1 soc10m2
merge m:m soc10m1 soc10m2 using angSep_2010_`type'.dta
drop if _merge==2
drop _merge

merge m:m soc10m1 soc10m2 using modOfMod_2010_`type'.dta
drop if _merge==2
drop _merge


* make just one angSep & modofmod variable

*gen angSep_`type' = angSep_90_`type'
*replace angSep_`type' = angSep_2000_`type' if date> yq(2001,3)
gen angSep_`type' = angSep_2000_`type' if date> yq(1999,4) & date<=yq(2010,4)
replace angSep_`type' = angSep_2010_`type' if date> yq(2010,4)
*replace angSep_raw = angSep_2000_2010 if date== yq(2010,4)
*replace angSep_`type' = . if date==yq(2010,4)



*gen modOfMod_`type' = modOfMod_90_`type'
*replace modOfMod_`type' = modOfMod_2000_`type' if date> yq(2001,3)
gen modOfMod_`type' = modOfMod_2000_`type' if date> yq(1999,4) & date<=yq(2010,4)
replace modOfMod_`type' = modOfMod_2010_`type' if date> yq(2010,4)
*create absolute mod
replace modOfMod_`type' = abs(modOfMod_`type')


*get rid of spurious transitions
*drop if jobMover==0 & angSep_`type'!=0
*drop if jobMover==0 & modOfMod_`type'!=0
*replace angSep_`type' = 0 if jobMover==0 & angSep_`type'!=0
*replace modOfMod_`type' = 0 if jobMover==0 & modOfMod_`type'!=0

* graphs

preserve
	collapse (mean) angSep_CASCOT if angSep_CASCOT!=. & empmon2<=3 & status=="EE" [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline angSep_CASCOT)
	graph export Results/angSep_`type'`filename'_EE.pdf, replace
	export excel using Results/angSep_CASCOT_`filename'_EE, replace
restore


if "`filename'" == "_5q" {


preserve
	collapse (mean) angSep_CASCOT if angSep_CASCOT!=. & empmon2<=3 & (status=="IE" | status=="UE") [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline angSep_CASCOT)
	graph export Results/angSep_`type'`filename'_IEUE.pdf, replace
	export excel using Results/angSep_CASCOT_`filename'_IEUE, replace

restore

/*preserve
	collapse (mean) angSep_CASCOT if angSep_CASCOT!=. & empmon2<=3 & status=="UE" [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline angSep_CASCOT)
	graph export Results/angSep_`type'`filename'_UE.pdf, replace
	export excel using Results/angSep_CASCOT_`filename'_UE, replace
restore
*/
}

preserve
	collapse (mean) modOfMod_CASCOT if modOfMod_CASCOT!=. & empmon2<=3 & status=="EE" [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline modOfMod_CASCOT)
	graph export Results/modOfMod_`type'`filename'_EE.pdf, replace
	export excel using Results/modOfMod_CASCOT_`filename'_EE, replace
restore

if "`filename'" == "_5q" {
preserve
	collapse (mean) modOfMod_CASCOT if modOfMod_CASCOT!=. & empmon2<=3 & (status=="IE" | status=="UE") [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline modOfMod_CASCOT)
	graph export Results/modOfMod_`type'`filename'_IEUE.pdf, replace
	export excel using Results/modOfMod_CASCOT_`filename'_IEUE, replace
restore
/*
preserve
	collapse (mean) modOfMod_CASCOT if modOfMod_CASCOT!=. & empmon2<=3 & status=="UE" [pw=lgwt], by(date)
	tsset date
	quietly twoway (tsline modOfMod_CASCOT)
	graph export Results/modOfMod_`type'`filename'_UE.pdf, replace
		export excel using Results/modOfMod_CASCOT_`filename'_UE, replace
restore
*/
}
}

save Data/all_variables`filename'.dta, replace
}

* delete lots of files no longer needed
local measures angSep modOfMod
local decades 2000 2010
foreach type of local types {
foreach measure of local measures{
foreach decade of local decades{
erase `measure'_`decade'_`type'.dta
}
}
}



clear

