********************************************************************************
*********************** Add Agg Unemployment Rate  *****************************
********************************************************************************

* Calculate aggregate unemployment rate
use Data/all_variables_2q.dta, clear


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
merge m:1 date uresmc1 using "uresmc_date_Unemp_r.dta", keepusing(`vars')

drop _merge


rename Esker E_seek_rate
rename Urat Urate
gen Aggre_Ur=Urate-Devia_U_r // Aggregate unemployment rate


* save data
save Data/regressionData_2q.dta, replace


erase gov_date_Unemp_r.dta 
erase uresmc_date_Unemp_r.dta
