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


1. Download LFS data for the 2000s (see list below) from ukdataservice.ac.uk/ and save the .dta files into the Extracted_2q and Extracted_5q 

2. Open Code/MASTER.do in Stata
	Change lines 9 and 10 to reflect the paths to your repository and to Python
	(you will need Python in order to create graphs and format Stata output)
	
3. Run MASTER.do


************ REQUIRED DATA ************
5857    Quarterly Labour Force Survey, April - June, 2000    
5418    Quarterly Labour Force Survey, April - June, 2001    
5420    Quarterly Labour Force Survey, April - June, 2002    
5422    Quarterly Labour Force Survey, April - June, 2003    
5424    Quarterly Labour Force Survey, April - June, 2004    
5427    Quarterly Labour Force Survey, April - June, 2005    
5466    Quarterly Labour Force Survey, April - June, 2006    
5715    Quarterly Labour Force Survey, April - June, 2007    
6013    Quarterly Labour Force Survey, April - June, 2008    
6276    Quarterly Labour Force Survey, April - June, 2009    
6548    Quarterly Labour Force Survey, April - June, 2010    
5856    Quarterly Labour Force Survey, January - March, 2000    
5854    Quarterly Labour Force Survey, January - March, 2001    
5846    Quarterly Labour Force Survey, January - March, 2002    
5844    Quarterly Labour Force Survey, January - March, 2003    
5842    Quarterly Labour Force Survey, January - March, 2004    
5426    Quarterly Labour Force Survey, January - March, 2005    
5369    Quarterly Labour Force Survey, January - March, 2006    
5657    Quarterly Labour Force Survey, January - March, 2007    
5851    Quarterly Labour Force Survey, January - March, 2008    
6199    Quarterly Labour Force Survey, January - March, 2009    
6457    Quarterly Labour Force Survey, January - March, 2010    
5858    Quarterly Labour Force Survey, July - September, 2000    
5855    Quarterly Labour Force Survey, July - September, 2001    
5847    Quarterly Labour Force Survey, July - September, 2002    
5845    Quarterly Labour Force Survey, July - September, 2003    
5843    Quarterly Labour Force Survey, July - September, 2004    
5428    Quarterly Labour Force Survey, July - September, 2005    
5547    Quarterly Labour Force Survey, July - September, 2006    
5763    Quarterly Labour Force Survey, July - September, 2007    
6074    Quarterly Labour Force Survey, July - September, 2008    
6334    Quarterly Labour Force Survey, July - September, 2009    
6632    Quarterly Labour Force Survey, July - September, 2010    
5859    Quarterly Labour Force Survey, October - December, 2000    
5419    Quarterly Labour Force Survey, October - December, 2001    
5421    Quarterly Labour Force Survey, October - December, 2002    
5423    Quarterly Labour Force Survey, October - December, 2003    
5425    Quarterly Labour Force Survey, October - December, 2004    
5429    Quarterly Labour Force Survey, October - December, 2005    
5609    Quarterly Labour Force Survey, October - December, 2006    
5796    Quarterly Labour Force Survey, October - December, 2007    
6119    Quarterly Labour Force Survey, October - December, 2008    
6404    Quarterly Labour Force Survey, October - December, 2009    
6715    Quarterly Labour Force Survey, October - December, 2010

************ OUTPUTS ************
