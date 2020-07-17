************ OVERVIEW ****************

This repository replicates the results of Bizopoulou & Forshaw 
'The Task Skill Content of Occupational Transitions over the Business Cycle: Evidence for the UK'

************ REQUIRED SOFTWARE ************

STATA
Python 2
A Latex compiler

************ FILES ************

MASTER.do - master file calls all code
Data_extraction.do  - extracts separate .dta files into one .dta file for 2q and 5q surveys
Data_organisation_*q.do - cleans 2q/5q extracted data

************ REPLICATION STEPS ************

1. Download LFS data for the 2000s from ukdataservice.ac.uk/ and save the .dta files into the Extracted_2q and Extracted_5q 
 	folders (depending on whether they are the two quarter or five quarter versions)

2. Open Code/MASTER.do in Stata
	Change lines 9 and 10 to reflect the paths to your repository and to Python
	(you will need Python in order to create graphs and format Stata output)
	
3. Run MASTER.do


************ OUTPUTS ************