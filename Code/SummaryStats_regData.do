
use Data/regressionData_2q_5q_post.dta, clear
keep if used_ALL

label variable angSep_CASCOT "$\Delta$ Task Content"
label variable angSep_CASCOT_AGG "$\Delta$ Task Content 1 digit"
label variable modOfMod_CASCOT "$\Delta$ Task Complexity"
label variable modOfMod_CASCOT_AGG "$\Delta$ Task Complexity 1 digit"
label variable jobMover "JobMover"

* job movers
eststo clear
estpost tab jobMover
eststo jobMovers

esttab jobMovers using Results/jobMoverTab.tex, replace nonotes nogaps nonumbers title("Number of job movers, 0 = did not move jobs, 1= moved jobs") 

* job movers by status
eststo clear
sort jobMover status 
by jobMover: eststo: estpost tab ///
    status
esttab using Results/jobMoverTabbyStatus.tex, replace nonotes nogaps nonumbers mtitles("Job Mover=0" "Job Mover=1")  keep(EE IE UE) order(EE IE UE) title("Number of job movers by transition type, 0 = did not move jobs, 1= moved jobs")	



*second hurdle

eststo clear
sort jobMover
by jobMover: eststo: estpost summarize ///
    angSep_CASCOT modOfMod_CASCOT 
esttab using Results/angSepJobMove.tex, replace cells("mean sd") mtitles("Job Mover=0" "Job Mover=1") nogaps nonumbers  title("Mean and sd of $\Delta$ task content and $\Delta$ task complexity by job move, 0 = did not move jobs, 1= moved jobs") coeflabels(angSep_CASCOT "$\Delta$ Task Content" modOfMod_CASCOT "$\Delta$ Task Complexity") label
* this is for aggregate measure, currently taken out:
*    angSep_CASCOT angSep_CASCOT_AGG modOfMod_CASCOT modOfMod_CASCOT_AGG
*esttab using Results/angSepJobMove.tex, replace cells("mean sd") mtitles("Job Mover=0" "Job Mover=1") nogaps nonumbers  title("Mean and sd of $\Delta$ tasks and $\Delta$ skills by job move, 0 = did not move jobs, 1= moved jobs") coeflabels(angSep_CASCOT "$\Delta$ Tasks" angSep_CASCOT_AGG "$\Delta$ Tasks 1 digit" modOfMod_CASCOT "$\Delta$ Skills" modOfMod_CASCOT_AGG "$\Delta$ Skills 1 digit") label


eststo clear
gen angSep_mover = 0
replace angSep_mover =1 if angSep_CASCOT>0 | modOfMod_CASCOT>0

* angSep movers by status
eststo clear
sort angSep_mover status 
by angSep_mover: eststo: estpost tab ///
    status
esttab using Results/angSepTabbyStatus.tex, replace nonotes nogaps nonumbers mtitles("Task Mover=0" "Task Mover=1")  keep(EE IE UE) order(EE IE UE) title("Number of task movers by transition type, 0 = did not move jobs, 1= moved jobs")	




eststo clear
sort angSep_mover
by angSep_mover : eststo: estpost summarize ///
    angSep_CASCOT  modOfMod_CASCOT 
eststo clear
sort angSep_mover
by angSep_mover : eststo: estpost summarize ///
    angSep_CASCOT  modOfMod_CASCOT 
esttab using Results/angSepTaskMove.tex, replace cells("mean sd") mtitles("Task mover=0" "Task mover=1") nogaps nonumbers title("Mean and sd of $\Delta$ task content and $\Delta$ task complexity by task move") coeflabels(angSep_CASCOT "$\Delta$ Task Content" modOfMod_CASCOT "$\Delta$ Task Complexity") label
* this is for aggregate measure, currently taken out:
*angSep_CASCOT angSep_CASCOT_AGG modOfMod_CASCOT modOfMod_CASCOT_AGG
*esttab using Results/angSepTaskMove.tex, replace cells("mean sd") mtitles("Task/skill mover=0" "Task/skill mover=1") nogaps nonumbers title("Mean and sd of $\Delta$ tasks and $\Delta$ skills by task/skill move, 0 = did not move task/skills, 1= moved task/skills") coeflabels(angSep_CASCOT "$\Delta$ Tasks" angSep_CASCOT_AGG "$\Delta$ Tasks 1 digit" modOfMod_CASCOT "$\Delta$ Skills" modOfMod_CASCOT_AGG "$\Delta$ Skills 1 digit") label


eststo clear
sort angSep_mover
by angSep_mover : eststo: estpost summarize ///
    jobMover
esttab using Results/angSepjobMover.tex, replace cells("mean sd") mtitles("Task mover=0" "Task mover=1") nogaps nonumbers title("Mean and sd of job mover by task move, 0 = did not move tasks, 1= moved tasks") coeflabels(jobMover "Job Mover") label
 	

drop angSep_mover



* regression variables

eststo clear
sort jobMover
by jobMover: eststo: estpost summarize ///
   sex age1 mar_cohab durats1 fpt_job1 temporary1 public1 selfe1 edulevel1 uresmc1 f_v_retire2 industry n_child spell_duration lookfor1
esttab using Results/regVars_jobMove.tex, replace cells("mean sd") mtitles("Job Mover=0" "Job Mover=1") nogaps nonumbers title("Mean and sd of dependent variables by job move, 0 = did not move jobs, 1= moved jobs") coeflabels( sex "Female" age1 "Age" mar_cohab "Married" durats1 "Tenure" fpt_job1 "Full time" temporary1 "Temporary" public1 "Public" selfe1 "Self-employed" edulevel1 "Education" uresmc1 "Region" f_v_retire2 "Reason left last job" industry "Industry" n_child "Number of Children" spell_duration "Time between jobs" lookfor1 "Whether looking" ) 




eststo clear
sort status 
by status: eststo: estpost summarize ///
   Aggre_Ur_pct sex age1 mar_cohab durats1 fpt_job1 temporary1 public1 selfe1 edulevel1 uresmc1 f_v_retire2 industry if jobMover==1
esttab using Results/regVars_statusJobMove.tex, replace cells("mean sd") mtitles("EE" "IE" "UE") nogaps nonumbers title("Mean and sd of independent variables by transition type; all job movers") label

eststo clear
eststo: estpost summarize ///
   Aggre_Ur_pct sex age1 mar_cohab durats1 fpt_job1 temporary1 public1 selfe1 edulevel1 uresmc1 f_v_retire2 industry if jobMover==0
esttab using Results/regVars_statusJobStay.tex, replace cells("mean sd") mtitles("EE") nogaps nonumbers title("Mean and sd of independent variables by transition type; all job stayers") label 




eststo clear
sort wait
by wait : eststo: estpost summarize ///
    angSep_CASCOT modOfMod_CASCOT if jobMover==1
esttab using Results/waitTaskMove.tex, replace cells("mean sd") mtitles("wait=0" "wait=1") nogaps nonumbers label 

eststo clear

* are differences in task and skills by wait significant 

gen angSep_jm_EE = .
replace angSep_jm_EE = angSep_CASCOT if jobMover==1 & status=="EE"
label variable angSep_jm_EE "$\Delta$ Task Content, EE job movers"
gen modOfMod_jm_EE = .
replace modOfMod_jm_EE = modOfMod_CASCOT if jobMover==1 & status=="EE"
label variable modOfMod_jm_EE "$\Delta$ Task Complexity, EE job movers"
gen angSep_jm_UE = .
replace angSep_jm_UE = angSep_CASCOT if jobMover==1 & status=="UE"
label variable angSep_jm_UE "$\Delta$ Task Content, UE job movers"
gen modOfMod_jm_UE = .
replace modOfMod_jm_UE = modOfMod_CASCOT if jobMover==1 & status=="UE"
label variable modOfMod_jm_UE "$\Delta$ Task Complexity, UE job movers"
gen angSep_jm_IE = .
replace angSep_jm_IE = angSep_CASCOT if jobMover==1 & status=="IE"
label variable angSep_jm_IE "$\Delta$ Task Content, IE job movers"
gen modOfMod_jm_IE = .
replace modOfMod_jm_IE = modOfMod_CASCOT if jobMover==1 & status=="IE"
label variable modOfMod_jm_IE "$\Delta$ Task Complexity, UE job movers"


local varlist " angSep_jm_EE modOfMod_jm_EE angSep_jm_UE modOfMod_jm_UE angSep_jm_IE modOfMod_jm_IE"	
dmout `varlist' using "Results/test" , by(wait) replace tex

* are differences in task and skills by wait significant - EE?
* since the variances between the samples are different, we'll use the Satterthwaite approximation *
	local varlist " angSep_CASCOT modOfMod_CASCOT"	
	local condition "jobMover==1 & status=="EE"" 
	dmout `varlist' if `condition' using "Results/t_test_wait_EE" , by(wait) replace tex caption("Mean values of $\Delta$ task content and $\Delta$ task complexity for EE transitions by whether waited to start new job, 1= yes , 0=no") 
	*mvtest means `varlist' if `condition', by(wait)
* are differences in task and skills by wait significant - IE?
* since the variances between the samples are different, we'll use the Satterthwaite approximation *
	local varlist " angSep_CASCOT modOfMod_CASCOT"	
	local condition "jobMover==1 & status=="IE"" 
	dmout `varlist' if `condition' using "Results/t_test_wait_IE" , by(wait) replace tex caption("Mean values of $\Delta$ task content and $\Delta$ task complexity for IE transitions by whether waited to start new job, 1= yes , 0=no") 

eststo clear
* are differences in task and skills by wait significant - UE?
* since the variances between the samples are different, we'll use the Satterthwaite approximation *
	local varlist " angSep_CASCOT modOfMod_CASCOT"	
	local condition "jobMover==1 & status=="UE"" 
	dmout `varlist' if `condition' using "Results/t_test_wait_UE" , by(wait) replace tex caption("Mean values of $\Delta$ task content and $\Delta$ task complexity for UE transitions by whether waited to start new job, 1= yes , 0=no") 


* does wait predict jobMove?
* since the variances between the samples are different, we'll use the Satterthwaite approximation *
	local varlist "jobMover"
	local condition "jobMover!=. & (status=="EE" | status=="IE" | status=="UE")" 
	dmout `varlist'  if `condition' using "Results/t_test_jobMove_ALL" , by(wait) replace tex caption("Likelihood of job move for all transitions by whether waiting to start job, 1= yes , 0=no")

eststo clear
sort status 
by status: eststo: estpost summarize ///
    jobMover
esttab using Results/regVars_statusJobMove.tex, replace cells("mean sd") mtitles("EE" "IE" "UE") nogaps nonumbers title("Mean and sd of control variables by transition type; all job movers") coeflabels(jobMover "Job Mover")



* how does distribution of statuses in synthetic sample compare to original 5q?

* synthetic sample, all transitions
eststo clear

* create marker for transtions with less than a year between
gen lessThanYear = 0
replace lessThanYear =1 if wneft112<=3 | wneft112==.

estpost tab status
eststo status_synth

* synthetic sample, job movers
estpost tabulate status if jobMover==1

eststo status_synth_jm

*synthetic sample, career movers
*gen careerMover = 0
*replace careerMover = 1 if jobMover==1 & angSep_CASCOT>0

*estpost tab status if careerMover==1
*eststo status_synth_cm

use Data/LFS_2q_dates.dta, clear
keep if status=="EE" | status=="IE" | status=="UE"
keep if ilodefr1<4
keep if ilodefr2<4
estpost tab status
eststo status_2q
gen jobMover = 0
replace jobMover = 1 if (status=="EE" & empmon2>=0 & empmon2<=3) | (status=="IE") | (status=="UE")  /* job movers */


estpost tab status if jobMover==1
eststo status_2q_jm



*esttab status_synth status_2q status_synth_jm status_2q_jm using Results/status_bySample.tex, replace nonotes nogaps nonumbers title("Transition types by sample") keep(EE IE UE) mtitles("All transitions, synthetic" "All transitions, 2Q" "Job Movers, synthetic" "Job Movers, 2Q")
esttab status_2q status_2q_jm status_synth status_synth_jm  using Results/status_bySample.tex, cells("pct(fmt(2))")replace nonotes nogaps nonumbers title("Observations by Transition Type") keep(EE IE UE) mtitles("All transitions"  "Job Movers" "All transitions"  "Job Movers")

