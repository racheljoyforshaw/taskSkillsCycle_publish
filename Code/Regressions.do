********************************************************************************
*********************** REGRESSIONS  *******************************************
********************************************************************************

log using "Results/EstimationLog_18062022.txt", replace
use Data/regressionData_2q_5q.dta, clear
keep if angSep_CASCOT!=. & Aggre_Ur_pct!=. & Devia_Ur_pct!=. & sex!=. & age1!=. & age1_sq!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & Devia_Ur_pct!=. & n_child!=. & lookfor1!=. & jobMover!=. & seek_method!=.


* Exclusion restriction
local exclusion_restriction "wait"

****************************************************
* Double hurdle 
local transitions ALL EE IUE 
foreach trans of local transitions {

if "`trans'" == "ALL"{
local regression_condition_dh "angSep_CASCOT!=. & Aggre_Ur_pct!=.& Devia_Ur_pct!=. & sex!=. & age1!=. & age1_sq & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & n_child!=. & lookfor1!=."
local controls_dh_1 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 temporary1 public1 selfe1 lookfor1 i.edulevel i.uresmc1 i.quarter i.industry"
local controls_dh_2 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry"
local rounding_a = 0 
local rounding_m = 0.000001
}
if "`trans'"== "EE" {
local regression_condition_dh "status=="EE" & angSep_CASCOT!=. & Aggre_Ur_pct!=. & Devia_Ur_pct!=. & sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & n_child!=. & lookfor1!=."
local controls_dh_1 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 temporary1 public1 selfe1 lookfor1 i.edulevel i.uresmc1 i.quarter i.industry"
local controls_dh_2 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry"
local rounding_a = 0
local rounding_m = 0.0000001
}
if "`trans'"== "IUE" {
local regression_condition_dh "(status=="IE" | status=="UE") & angSep_CASCOT!=. & Aggre_Ur_pct!=. & Devia_Ur_pct!=. & sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & n_child!=. & lookfor1!=."
local controls_dh_1 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 temporary1 public1 selfe1 lookfor1 i.edulevel i.uresmc1 i.quarter i.industry"
local controls_dh_2 = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry"
local rounding_a = 0
local rounding_m = 0.000001
}



* create angSep & modOfMod for double hurdle (missing because job stayer must = 0 for inclusion in `above')
capture drop angSep_CASCOT_dh
gen angSep_CASCOT_dh = 0
replace angSep_CASCOT_dh = angSep_CASCOT if angSep_CASCOT!=.
capture drop modOfMod_CASCOT_dh
gen modOfMod_CASCOT_dh = 0
replace modOfMod_CASCOT_dh = modOfMod_CASCOT if modOfMod_CASCOT!=.

* create standardardised angSep
tab angSep_CASCOT_dh if angSep_CASCOT_dh==0 & `regression_condition_dh' /* (3) */
capture drop angSep_CASCOT_stdz_dh
su angSep_CASCOT_dh if `regression_condition_dh'
gen angSep_CASCOT_stdz_dh= ((angSep_CASCOT_dh - r(mean))/r(sd)) + `rounding_a'
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
su angSep_CASCOT_dh if `regression_condition_dh'
local angSep_leftLimit_dh : di %9.7g scalar((0 - r(mean))/r(sd)) + `rounding_a'
su angSep_CASCOT_stdz_dh if `regression_condition_dh'
di `angSep_leftLimit_dh'
tab angSep_CASCOT_stdz_dh if angSep_CASCOT_stdz_dh<=`angSep_leftLimit_dh' & `regression_condition_dh' /* This should be the same number as (3), above*/


* create standardardised modOfMod
tab modOfMod_CASCOT_dh if modOfMod_CASCOT_dh==0 & `regression_condition_dh' /* (3) */
capture drop modOfMod_CASCOT_stdz_dh
su modOfMod_CASCOT_dh if `regression_condition_dh'
gen modOfMod_CASCOT_stdz_dh= ((modOfMod_CASCOT_dh - r(mean))/r(sd)) + `rounding_m'
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
su modOfMod_CASCOT_dh if `regression_condition_dh'
local modOfMod_leftLimit_dh : di %9.7g scalar((0 - r(mean))/r(sd)) + `rounding_m'
su modOfMod_CASCOT_stdz_dh if `regression_condition_dh'
di `modOfMod_leftLimit_dh'
tab modOfMod_CASCOT_stdz_dh if modOfMod_CASCOT_stdz_dh<=`modOfMod_leftLimit_dh' & `regression_condition_dh' /* This should be the same number as (3), above*/



di "`trans'"

* double hurdle
xi: dhreg angSep_CASCOT_stdz_dh `controls_dh_2' if `regression_condition_dh', hd(`controls_dh_1' `exclusion_restriction') millr
eststo angSep_CASCOT_dh_`trans'
gen used_`trans'=e(sample)
*margins, dydx(Aggre_Ur_pct) predict(equation(hurdle)) ALREADY IS MARGINAL EFFECTS!
*margins, dydx(Aggre_Ur_pct) predict(equation(above))


xi: dhreg modOfMod_CASCOT_stdz_dh `controls_dh_2' if `regression_condition_dh', hd(`controls_dh_1' `exclusion_restriction') millr
eststo modOfMod_CASCOT_dh_`trans'



*xi: dblhurdle angSep_CASCOT_stdz_dh `controls_dh_2' [pw=lgwt], ll(`angSep_leftLimit_dh') peq(`controls_dh_1' `heckman_instrument') correlation
*eststo angSep_CASCOT_dh_`tr'

*xi: dhreg modOfMod_CASCOT_stdz_dh `controls_dh_2' if `regression_condition_dh', hd(`controls_dh_1' `heckman_instrument') millr
*eststo modOfMod_CASCOT_dh_`tr'

}




* output to latex file 
		*esttab angSep_tobit_CASCOT_t modOfMod_tobit_CASCOT_t angSep_tobit_CASCOT_AGG modOfMod_tobit_CASCOT_AGG probit_EE angSep_tobit_CASCOT_h modOfMod_tobit_CASCOT_h using Results/tobit_temp_2000s.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		
		esttab angSep_CASCOT_dh_ALL  angSep_CASCOT_dh_EE angSep_CASCOT_dh_IUE modOfMod_CASCOT_dh_ALL modOfMod_CASCOT_dh_EE modOfMod_CASCOT_dh_IUE using Results/dh_temp_ALL.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		b(a2) ///
		addnotes("")  unstack compress keep(Aggre_Ur_pct Devia_Ur_pct _mill n_child lookfor1 sex age1 age1_sq mar_cohab durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover _Iedul* _Iseek_meth_*  _If_v_retir_* `exclusion_restriction')     ///
		scalars ("ll Log llik.") order(Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child _Iedulevel1_1 _Iedulevel1_2 durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover _If_v_retir_1 _If_v_retir_2 _If_v_retir_3 _Iseek_meth_1 _Iseek_meth_2 _Iseek_meth_3 _Iseek_meth_4 _Iseek_meth_5 `exclusion_restriction' _mill )  /// 
		indicate("Quarters=_Iquarter*"  "Regions=_Iuresmc1*" ) varwidth(15) modelwidth(8) coeflabels( Aggre_Ur_pct "Aggregate Unemployment Rate" Devia_Ur_pct "Regional-Aggregate Unemployment Rate" sex "Female" age1 "Age" age1_sq "Age$^2$" mar_cohab "Married/Cohabitating" n_child "Number of Children" _Iedulevel1_1 "High Education" _Iedulevel1_2 "Medium Education" _If_v_retir_1 "Involuntary Separation" _If_v_retir_1 "Voluntary Separation" _If_v_retir_3 "Other" durats1 "Previous Employment Duration" fpt_job1 "Full time, Previous Job" fpt_job2 "Full time, Current Job" temporary1 "Temporary, Previous Job"  temporary2 "Temporary, Current Job" publicr1 "Public, Previous Job" publicr2 "Public, Current Job" selfe1 "Self-employed, Previous Job" selfe2 "Self-employed, Current Job" _Iseek_meth_1 "Method of seeking: Job Centre" _Iseek_meth_2 "Method of seeking: Ads" _Iseek_meth_3 "Method of seeking:Direct application" _Iseek_meth_4 "Method of seeking: Family/Friend" _Iseek_meth_5 "Method of seeking: Other " lookfor1 "Looking for Job" jobMover "Job Mover" `exclusion_restriction' "Wait" _mill "$\lambda$") nonumbers 
	

* Probit	
gen careerChange_angSep = .
replace careerChange_angSep = 0 if jobMover>0
replace careerChange_angSep =1 if angSep_CASCOT >0 & jobMover>0

/*
gen careerChange_1digit = .
replace careerChange_1digit = 0 if jobMover>0
gen temp_1digit_1 = substr(string(soc2km1),1,1)
gen temp_1digit_2 = substr(string(soc2km2),1,1)
replace careerChange_1digit = 1 if temp_1digit_1!=temp_1digit_2 & jobMover>0
replace careerChange_1digit = . if (temp_1digit_1=="-") | (temp_1digit_1==".") |(temp_1digit_2=="-") | (temp_1digit_2==".")
drop temp_1digit_1 temp_1digit_2
gen temp_1digit_1 = substr(string(soc10m1),1,1)
gen temp_1digit_2 = substr(string(soc10m2),1,1)
replace careerChange_1digit = 1 if temp_1digit_1!=temp_1digit_2 & date>yq(2010,4)
replace careerChange_1digit = . if ((temp_1digit_1=="-") | (temp_1digit_1==".") |(temp_1digit_2=="-") | (temp_1digit_2==".") )& date>yq(2010,4)
*/

local controls_p = "Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry "

*ALL
local regression_condition_p "angSep_CASCOT!=. & Aggre_Ur_pct!=. & sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & quarter!=. & f_v_retire2!=. & industry!=.  & Devia_Ur_pct!=. & n_child!=. & lookfor1!=."
xi: probit careerChange_angSep `controls_p' if `regression_condition_p', vce(robust)
eststo angSep_p_CASCOT_ALL


* output to latex file 
		*esttab angSep_tobit_CASCOT_t modOfMod_tobit_CASCOT_t angSep_tobit_CASCOT_AGG modOfMod_tobit_CASCOT_AGG probit_EE angSep_tobit_CASCOT_h modOfMod_tobit_CASCOT_h using Results/tobit_temp_2000s.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		
		esttab angSep_p_CASCOT_ALL using Results/probit_temp_ALL.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		b(a2) ///
		addnotes("")  unstack compress keep(Aggre_Ur_pct Devia_Ur_pct n_child lookfor1 sex age1 age1_sq mar_cohab durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover _Iedul* _Iseek_meth_*  _If_v_retir_* `exclusion_restriction')     ///
		scalars ("ll Log llik.") order(Aggre_Ur_pct Devia_Ur_pct sex age1 age1_sq mar_cohab n_child _Iedulevel1_1 _Iedulevel1_2 durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 lookfor1 jobMover _If_v_retir_1 _If_v_retir_2 _If_v_retir_3 _Iseek_meth_1 _Iseek_meth_2 _Iseek_meth_3 _Iseek_meth_4 _Iseek_meth_5 `exclusion_restriction' _mill )  /// 
		indicate("Quarters=_Iquarter*"  "Regions=_Iuresmc1*" ) varwidth(15) modelwidth(8) coeflabels( Aggre_Ur_pct "Aggregate Unemployment Rate" Devia_Ur_pct "Regional-Aggregate Unemployment Rate" sex "Female" age1 "Age" age1_sq "Age$^2$" mar_cohab "Married/Cohabitating" n_child "Number of Children" _Iedulevel1_1 "High Education" _Iedulevel1_2 "Medium Education" _If_v_retir_1 "Involuntary Separation" _If_v_retir_1 "Voluntary Separation" _If_v_retir_3 "Other" durats1 "Previous Employment Duration" fpt_job1 "Full time, Previous Job" fpt_job2 "Full time, Current Job" temporary1 "Temporary, Previous Job"  temporary2 "Temporary, Current Job" publicr1 "Public, Previous Job" publicr2 "Public, Current Job" selfe1 "Self-employed, Previous Job" selfe2 "Self-employed, Current Job" _Iseek_meth_1 "Method of seeking: Job Centre" _Iseek_meth_2 "Method of seeking: Ads" _Iseek_meth_3 "Method of seeking:Direct application" _Iseek_meth_4 "Method of seeking: Family/Friend" _Iseek_meth_5 "Method of seeking: Other " lookfor1 "Looking for Job" jobMover "Job Mover") nonumbers 


*estimates clear
*shell $my_python_path Code/get_pseudor2.py
*shell $my_python_path Code/formatTobitResults_2000s.py
*erase Results/tobit_temp_2000s.tex
log close



