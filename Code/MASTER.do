********************************************************************************
*********************** MASTER FILE ********************************************
********************************************************************************

*********************** Preliminaries ******************************************
clear
*** change directory

cd "/Users/Rachel/Documents/Research/taskSkillsCycle/" /* path to where repository stored */
global my_python_path = "/usr/bin/python" /* path to where Python stored */

************************** Data Cleaning ***************************************
*** put together all 2Q and 5q files from extracted
* INPUTS: all files in Extracted folders (_2q, _5q)
* OUTPUTS: LFS_all_raw_2q.dta
* 	       LFS_all_raw_5q.dta
do Code/Data_extraction.do


************************** Data Cleaning ***************************************
*** clean the data
* INPUTS:  LFS_all_raw_2q.dta
* 		   LFS_all_raw_5q.dta
* OUTPUTS: LFS_2q.dta
*          LFS_5q.dta
do Code/Data_organisation_2q.do
do Code/Data_organisation_5q.do
erase Data/LFS_all_raw_2q.dta
erase Data/LFS_all_raw_5q.dta


************************** Task & Skills Data **********************************

*** create angular separation & scale score files
*shell $my_python_path/python DoFiles/ONET.py


*** add in angular separation & scale score
* INPUTS: all angSep & modOfMod csv files, LFS_2q, LFS_5q.dta
* OUTPUTS: all_variables_2q all_variables_5q.dta
do Code/Add_tasks_skills.do
erase Data/LFS_2q.dta

************************** Add Unemployment Rate *******************************
**** add in aggregate unemployment rate to 2q
* INPUTS: all_variables_2q.dta
* OUTPUTS: regressionData_2q.dta
do Code/Add_agg_unemployment.do
erase Data/all_variables_2q.dta



************************** Summary Stats, Preliminary Regressions *******************************
**** summary stats
* INPUTS: regressionData_2q.dta
* OUTPUTS: min_date.txt, max_date.txt, beta_skillTotal.txt, returns_skill_2000s.tex
do Code/summaryStats.do


************************** Main Analysis *******************************
**** run regressions for the paper
* INPUTS: regressionData_2q.dta
* OUTPUTS: all regression output
do Code/Regressions.do



