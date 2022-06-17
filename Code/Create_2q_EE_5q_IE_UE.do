********************************************************************************
*********************** CREATE SYNTHETIC 2Q DATASET   *****************************************
********************************************************************************


****************** keep EEs from 2q and IE, UEs from 5q sample ******
clear


use Data/regressionData_2q.dta, clear
* keep only EEs from this sample
keep if status=="EE"
save Data/regressionData_2q_EE.dta, replace

use Data/regressionData_5q.dta, clear
keep if status=="IE" | status=="UE"


append using Data/regressionData_2q_EE.dta


keep if date >yq(2001,2) & date <yq(2021,1) /* something weird going on 2001q1-q2, ONS aware but not fixing */


save Data/regressionData_2q_5q.dta, replace


		 
