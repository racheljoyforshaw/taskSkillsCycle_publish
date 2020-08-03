********************************************************************************
*********************** REGRESSIONS  *******************************************
********************************************************************************

*log using "Results/EstimationLog.txt", replace
use Data/regressionData_2q, clear

*********************************************************************************************************************************************************
* Create Independent Variables

* create dummy for job change
gen EE = .
replace EE = 0 if ilodefr1==1 & ilodefr2==1 /* job stayers */
replace EE = 1 if ilodefr1==1 & ilodefr2==1 & empmon2>=0 & empmon2<=2  /* job movers */

* make percentage unemployment
gen Aggre_Ur_pct = Aggre_Ur*100


* age squared
replace age1_sq = age1_sq/1000

* take absolute value of skill change
replace modOfMod_CASCOT = abs(modOfMod_CASCOT)
*********************************************************************************************************************************************************
* Dependent Variables & Controls

* conditions to create standardised $\Delta$ tasks and $\Delta$ skills
* simple
local regression_condition_s "angSep_CASCOT!=. & ilodefr1==1 & ilodefr2==1 & empmon2>=0 & empmon2<=2"

* create standardardised angSep
tab angSep_CASCOT if angSep_CASCOT==0 & `regression_condition_s' /* (1) */
scalar N_lc = r(N)
su angSep_CASCOT if `regression_condition_s'
scalar N_unc = r(N)
* write APE to txt file
scalar angSep_APE_s = 1 - (N_lc/(N_unc))
di angSep_APE_s
file open APEfactor_angSep_CASCOT using "Results/APEfactor_angSep_CASCOT.txt", write replace
file write APEfactor_angSep_CASCOT (round(angSep_APE_s,0.01))
file close APEfactor_angSep_CASCOT
gen angSep_CASCOT_stdz_s= ((angSep_CASCOT - r(mean))/r(sd))
* save mean to txt file		
local angSep_s_mean: di %9.2g round(scalar(r(mean)),0.01)
file open angSep_s_mean using "Results/angSep_s_mean.txt", write replace
file write angSep_s_mean (`angSep_s_mean')
file close angSep_s_mean
* save sd to txt file		
local angSep_s_sd: di %9.2g round(scalar(r(sd)),0.01)
file open angSep_s_sd using "Results/angSep_s_sd.txt", write replace
file write angSep_s_sd (`angSep_s_sd')
file close angSep_s_sd
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local angSep_leftLimit_s: di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
di `angSep_leftLimit_s'
tab angSep_CASCOT_stdz_s if angSep_CASCOT_stdz_s<=`angSep_leftLimit_s' & `regression_condition_s' /* This should be the same number as (1), above*/

						

* create standardised abs(modOfMod)
tab modOfMod_CASCOT if modOfMod_CASCOT==0 & `regression_condition_s' /* (2) */
scalar N_lc = r(N)
su modOfMod_CASCOT if `regression_condition_s'
scalar N_unc = r(N)
* write APE to txt file
scalar modOfMod_APE_s = 1 - (N_lc/(N_unc))
di modOfMod_APE_s
file open APEfactor_modOfMod_CASCOT using "Results/APEfactor_modOfMod_CASCOT.txt", write replace
file write APEfactor_modOfMod_CASCOT (round(modOfMod_APE_s,0.01))
file close APEfactor_modOfMod_CASCOT
gen modOfMod_CASCOT_stdz_s = ((modOfMod_CASCOT - r(mean))/r(sd))
local modOfMod_s_sd: di %9.2g round(scalar(r(sd)),0.01)
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local modOfMod_leftLimit_s: di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
di `modOfMod_leftLimit_s'
tab modOfMod_CASCOT_stdz_s if modOfMod_CASCOT_stdz_s<=`modOfMod_leftLimit_s' & `regression_condition_s'  /* This should be the same number as (1) and (2), above*/

*********************************************************************************************************************************************************


* Double hurdle

local regression_condition_dh "sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & temporary1!=. & public1!=. & selfe1!=. & edulevel!=. & uresmc1!=. & f_v_retire2!=. & quarter!="." & industry!=. & ilodefr1==1 & ilodefr2==1" 

* first step - probit with all EE movers and stayers
local controls_dh_1 = "Aggre_Ur_pct sex age1 age1_sq mar_cohab durats1 fpt_job1 temporary1 public1 selfe1 i.edulevel i.uresmc1 i.quarter i.industry"

* second step - tobit with all EE movers and stayers
local controls_dh_2 = "Aggre_Ur_pct sex age1 age1_sq mar_cohab durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry"

* create angSep & modOfMod for double hurdle (missing because job stayer must = 0 for inclusion in `above')
gen angSep_CASCOT_dh = 0
replace angSep_CASCOT_dh = angSep_CASCOT if angSep_CASCOT!=.
gen modOfMod_CASCOT_dh = 0
replace modOfMod_CASCOT_dh = modOfMod_CASCOT if modOfMod_CASCOT!=.

* create standardardised angSep
tab angSep_CASCOT_dh if angSep_CASCOT_dh==0 & `regression_condition_dh' /* (3') */
scalar N_lc = r(N)
su angSep_CASCOT_dh if `regression_condition_dh'
scalar N_unc = r(N)
* write APE to txt file
scalar angSep_APE_dh = 1 - (N_lc/(N_unc))
di angSep_APE_dh
file open APEfactor_angSep_CASCOT_dh using "Results/APEfactor_angSep_CASCOT_dh.txt", write replace
file write APEfactor_angSep_CASCOT_dh (round(angSep_APE_dh,0.01))
file close APEfactor_angSep_CASCOT_dh
gen angSep_CASCOT_stdz_dh= ((angSep_CASCOT_dh - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local angSep_leftLimit_dh : di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su angSep_CASCOT_stdz_dh if `regression_condition_dh'
di `angSep_leftLimit_dh'
tab angSep_CASCOT_stdz_dh if angSep_CASCOT_stdz_dh<=`angSep_leftLimit_dh' & `regression_condition_dh' /* This should be the same number as (3'), above*/

* create standardised abs(modOfMod)
tab modOfMod_CASCOT_dh if modOfMod_CASCOT_dh==0 & `regression_condition_dh' /* (3') */
scalar N_lc = r(N)
su modOfMod_CASCOT_dh if `regression_condition_dh'
scalar N_unc = r(N)
* write APE to txt file
scalar modOfMod_APE_dh = 1 - (N_lc/(N_unc))
di modOfMod_APE_dh
file open APEfactor_modOfMod_CASCOT_dh using "Results/APEfactor_modOfMod_CASCOT_dh.txt", write replace
file write APEfactor_modOfMod_CASCOT_dh (round(modOfMod_APE_dh,0.01))
file close APEfactor_modOfMod_CASCOT_dh
gen modOfMod_CASCOT_stdz_dh= ((modOfMod_CASCOT_dh - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local modOfMod_leftLimit_dh : di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su modOfMod_CASCOT_stdz_dh if `regression_condition_dh'
di `modOfMod_leftLimit_dh'
tab modOfMod_CASCOT_stdz_dh if modOfMod_CASCOT_stdz_dh<=`modOfMod_leftLimit_dh' & `regression_condition_dh' /* This should be the same number as (3'), above*/

*********************************************************************************************************************************************************

* Heckman instrument
local heckman_instrument "available"
local instrument_name "Available to start job"

*********************************************************************************************************************************************************

* Tobit
* condition and controls 
local regression_condition_t "sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & fpt_job2!=. & temporary1!=. & temporary2!=. & public1!=. & public2!=. & selfe1!=. & selfe2!=. & edulevel!=. & seek_method!=. & uresmc1!=. & f_v_retire2!=. & quarter!="." & angSep_CASCOT!=. & industry!=. & ilodefr1==1 & ilodefr2==1 & empmon2>=0 & empmon2<=2" 
local controls_t = "Aggre_Ur_pct sex age1 age1_sq mar_cohab durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 i.edulevel i.seek_method i.uresmc1 i.f_v_retire2 i.quarter i.industry"


* create standardardised angSep
tab angSep_CASCOT if angSep_CASCOT==0 & `regression_condition_t' /* (3) */
scalar N_lc = r(N)
su angSep_CASCOT if `regression_condition_t'
scalar N_unc = r(N)
* write APE to txt file
scalar angSep_APE_t = 1 - (N_lc/(N_unc))
di angSep_APE_t
file open APEfactor_angSep_CASCOT_t using "Results/APEfactor_angSep_CASCOT_t.txt", write replace
file write APEfactor_angSep_CASCOT_t (round(angSep_APE_t,0.01))
file close APEfactor_angSep_CASCOT_t
gen angSep_CASCOT_stdz_t= ((angSep_CASCOT - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local angSep_leftLimit_t : di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su angSep_CASCOT_stdz_t if `regression_condition_t'
di `angSep_leftLimit_t'
tab angSep_CASCOT_stdz_t if angSep_CASCOT_stdz_t<=`angSep_leftLimit_t' & `regression_condition_t' /* This should be the same number as (3), above*/

* create standardised abs(modOfMod)
tab modOfMod_CASCOT if angSep_CASCOT==0 & `regression_condition_t' /* (4) */
scalar N_lc = r(N)
su modOfMod_CASCOT if `regression_condition_t'
scalar N_unc = r(N)
* write APE to txt file
scalar modOfMod_APE_t = 1 - (N_lc/(N_unc))
di modOfMod_APE_t
file open APEfactor_modOfMod_CASCOT_t using "Results/APEfactor_modOfMod_CASCOT_t.txt", write replace
file write APEfactor_modOfMod_CASCOT_t (round(modOfMod_APE_t,0.01))
file close APEfactor_modOfMod_CASCOT_t
gen modOfMod_CASCOT_stdz_t = ((modOfMod_CASCOT - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local modOfMod_leftLimit_t: di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su modOfMod_CASCOT_stdz_t if `regression_condition_t'
di `modOfMod_leftLimit_t'
tab modOfMod_CASCOT_stdz_t if modOfMod_CASCOT_stdz_t<=`modOfMod_leftLimit_t' & `regression_condition_t' /* This should be the same number as (3) and (4), above*/


* Tobit on aggregated one-digit
local regression_condition_AGG "sex!=. & age1!=. & mar_cohab!=. & durats1!=. & fpt_job1!=. & fpt_job2!=. & temporary1!=. & temporary2!=. & public1!=. & public2!=. & selfe1!=. & selfe2!=. & edulevel!=. & seek_method!=. & uresmc1!=. & f_v_retire2!=. & quarter!="." & angSep_CASCOT_AGG!=. & industry!=. & ilodefr1==1 & ilodefr2==1 & empmon2>=0 & empmon2<=2" 

*create standardised angSep AGG
tab angSep_CASCOT_AGG if angSep_CASCOT_AGG==0 & `regression_condition_t' /* (5) */
scalar N_lc = r(N)
su angSep_CASCOT_AGG if `regression_condition_t'
scalar N_unc = r(N)
* write APE to txt file
scalar angSep_APE_AGG = 1 - (N_lc/(N_unc))
di angSep_APE_AGG
file open APEfactor_angSep_CASCOT_AGG_t using "Results/APEfactor_angSep_CASCOT_AGG_t.txt", write replace
file write APEfactor_angSep_CASCOT_AGG_t (round(angSep_APE_AGG,0.01))
file close APEfactor_angSep_CASCOT_AGG_t
gen angSep_CASCOT_AGG_stdz= ((angSep_CASCOT_AGG - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local angSep_leftLimit_AGG : di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su angSep_CASCOT_AGG_stdz if `regression_condition_t'
di `angSep_leftLimit_AGG'
tab angSep_CASCOT_AGG_stdz if angSep_CASCOT_AGG_stdz<=`angSep_leftLimit_AGG' & `regression_condition_AGG' /* This should be the same number as (5), above*/

*create standardised modOfMod AGG
tab modOfMod_CASCOT_AGG if modOfMod_CASCOT_AGG==0 & `regression_condition_t' /* (6) */
scalar N_lc = r(N)
su modOfMod_CASCOT_AGG if `regression_condition_t'
scalar N_unc = r(N)
* write APE to txt file
scalar modOfMod_APE_AGG = 1 - (N_lc/(N_unc))
di modOfMod_APE_AGG
file open APEfactor_modOfMod_CASCOT_AGG_t using "Results/APEfactor_modOfMod_CASCOT_AGG_t.txt", write replace
file write APEfactor_modOfMod_CASCOT_AGG_t (round(modOfMod_APE_AGG,0.01))
file close APEfactor_modOfMod_CASCOT_AGG_t
gen modOfMod_CASCOT_AGG_stdz= ((modOfMod_CASCOT_AGG - r(mean))/r(sd))
* added epsilon to deal with Stata rounding errors - need to check fraction above/below limit is the same in the pre-standardised and standardised variables
local modOfMod_leftLimit_AGG : di %9.7g scalar((0 - r(mean))/r(sd)) + 0.0000001
su modOfMod_CASCOT_AGG_stdz if `regression_condition_t'
di `modOfMod_leftLimit_AGG'
tab modOfMod_CASCOT_AGG_stdz if modOfMod_CASCOT_AGG_stdz<=`modOfMod_leftLimit_AGG' & `regression_condition_AGG' /* This should be the same number as (6), above*/

*********************************************************************************************************************************************************

***** TOBIT NO CONTROLS *******

		* tobit with no covariates
		xi: tobit angSep_CASCOT_stdz_s Aggre_Ur_pct if `regression_condition_s' [pw=lgwt], ll(`angSep_leftLimit_s') vce(robust)
		eststo angSep_tobit_simple
		
		* APE (F(z)) - fraction of obs above the limit
		scalar APE = e(N_unc)/(e(N_lc)+e(N_unc))
		di APE
		
		* agg_urate 
		scalar beta_Aggre_Ur_pct_simple = round(_b[Aggre_Ur_pct],0.01)
		file open agg_urate_angSep_simple using "Results/agg_urate_angSep_simple.txt", write replace
		file write agg_urate_angSep_simple (beta_Aggre_Ur_pct_simple)
		file close agg_urate_angSep_simple
		* agg_urate times APE
		scalar agg_urate_ape_simple = round(APE*_b[Aggre_Ur_pct],0.01)
		file open agg_urate_angSep_ape_simple using "Results/agg_urate_angSep_ape_simple.txt", write replace
		file write agg_urate_angSep_ape_simple (agg_urate_ape_simple)
		file close agg_urate_angSep_ape_simple
		
		* tobit with no covariates
		xi: tobit modOfMod_CASCOT_stdz_s Aggre_Ur_pct if `regression_condition_s' [pw=lgwt], ll(`modOfMod_leftLimit_s') vce(robust)
		eststo modOfMod_tobit_simple
		
		* APE (F(z)) - fraction of obs above the limit
		scalar APE = e(N_unc)/(e(N_lc)+e(N_unc))
		di APE

		
		* agg_urate 
		scalar beta_Aggre_Ur_pct_simple = round(_b[Aggre_Ur_pct],0.01)
		file open agg_urate_modOfMod_simple using "Results/agg_urate_modOfMod_simple.txt", write replace
		file write agg_urate_modOfMod_simple (beta_Aggre_Ur_pct_simple)
		file close agg_urate_modOfMod_simple
		* agg_urate times APE
		scalar agg_urate_ape_simple = round(APE*_b[Aggre_Ur_pct],0.01)
		file open agg_urate_modOfMod_ape_simple using "Results/agg_urate_modOfMod_ape_simple.txt", write replace
		file write agg_urate_modOfMod_ape_simple (agg_urate_ape_simple)
		file close agg_urate_modOfMod_ape_simple
		


		* output to latex file 
				esttab angSep_tobit_simple modOfMod_tobit_simple using Results/tobit_simple_2000s_temp.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
				b(a2) ///
				addnotes("")  unstack compress keep(Aggre_Ur_pct)     ///
				scalars ("ll Log llik.") order(Aggre_Ur_pct)  /// 
				varwidth(15) modelwidth(8) coeflabels( Aggre_Ur_pct agg_urate) nonumbers //

				shell  $my_python_path/python DoFiles/tobit_simple_2000s.py
				erase Results/tobit_simple_2000s_temp.tex
				estimates clear 
		
				


**********************************************************************************************************************************************************************************************************************						
				
						


* double hurdle
xi: dhreg angSep_CASCOT_stdz_dh `controls_dh_2' if `regression_condition_dh', hd(`controls_dh_1' `heckman_instrument') millr
eststo angSep_CASCOT_dh

xi: dhreg modOfMod_CASCOT_stdz_dh `controls_dh_2' if `regression_condition_dh', hd(`controls_dh_1' `heckman_instrument') millr
eststo modOfMod_CASCOT_dh



*****   Tobit with controls   *****
		
		


					*********************************** Decomposition ****************************
					******************************************************************************************
					* first unstandardised for McDonald Moffit Decomposition
					xi: tobit angSep_CASCOT `controls_t' if `regression_condition_t' [pw=lgwt], ll(0) vce(robust)

					* APE
					*gen dependent = angSep_CASCOT
					*do Dofiles/APEfactor_2000s.do
					
					* APE (F(z)) - fraction of obs above the limit
					scalar APE = e(N_unc)/(e(N_lc)+e(N_unc))
					di APE
					
					* sigma 
					mat temp = e(b)
					matlist temp
					scalar sigma = temp[1,67] // stata doesn't seem to have 'last element' capability so always check this
					di sigma


					* z, f(z)
					* first get z corresponding to F(z)
					scalar z = invnormal(APE)
					scalar fz = normalden(z)
					
					
					* fraction of mean total response due to response above limit
					scalar fracMeanPos = (1-z*fz/APE - (fz^2/APE^2))
					di fracMeanPos

					* dEy*/dXi - change in task distance for occupation changers due to change in urate
					scalar dEystarbydXi = fracMeanPos*_b[Aggre_Ur_pct]
					di dEystarbydXi


					* F(z)Bi - marginal effect (both occupation changers and stayers)
					scalar FzBi = _b[Aggre_Ur_pct]*APE
					di FzBi


					* Ey* - mean of y, y>0
					scalar Eystar = z*sigma + sigma*fz/APE
					di Eystar

					* dFz/dXi - effect of unemployment rate on probability of occupation change
	
					scalar dFzbydXi = fz*_b[Aggre_Ur_pct]/sigma
					di dFzbydXi

						

					* Decomposition		
							
							* fraction of mean total response due to response above limit
							scalar fracMeanPos_angSep_CASCOT = fracMeanPos
							file open fracMeanPos_angSep_CASCOT using "Results/fracMeanPos_angSep_CASCOT.txt", write replace
							file write fracMeanPos_angSep_CASCOT (round(100*fracMeanPos_angSep_CASCOT,0.01))
							file close fracMeanPos_angSep_CASCOT
							* rounded fraction of mean total response due to response above limit
							file open fracMeanPos_angSep_CASCOT_r using "Results/fracMeanPos_angSep_CASCOT_r.txt", write replace
							file write fracMeanPos_angSep_CASCOT_r (round(100*fracMeanPos_angSep_CASCOT,1))
							file close fracMeanPos_angSep_CASCOT_r
							* dEy*/dXi - change in task distance for occupation changers due to change in urate
							scalar dEystarbydXi_angSep_CASCOT = dEystarbydXi
							file open dEystarbydXi_angSep_CASCOT using "Results/dEystarbydXi_angSep_CASCOT.txt", write replace
							file write dEystarbydXi_angSep_CASCOT (round(dEystarbydXi_angSep_CASCOT,0.0001))
							file close dEystarbydXi_angSep_CASCOT
							* F(z)Bi - marginal effect (both occupation changers and stayers)
							scalar FzBi_angSep_CASCOT = FzBi
							file open FzBi_angSep_CASCOT using "Results/FzBi_angSep_CASCOT.txt", write replace
							file write FzBi_angSep_CASCOT (round(FzBi_angSep_CASCOT,0.01))
							file close FzBi_angSep_CASCOT
							* Ey* - mean of y, y>0
							scalar Eystar_angSep_CASCOT = Eystar
							file open Eystar_angSep_CASCOT using "Results/Eystar_angSep_CASCOT.txt", write replace
							file write Eystar_angSep_CASCOT (round(Eystar_angSep_CASCOT,0.01))
							file close Eystar_angSep_CASCOT
							* dFz/dXi - effect of unemployment rate on probability of occuaption change
							scalar dFzbydXi_angSep_CASCOT = dFzbydXi
							file open dFzbydXi_angSep_CASCOT using "Results/dFzbydXi_angSep_CASCOT.txt", write replace
							file write dFzbydXi_angSep_CASCOT (round(dFzbydXi_angSep_CASCOT,0.01))
							file close dFzbydXi_angSep_CASCOT
							* total effect
							scalar totalEffect = APE*dEystarbydXi_angSep_CASCOT + Eystar_angSep_CASCOT*dFzbydXi_angSep_CASCOT
							file open totalEffect using "Results/totalEffect.txt", write replace
							file write totalEffect (round(totalEffect,0.0001))
							file close totalEffect


					*capture drop dependent

***************************************** proper angSep Tobit *****************************************
		xi: tobit angSep_CASCOT_stdz_t `controls_t' if `regression_condition_t' [pw=lgwt], ll(`angSep_leftLimit_t') vce(robust)
		eststo angSep_tobit_CASCOT_t
		
		* APE (F(z)) - fraction of obs above the limit
		scalar APE = e(N_unc)/(e(N_lc)+e(N_unc))
		di APE

		
	* Scalars to be referenced in paper

		* agg_urate 
		scalar beta_Aggre_Ur_pct = round(_b[Aggre_Ur_pct],0.01)
		file open agg_urate_angSep_CASCOT using "Results/agg_urate_angSep_CASCOT.txt", write replace
		file write agg_urate_angSep_CASCOT (beta_Aggre_Ur_pct)
		file close agg_urate_angSep_CASCOT
		* agg_urate times APE
		scalar agg_urate_ape = round(APE*_b[Aggre_Ur_pct],0.01)
		file open agg_urate_angSep_ape_CASCOT using "Results/agg_urate_angSep_ape_CASCOT.txt", write replace
		file write agg_urate_angSep_ape_CASCOT (agg_urate_ape)
		file close agg_urate_angSep_ape_CASCOT
		* agg_urate change in context
		scalar agg_urate_context = round(APE*_b[Aggre_Ur_pct]*`angSep_s_sd'*2.5,0.001)
		file open agg_urate_context using "Results/agg_urate_context.txt", write replace
		file write agg_urate_context (agg_urate_context)
		file close agg_urate_context	
		* agg_urate change in context
		scalar agg_urate_context2 = round(`angSep_s_mean' + agg_urate_context ,0.001)
		file open agg_urate_context2 using "Results/agg_urate_context2.txt", write replace
		file write agg_urate_context2 (agg_urate_context2)
		file close agg_urate_context2
		* num sd
		scalar angSep_sd = abs(round(APE*_b[Aggre_Ur_pct],0.01))
		file open angSep_sd_CASCOT using "Results/angSep_sd_CASCOT.txt", write replace
		file write angSep_sd_CASCOT (angSep_sd)
		file close angSep_sd_CASCOT
		*N
		scalar N_angSep_CASCOT = e(N)
		file open N_angSep_CASCOT using "Results/N_angSep_CASCOT.txt", write replace
		file write N_angSep_CASCOT (N_angSep_CASCOT)
		file close N_angSep_CASCOT


***************************************** proper modOfMod Tobit *****************************************

	xi: tobit modOfMod_CASCOT_stdz_t `controls_t' if  `regression_condition_t' [pw=lgwt], ll(`modOfMod_leftLimit_t') vce(robust)
	eststo modOfMod_tobit_CASCOT_t
	
		* APE (F(z)) - fraction of obs above the limit
		scalar APE = e(N_unc)/(e(N_lc)+e(N_unc))
		di APE
			

			* agg_urate 
			scalar beta_Aggre_Ur_pct = round(_b[Aggre_Ur_pct],0.01)
			file open agg_urate_modOfMod_CASCOT using "Results/agg_urate_modOfMod_CASCOT.txt", write replace
			file write agg_urate_modOfMod_CASCOT (beta_Aggre_Ur_pct)
			file close agg_urate_modOfMod_CASCOT
			* agg_urate times APE
			scalar agg_urate_ape = round(APE*_b[Aggre_Ur_pct],0.01)
			file open agg_urate_modOfMod_ape_CASCOT using "Results/agg_urate_modOfMod_ape_CASCOT.txt", write replace
			file write agg_urate_modOfMod_ape_CASCOT (agg_urate_ape)
			file close agg_urate_modOfMod_ape_CASCOT
			* agg_urate change in context
			scalar agg_urate_context_mod = round(APE*_b[Aggre_Ur_pct]*`modOfMod_s_sd'*2.5,0.001)
			file open agg_urate_context_mod using "Results/agg_urate_context_mod.txt", write replace
			file write agg_urate_context_mod (agg_urate_context_mod)
			file close agg_urate_context_mod	
			* num sd
			scalar modOfMod_sd = abs(round(APE*_b[Aggre_Ur_pct],0.01))
			file open modOfMod_sd_CASCOT using "Results/modOfMod_sd_CASCOT.txt", write replace
			file write modOfMod_sd_CASCOT (modOfMod_sd)
			file close modOfMod_sd_CASCOT
			*N
			scalar N_modOfMod_CASCOT = e(N)
			file open N_modOfMod_CASCOT using "Results/N_modOfMod_CASCOT.txt", write replace
			file write N_modOfMod_CASCOT (N_modOfMod_CASCOT)
			file close N_modOfMod_CASCOT
			* fraction of mean total response due to response above limit
			scalar fracMeanPos_modOfMod_CASCOT = fracMeanPos
			file open fracMeanPos_modOfMod_CASCOT using "Results/fracMeanPos_modOfMod_CASCOT.txt", write replace
			file write fracMeanPos_modOfMod_CASCOT (round(100*fracMeanPos_modOfMod_CASCOT,0.01))
			file close fracMeanPos_modOfMod_CASCOT
			* dEystar/dXi - change in task distance for occupation changers due to change in urate
			scalar dEystarbydXi_modOfMod_CASCOT = dEystarbydXi
			file open dEystarbydXi_modOfMod_CASCOT using "Results/dEystarbydXi_modOfMod_CASCOT.txt", write replace
			file write dEystarbydXi_modOfMod_CASCOT (round(dEystarbydXi_modOfMod_CASCOT,0.01))
			file close dEystarbydXi_modOfMod_CASCOT
			
			
	***************************************** aggregated angSep Tobit *****************************************		
	xi: tobit angSep_CASCOT_AGG_stdz `controls_t' if `regression_condition_AGG' [pw=lgwt], ll(`angSep_leftLimit_AGG') vce(robust)	
	eststo angSep_tobit_CASCOT_AGG

***************************************** aggregated modOfMod Tobit *****************************************

	xi: tobit modOfMod_CASCOT_AGG_stdz `controls_t' if  `regression_condition_AGG' [pw=lgwt], ll(`modOfMod_leftLimit_AGG') vce(robust)
	eststo modOfMod_tobit_CASCOT_AGG	


	* output to latex file 
		*esttab angSep_tobit_CASCOT_t modOfMod_tobit_CASCOT_t angSep_tobit_CASCOT_AGG modOfMod_tobit_CASCOT_AGG probit_EE angSep_tobit_CASCOT_h modOfMod_tobit_CASCOT_h using Results/tobit_temp_2000s.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		
		esttab angSep_tobit_CASCOT_t modOfMod_tobit_CASCOT_t angSep_tobit_CASCOT_AGG modOfMod_tobit_CASCOT_AGG angSep_CASCOT_dh modOfMod_CASCOT_dh using Results/tobit_temp_2000s.tex, replace  star(* 0.10 ** 0.05 *** 0.01) se mtitles nogaps pr2 r2 margin  ///
		b(a2) ///
		addnotes("")  unstack compress keep(Aggre_Ur_pct _mill sex age1 age1_sq mar_cohab durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 _Iedul* _Iseek_meth_*  _If_v_retir_* start)     ///
		scalars ("ll Log llik.") order(Aggre_Ur_pct sex age1 age1_sq mar_cohab _Iedulevel1_1 _Iedulevel1_2 durats1 fpt_job1 fpt_job2 temporary1 temporary2 public1 public2 selfe1 selfe2 _If_v_retir_1 _If_v_retir_3 _Iseek_meth_1 _Iseek_meth_2 _Iseek_meth_3 _Iseek_meth_4 _Iseek_meth_5 start _mill )  /// 
		indicate("Quarters=_Iquarter*"  "Regions=_Iuresmc1* " "Industries=_Iindustry* ") varwidth(15) modelwidth(8) coeflabels( Aggre_Ur_pct "Unemployment Rate" sex "Female" age1 "Age" age1_sq "Age squared" mar_cohab "Married" _Iedulevel1_1 "High Education" _Iedulevel1_2 "Medium Education" _If_v_retir_1 "Involuntary Separation" _If_v_retir_3 "Other Separation" durats1 "Tenure" fpt_job1 "Full Time in Previous Job" fpt_job2 "Full Time in Current Job" temporary1 "Temporary in Previous Job" temporary2 "Temporary in Current Job" public1 "Public Sector in Previous Job" public2 "Public Sector in Current Job" selfe1 "Self Employed in Previous Job" selfe2 "Self Employed in Current Job" _Iseek_meth_1 "Search Method: Job Centre" _Iseek_meth_2 "Search Method: Advertisements" _Iseek_meth_3 "Search Method: Direct Application" _Iseek_meth_4 "Search Method: Family/Friend" _Iseek_meth_5 "Search Method: Other" start "Available" _mill "$\lambda$") nonumbers //


estimates clear
*log close
