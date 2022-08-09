***************************************************************
********* Probability of career change by 1,2,3,4 digit *******
***************************************************************/

use Data/all_variables_2q.dta, clear
keep if status=="EE" | status=="IE" | status=="UE"

scalar mult_factor = 10000000
file open mult_factor using "Results/mult_factor.txt", write replace
file write mult_factor (mult_factor)
file close mult_factor
* sort out weights
gen lgwt_int = lgwt*mult_factor

* create 1d, 2d and 3d occupations 
*** soc2010s ***
tostring soc10m1, gen(soc10_string1)
tostring soc10m2, gen(soc10_string2)


	* 1 digit
	* 1st period
	gen soc10_1d_1 = substr(soc10_string1,1,1)
	replace soc10_1d_1 = "." if soc10_1d_1=="-"
	destring soc10_1d_1, replace
	* 2nd period
	gen soc10_1d_2 = substr(soc10_string2,1,1)
	replace soc10_1d_2 = "." if soc10_1d_2=="-"
	destring soc10_1d_2, replace

	* 2 digit
	* 1st period
	gen soc10_2d_1 = substr(soc10_string1,1,2)
	replace soc10_2d_1 = "." if soc10_2d_1=="-9" | soc10_2d_1=="-8"
	destring soc10_2d_1, replace
	* 2nd period
	gen soc10_2d_2 = substr(soc10_string2,1,2)
	replace soc10_2d_2 = "." if soc10_2d_2=="-9" | soc10_2d_2=="-8"
	destring soc10_2d_2, replace

	* 3 digit
	* 1st period
	gen soc10_3d_1 = substr(soc10_string1,1,3)
	replace soc10_3d_1 = "." if soc10_3d_1=="-9" | soc10_3d_1=="-8"
	destring soc10_3d_1, replace
	* 2nd period
	gen soc10_3d_2 = substr(soc10_string2,1,3)
	replace soc10_3d_2 = "." if soc10_3d_2=="-9" | soc10_3d_2=="-8"
	destring soc10_3d_2, replace
/*
*** soc2000s ***
tostring soc2km1, gen(soc2k_string1)
tostring soc2km2, gen(soc2k_string2)

	* 2 digit
	* 1st period
	gen soc2k_1d_1 = substr(soc2k_string1,1,2)
	replace soc2k_1d_1 = "." if soc2k_1d_1=="-9" | soc2k_1d_1=="-8"
	destring soc2k_1d_1, replace
	* 2nd period
	gen soc2k_1d_2 = substr(soc2k_string2,1,2)
	replace soc2k_1d_2 = "." if soc2k_1d_2=="-9" | soc2k_1d_2=="-8"
	destring soc2k_1d_2, replace

	* 2 digit
	* 1st period
	gen soc2k_2d_1 = substr(soc2k_string1,1,2)
	replace soc2k_2d_1 = "." if soc2k_2d_1=="-9" | soc2k_2d_1=="-8"
	destring soc2k_2d_1, replace
	* 2nd period
	gen soc2k_2d_2 = substr(soc2k_string2,1,2)
	replace soc2k_2d_2 = "." if soc2k_2d_2=="-9" | soc2k_2d_2=="-8"
	destring soc2k_2d_2, replace

	* 3 digit
	* 1st period
	gen soc2k_3d_1 = substr(soc2k_string1,1,3)
	replace soc2k_3d_1 = "." if soc2k_3d_1=="-9" | soc2k_3d_1=="-8"
	destring soc2k_3d_1, replace
	* 2nd period
	gen soc2k_3d_2 = substr(soc2k_string2,1,3)
	replace soc2k_3d_2 = "." if soc2k_3d_2=="-9" | soc2k_3d_2=="-8"
	destring soc2k_3d_2, replace



** 3 digit **
* 1st period
gen soc_3digit_1 = soc10_3d_1
replace soc_3digit_1 = soc2k_3d_1 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_3digit_1  = soc90_3d_1 if date<yq(2001,1)
*replace soc_3digit_1 = . if soc_3digit_1==-9|soc_3digit_1==-8
* 2nd period
gen soc_3digit_2 = soc10_3d_2
replace soc_3digit_2 = soc2k_3d_2 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_3digit_2  = soc90_3d_2 if date<yq(2001,1)
*replace soc_3digit_2 = . if soc_3digit_2==-9|soc_3digit_2==-8

** 2 digit **
* 1st period
gen soc_2digit_1 = soc10_2d_1
replace soc_2digit_1 = soc2k_2d_1 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_2digit_1  = soc90_2d_1 if date<yq(2001,1)
replace soc_2digit_1 = . if soc_2digit_1==-9|soc_2digit_1==-8
* 2nd period
gen soc_2digit_2 = soc10_2d_2
replace soc_2digit_2 = soc2k_2d_2 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_2digit_2  = soc90_2d_2 if date<yq(2001,1)
*replace soc_2digit_2 = . if soc_2digit_2==-9|soc_2digit_2==-8

** 1 digit **
* 1st period
gen soc_1digit_1 = soc10_1d_1
replace soc_1digit_1 = soc2k_1d_1 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_2digit_1  = soc90_2d_1 if date<yq(2001,1)
*replace soc_1digit_1 = . if soc_1digit_1=="-9"|soc_1digit_1=="-8"
* 2nd period
gen soc_1digit_2 = soc10_2d_2
replace soc_1digit_2 = soc2k_1d_2 if date<yq(2011,1) & date> yq(2001,2)
*replace soc_2digit_2  = soc90_2d_2 if date<yq(2001,1)
*replace soc_1digit_2 = . if soc_1digit_2=="-9"|soc_1digit_2=="-8"
*/
*** now do the data analysis ***

* 4 digit
*EE
***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_all_4)   
* Count the number of occupational stayers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 & jobMover==1   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_s_all_4)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==1  & ilodefr2==1 & jobMover==0   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_m_all_4)   
matrix colnames occ_EE_all_4=occ_E2E_4
matrix colnames occ_EE_s_all_4=occ_Es_4
matrix colnames occ_EE_m_all_4=occ_Em_4

*UE
***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==2  & ilodefr2==1   [fw=lgwt_int] , v1(132/239) matrix(occ_UE_all_4)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==2  & ilodefr2==1 & jobMover==1   [fw=lgwt_int] , v1(132/239) matrix(occ_UE_m_all_4)   
matrix colnames occ_UE_all_4=occ_U2E_4
matrix colnames occ_UE_m_all_4=occ_Um_4

*IE
***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==3  & ilodefr2==1   [fw=lgwt_int] , v1(132/239) matrix(occ_IE_all_4)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==3  & ilodefr2==1 & jobMover==1   [fw=lgwt_int] , v1(132/239) matrix(occ_IE_m_all_4)   
matrix colnames occ_IE_all_4=occ_I2E_4
matrix colnames occ_IE_m_all_4=occ_Im_4


/*
* 3 digit

***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 & soc10_3d_1!=. & soc10_3d_2!=.  & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_all_3)   
* Count the number of occupational stayers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_3d_1== soc10_3d_2  & soc10_3d_1!=. & soc10_3d_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_s_all_3)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_3d_1!= soc10_3d_2  & soc10_3d_1!=. & soc10_3d_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_m_all_3)   
matrix colnames occ_EE_all_3=occ_E2E_3
matrix colnames occ_EE_s_all_3=occ_Es_3
matrix colnames occ_EE_m_all_3=occ_Em_3

* 2 digit

***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 & soc10_2d_1!=. & soc10_2d_2!=.  & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_all_2)   
* Count the number of occupational stayers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_2d_1== soc10_2d_2  & soc10_2d_1!=. & soc10_2d_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_s_all_2)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_2d_1!= soc10_2d_2  & soc10_2d_1!=. & soc10_2d_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_m_all_2)   
matrix colnames occ_EE_all_2=occ_E2E_2
matrix colnames occ_EE_s_all_2=occ_Es_2
matrix colnames occ_EE_m_all_2=occ_Em_2

* 1 digit

***Occupational data
* Count the number of workers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 & soc10_2d_1!=. & soc10_2d_2!=.  & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_all_1)   
* Count the number of occupational stayers who experienced job to job transition  
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_2d_1== soc10_2d_2 & soc10_2d_2!=. & soc_1digit_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_s_all_1)   
* Count the number of occupational movers who experienced job to job transition   
 tabcount date if ilodefr1==1  & ilodefr2==1 &  soc10_2d_1!= soc10_2d_2 & soc10_2d_2!=. & soc_1digit_2!=. & empmon2>=0 & empmon2<=2   [fw=lgwt_int] , v1(132/239) matrix(occ_EE_m_all_1)   
matrix colnames occ_EE_all_1=occ_E2E_1
matrix colnames occ_EE_s_all_1=occ_Es_1
matrix colnames occ_EE_m_all_1=occ_Em_1
*/
*--------------------------------------------------------------------------------------------------------------------------*
* The  codes below are to create  excel files containing the data series that established above *
*-------------------------------------------------------------------------------------------------------------------------- *

 local dem "all"
 local types 4
set matsize 11000
foreach type of local types {
		 *rmfiles, folder(.) match("Hm_data_`type'_dem.xml")
		 *rmfiles, folder(.) match("data_`type'_m_2Q.dta")
display "matrix all_data_occ_`type'=( occ_EE_m_all_`type' ,occ_EE_all_`type', occ_UE_m_all_`type' ,occ_UE_all_`type', occ_IE_m_all_`type' ,occ_IE_all_`type' )"
matrix all_data_`type'= (  occ_EE_m_all_`type' , occ_EE_all_`type',  occ_UE_m_all_`type' , occ_UE_all_`type',  occ_IE_m_all_`type' , occ_IE_all_`type')
svmatf , mat(all_data_`type') fil(Results/data_`type'_m_2Q.dta)
preserve
clear
use Results/data_`type'_m_2Q.dta, clear
destring row, gen(date)
format date %tq
gen str datestr = string( date, "%tq")
local varbs occ_Em_`type' occ_E2E_`type' occ_Um_`type' occ_U2E_`type' occ_Im_`type' occ_I2E_`type' 
foreach varb of local varbs {
replace `varb'=. if `varb'==0
}
mkmat  occ_Em_`type' occ_E2E_`type' occ_Um_`type' occ_U2E_`type' occ_Im_`type' occ_I2E_`type', matrix(all_data_`type'_dated) rownames(datestr)
xml_tab all_data_`type'_dated , save("Results/Hm_data_`type'_dem.xls") replace
restore
erase Results/data_`type'_m_2Q.dta
}

clear


*shell $my_python_path Code/prob_career_change.py

