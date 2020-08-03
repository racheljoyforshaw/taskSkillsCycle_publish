********************************************************************************
*********************** COMBINE ALL DATA INTO ONE ********************************
********************************************************************************

cd Data/
* get a list of all the extracted files
	local extensions _2q _5q
	foreach extension of local extensions {
	filelist, dir(Extracted`extension') pattern(*.dta) save(LFS_datasets`extension'.dta)

	use LFS_datasets`extension'.dta, clear
	local obs=_N
	forvalues i=1/`obs' {
	use LFS_datasets`extension'.dta in `i', clear
	local f = dirname + "/" + filename  
	use "`f'", clear
		* loop through variables, make lowercase
	   foreach v of varlist * {
	   rename `v' `=lower("`v'")'
	   }
	* variable source is name of file
	gen source = "`f'"
	save save`i'
	
}
* append all data together
	use save1.dta
	forvalues i=2/`obs' {
		append using save`i', force
		}
	* save dataset
	save LFS_all_raw`extension'.dta, replace
	clear
	
	* erase rubbish
	erase LFS_datasets`extension'.dta
		forvalues i=1/`obs' {
		erase "save`i'.dta"
		}
}

cd ..
