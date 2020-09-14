************ OVERVIEW ****************

This repository replicates the results of Bizopoulou & Forshaw 
'The Task Skill Content of Occupational Transitions over the Business Cycle: Evidence for the UK'

************ REQUIRED SOFTWARE ************

STATA
Python 2 - including numpy, pandas, seaborn
A Latex compiler

************ FILES ************

MASTER.do - master file calls all code
Data_extraction.do  - extracts separate .dta files into one .dta file for 2q and 5q surveys
Data_organisation_*q.do - cleans 2q/5q extracted data
Add_tasks_skills.do - adds task and skill distance measures to LFS data

************ REPLICATION STEPS ************


1. Download LFS data for the 2000s (see list below) from ukdataservice.ac.uk/, extract and save UKDA/ folders into the Extracted_2q and Extracted_5q folders

2. Open Code/MASTER.do in Stata
	Change lines 9 and 10 to reflect the paths to your repository and to Python
	(you will need Python in order to create graphs and format Stata output)
	
3. Run MASTER.do


************ REQUIRED DATA LIST ************

5936    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2000        
5928    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2002        
5924    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2003        
5920    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2004        
5916    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2005        
5548    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2006        
5779    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2007        
6206    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2008        
6336    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2009        
6636    Labour Force Survey Two-Quarter Longitudinal Dataset, April - September, 2010        

5935    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2000        
5931    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2001        
5927    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2002        
5923    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2003        
5919    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2004        
5915    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2005        
5914    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2006        
5719    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2007        
6205    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2008        
6278    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2009        
6550    Labour Force Survey Two-Quarter Longitudinal Dataset, January - June, 2010        

5937    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2000        
5933    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2001        
5929    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2002        
5925    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2003        
5921    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2004        
5917    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2005        
5610    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2006        
5797    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2007        
6121    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2008        
6407    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2009        
6717    Labour Force Survey Two-Quarter Longitudinal Dataset, July - December, 2010   

5942    Labour Force Survey Two-Quarter Longitudinal Dataset, October 1999 - March 2000        
5938    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2000 - March 2001        
5934    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2001 - March 2002        
5930    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2002 - March 2003        
5926    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2003 - March 2004        
5922    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2004 - March 2005        
5918    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2005 - March 2006        
5658    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2006 - March 2007        
5852    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2007 - March 2008        
6201    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2008 - March 2009        
6459    Labour Force Survey Two-Quarter Longitudinal Dataset, October 2009 - March 2010

5970    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2000 - June 2001    
5966    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2001 - June 2002    
5962    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2002 - June 2003    
5958    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2003 - June 2004    
5954    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2004 - June 2005    
5952    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2005 - June 2006    
5720    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2006 - June 2007    
6207    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2007 - June 2008    
6279    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2008 - June 2009    
6551    Labour Force Survey Five-Quarter Longitudinal Dataset, April 2009 - June 2010   

5969    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2000 - March 2001    
5965    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2001 - March 2002    
5961    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2002 - March 2003    
5957    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2003 - March 2004    
5953    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2004 - March 2005    
5951    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2005 - March 2006    
5660    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2006 - March 2007    
5853    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2007 - March 2008    
6202    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2008 - March 2009    
6460    Labour Force Survey Five-Quarter Longitudinal Dataset, January 2009 - March 2010    

5971    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2000 - September 2001    
5967    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2001 - September 2002    
5963    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2002 - September 2003    
5959    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2003 - September 2004    
5955    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2004 - September 2005    
5549    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2005 - September 2006    
5780    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2006 - September 2007    
6208    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2007 - September 2008    
6337    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2008 - September 2009    
6637    Labour Force Survey Five-Quarter Longitudinal Dataset, July 2009 - September 2010    

5972    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2000 - December 2001    
5968    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2001 - December 2002    
5964    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2002 - December 2003    
5960    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2003 - December 2004    
5956    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2004 - December 2005    
5611    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2005 - December 2006    
5798    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2006 - December 2007    
6122    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2007 - December 2008    
6408    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2008 - December 2009    
6719    Labour Force Survey Five-Quarter Longitudinal Dataset, October 2009 - December 2010

************ OUTPUTS ************
