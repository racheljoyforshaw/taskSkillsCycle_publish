********************************************************************************
*********************** task & skill distances  ********************************
********************************************************************************

clear

local types CASCOT CASCOT_AGG 

foreach type of local types {

* Bring angSep scores from .csv file

*** SOC2000  ***
insheet using Inputs/angSep_2000_`type'.csv
rename soccode1 soc2km1 
rename soccode2 soc2km2
sort soc2km1 soc2km2
save angSep_2000_`type'.dta, replace
clear

* Bring modOfMod scores from .csv file

*** SOC2000  ***
insheet using Inputs/modOfMod_2000_`type'.csv
rename soccode1 soc2km1 
rename soccode2 soc2km2
sort soc2km1 soc2km2
save modOfMod_2000_`type'.dta, replace
clear

}
			 
*Step 2: Match angSep and modofmod scores to LFS 

local filenames _2q _5q _5q_wages

foreach filename of local filenames {
use $my_data_path/LFS`filename'.dta, clear

foreach type of local types {

*** SOC2000  ***

sort soc2km1 soc2km2
merge m:m soc2km1 soc2km2 using angSep_2000_`type'.dta
drop if _merge==2
drop _merge

merge m:m soc2km1 soc2km2 using modOfMod_2000_`type'.dta
drop if _merge==2
drop _merge


* drop things

drop angSep_2000_`type' modOfMod_2000_`type'

}

save $my_data_path/all_variables`filename'.dta, replace
}

* delete lots of files no longer needed
local measures angSep modOfMod
local decades 2000 
foreach type of local types {
foreach measure of local measures{
foreach decade of local decades{
erase `measure'_`decade'_`type'.dta
}
}
}

clear

