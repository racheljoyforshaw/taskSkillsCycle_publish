********************************************************************************
*********************** MASTER FILE ********************************************
********************************************************************************

*********************** Preliminaries ******************************************
clear
*** change directory

cd "/Users/Rachel/Documents/Research/taskSkillsCycle/" /* path to where repository stored */
global my_python_path = "/Users/Rachel/anaconda/bin/" /* path to where Python stored */

************************** Data Cleaning ***************************************
*** put together all 2Q and 5q files from extracted
* INPUTS: all files in Extracted folders (_2q, _5q)
* OUTPUTS: LFS_all_raw_2q.dta
* 	       LFS_all_raw_5q.dta
do DoFiles/Data_extraction.do


************************** Data Cleaning ***************************************
*** clean the data
* INPUTS:  LFS_all_raw_2q.dta
* 		   LFS_all_raw_5q.dta
* OUTPUTS: LFS_2q.dta
*          LFS_5q.dta
do DoFiles/Data_organisation_2q.do
do DoFiles/Data_organisation_5q.do
*erase LFS_all_raw_2q.dta
*erase LFS_all_raw_5q.dta


************************** Task & Skills Data ***************************************

*** create angular separation & scale score files
*shell $my_python_path/python DoFiles/ONETmaster.py


*** add in angular separation & scale score
* INPUTS: all angSep & modOfMod csv files, LFS_2q, LFS_5q.dta
* OUTPUTS: all_variables_2q all_variables_5q.dta
do DoFiles/add_angSep_scaleScores.do
*erase LFS_2q.dta
*erase LFS_5q.dta
