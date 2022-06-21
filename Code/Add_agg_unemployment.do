********************************************************************************
*********************** Add Agg Unemployment Rate  *****************************
********************************************************************************

* Calculate aggregate unemployment rate
use Data/LFS_2q.dta, clear



compress

***Create Aggregate and Regional Unemployment rate from LFS dataset
preserve

tab date uresmc1 [iw=lgwt] if ilodefr1==1, matrow(date) matcol(gov) matcell(E)
tab date uresmc1 [iw=lgwt] if ilodefr1==2, matrow(date) matcol(gov) matcell(U)
tab date uresmc1 [iw=lgwt] if ilodefr1==1 & lookfor1==1, matrow(date) matcol(gov) matcell(Eseeker)
tab date uresmc1 [iw=lgwt] if ilodefr1==1 & ilodefr2==2, matrow(date) matcol(gov) matcell(EU)

matsum U, row(AggreU)
matsum E, row(AggreE)
matrix AggreL=AggreU+AggreE
matewd AggreU AggreL Aggre_Ur
matrix colnames Aggre_Ur=Aggre_Ur



matrix L=U+E
local dl=rowsof(date)
local gl=colsof(gov)
display `dl'
display `gl'
 
**compute if all the parameter are current period
matrix Unemp_r=J(`dl',`gl',0)
matrix Eseeker_r=J(`dl',`gl',0)
matrix Devia_U_r=J(`dl',`gl',0)

forvalues i=1/`dl' {
forvalues j=1/`gl' {
matrix Unemp_r[`i', `j']=U[`i', `j'] / L[`i', `j']
matrix Eseeker_r[`i', `j']=Eseeker[`i', `j'] / E[`i', `j']
matrix Devia_U_r[`i', `j']=Unemp_r[`i', `j']-Aggre_Ur[`i', 1]
}
}

matrix list Unemp_r
matrix colnames date=date

local Eskindex 
local Ustockinx
local Estockinx
local EUinx
local Devia_U_rinx
forvalues inde=1/`gl' {
local Eskindex `Eskindex' Esker`inde'
local Ustockinx `Ustockinx' Ust`inde'
local Estockinx `Estockinx' Est`inde'
local EUinx `EUinx' EU`inde'
local Devia_U_rinx `Devia_U_rinx' Devia_U_r`inde'
}

matrix colnames E= `Estockinx'
matrix colnames Eseeker_r= `Eskindex'
matrix colnames U= `Ustockinx'
matrix colnames EU= `EUinx'
matrix colnames Devia_U_r= `Devia_U_rinx'
matrix Unemp_r=(date, Unemp_r)
matrix Eseeker_r=( Eseeker_r)
matrix U=( U)

matrix all_rate=(Unemp_r, Eseeker_r, U , E, EU, Aggre_Ur, Devia_U_r)
capture erase gov_date_Unemp_r.dta
svmatf , mat(all_rate) fil(gov_date_Unemp_r.dta) 

use gov_date_Unemp_r.dta, clear
drop row
format date %tq
tsset date

** compute if the parameter are across different period
forvalues gov=1/`gl' {
rename c`gov' Urat`gov'
gen U_gw_g`gov'=(Ust`gov'-l.Ust`gov')/l.Ust`gov'
gen lEU_g`gov'=(l.EU`gov')


}

local vars Urat U_gw_g Esker lEU_g Devia_U_r

pause on
pause // wait 15 second and press "q" for continuing the code
pause off

reshape long `vars' , i(date) j(uresmc1)
compress 
save "uresmc_date_Unemp_r.dta", replace


restore

local filenames _2q _5q

foreach filename of local filenames {

use Data/all_variables`filename'.dta , clear


scalar mult_factor = 10000000
file open mult_factor using "Results/mult_factor_`filename'.txt", write replace
file write mult_factor (mult_factor)
file close mult_factor
* sort out weights
gen lgwt_int = lgwt*mult_factor

merge m:1 date uresmc1 using "uresmc_date_Unemp_r.dta", keepusing(`vars')

drop _merge


rename Esker E_seek_rate
rename Urat Urate
gen Aggre_Ur=Urate-Devia_U_r // Aggregate unemployment rate

* make percentage unemployment
gen Aggre_Ur_pct = Aggre_Ur*100
gen Devia_Ur_pct = Devia_U_r*100

preserve
	collapse (mean) Aggre_Ur_pct, by(date)
	tsset date
	quietly twoway (tsline Aggre_Ur_pct)
	graph export Results/Aggre_Ur_pct`filename'.pdf, replace
	export excel using Results/Aggre_Ur_pct`filename', replace
restore 
/*
if `filename'==_5q{
preserve
	collapse (sum) IE, by(date)
	tsset date
	quietly twoway (tsline IE)
	graph export Results/IE`filename'.pdf, replace
restore 
preserve
	collapse (sum) UE, by(date)
	tsset date
	quietly twoway (tsline UE)
	graph export Results/UE`filename'.pdf, replace
restore 

 }*/
 
preserve
	collapse (sum) EE [fw=lgwt_int] if ilodefr1==1 & empmon2>=0 & empmon2<=3 , by(date)
	tsset date
	quietly twoway (tsline EE)
	graph export Results/EE`filename'.pdf, replace
	export excel using Results/EE`filename', replace
restore 
* save data
save Data/regressionData`filename'.dta, replace

}

use Data/regressionData_5q.dta
preserve
	collapse (sum) IEorUE [fw=lgwt_int], by(date)
	tsset date
	quietly twoway (tsline IEorUE)
	graph export Results/IEorUE_5q.pdf, replace
	export excel using Results/IEorUE_5q, replace
restore 
*erase gov_date_Unemp_r.dta 
*erase uresmc_date_Unemp_r.dta
