# packages
import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import csv
import os
import scipy.stats as sps
import seaborn as sns

cwd = os.getcwd()
#print cwd

tree = ET.parse(cwd + "/Results/modOfMod_wage_distribution_by_channels_skills.xml")
root = tree.getroot()

master_list_all = []
master_list_EUE = []
master_list_EIE = []
master_list_EE = []
MS_OFFICE_SCHEMA_STR="{urn:schemas-microsoft-com:office:spreadsheet}"
# all
for child in root[7][0]: # iter through row # <-- should probably do "findall"
    dummy_list = []                         # recursively right through the whole tree  for a more elegant solution
    if "Row" in child.tag:
        #print "Row: ", child.get(MS_OFFICE_SCHEMA_STR + "Index")
        for cell in child.findall(MS_OFFICE_SCHEMA_STR + "Cell"):
            #print "-Cell: ", cell.get(MS_OFFICE_SCHEMA_STR + "StyleID")
            for data in cell.findall(MS_OFFICE_SCHEMA_STR + "Data"):
                #print "--Data: ", data.get(MS_OFFICE_SCHEMA_STR + "Type"), ": ", data.text
                dummy_list = dummy_list + [data.text]
        master_list_all = master_list_all +[dummy_list]
master_list_all[0][0] = 'date'

df_all = pd.DataFrame.from_records(master_list_all[1:], columns=master_list_all[0])
df_all.set_index(['date'],inplace=True)

# get stats


#### Whole sample
## 25th
# total
with open(cwd + "/Figures/wages_all_25_up.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_upskill, errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_down.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_downskill, errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_unchanged.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_unchanged, errors=coerce))*100,2)))
## 50th
# total
with open(cwd + "/Figures/wages_all_50_up.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_upskill, errors=coerce))*100,2)))
Total_up = np.round(np.mean(pd.to_numeric(df_all.p50_upskill, errors=coerce))*100,2)     
with open(cwd + "/Figures/wages_all_50_down.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_downskill, errors=coerce))*100,2)))
Total_down = np.round(np.mean(pd.to_numeric(df_all.p50_downskill, errors=coerce))*100,2)   
with open(cwd + "/Figures/wages_all_50_unchanged.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_unchanged, errors=coerce))*100,2)))
Total_unchanged = np.round(np.mean(pd.to_numeric(df_all.p50_unchanged, errors=coerce))*100,2)  
## 75th
# total
with open(cwd + "/Figures/wages_all_75_up.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_upskill, errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_down.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_downskill, errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_unchanged.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_unchanged, errors=coerce))*100,2)))

# add recession indicator - only need for one df as all identical
df_recession = pd.read_csv(cwd + "/Inputs/UKQRecessionIndicator.csv")
df_recession = df_recession.rename(columns={"qtime1": "date"})
df_recession.set_index(['date'],inplace=True)
df_recession = df_recession.drop(columns=['qtime2', 'GBRRECDM2'])
df_all = df_all.join(df_recession)

#### Recession - 2008q2-2012q1

mask = df_all.GBRRECDM1==1.0
## 25th
# total
with open(cwd + "/Figures/wages_all_25_up_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_upskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_down_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_downskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_unchanged_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_unchanged[mask], errors=coerce))*100,2)))
## 50th
# total
with open(cwd + "/Figures/wages_all_50_up_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_upskill[mask], errors=coerce))*100,2)))
Total_up_r = np.round(np.mean(pd.to_numeric(df_all.p50_upskill[mask], errors=coerce))*100,2) 
with open(cwd + "/Figures/wages_all_50_down_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_downskill[mask], errors=coerce))*100,2)))
Total_down_r = np.round(np.mean(pd.to_numeric(df_all.p50_downskill[mask], errors=coerce))*100,2) 
with open(cwd + "/Figures/wages_all_50_unchanged_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_unchanged[mask], errors=coerce))*100,2)))
Total_unchanged_r = np.round(np.mean(pd.to_numeric(df_all.p50_unchanged[mask], errors=coerce))*100,2) 
## 75th
# total
with open(cwd + "/Figures/wages_all_75_up_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_upskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_down_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_downskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_unchanged_r.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_unchanged[mask], errors=coerce))*100,2)))

#### Not recession - != 2008q2-2012q1
mask = df_all.GBRRECDM1!=1.0
## 25th
# total
with open(cwd + "/Figures/wages_all_25_up_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_upskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_down_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_downskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_25_unchanged_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p25_unchanged[mask], errors=coerce))*100,2)))
## 50th
# total
with open(cwd + "/Figures/wages_all_50_up_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_upskill[mask], errors=coerce))*100,2)))
Total_up_nr = np.round(np.mean(pd.to_numeric(df_all.p50_upskill[mask], errors=coerce))*100,2) 
with open(cwd + "/Figures/wages_all_50_down_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_downskill[mask], errors=coerce))*100,2)))
Total_down_nr = np.round(np.mean(pd.to_numeric(df_all.p50_downskill[mask], errors=coerce))*100,2) 
with open(cwd + "/Figures/wages_all_50_unchanged_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p50_unchanged[mask], errors=coerce))*100,2)))
Total_unchanged_nr = np.round(np.mean(pd.to_numeric(df_all.p50_unchanged[mask], errors=coerce))*100,2) 
## 75th
# total
with open(cwd + "/Figures/wages_all_75_up_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_upskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_down_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_downskill[mask], errors=coerce))*100,2)))
with open(cwd + "/Figures/wages_all_75_unchanged_nr.txt", "w") as text_file:
    text_file.write(str(np.round(np.mean(pd.to_numeric(df_all.p75_unchanged[mask], errors=coerce))*100,2)))


df_all.drop(df_all.tail(1).index,inplace=True)

mask = df_all.p25_downskill!='.'

## TOTAL
# upskill vs downskill
with open(cwd + "/Figures/up_down_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_upskill[mask]),pd.to_numeric(df_all.p25_downskill[mask]), equal_var=False),2)))
with open(cwd + "/Figures/up_down_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_upskill[mask]),pd.to_numeric(df_all.p50_downskill[mask]), equal_var=False),2)))
with open(cwd + "/Figures/up_down_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_upskill[mask]),pd.to_numeric(df_all.p75_downskill[mask]), equal_var=False),2)))
print 'UPSKILL VS. DOWNSKILL'
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_upskill[mask]),pd.to_numeric(df_all.p25_downskill[mask]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_upskill[mask]),pd.to_numeric(df_all.p50_downskill[mask]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_upskill[mask]),pd.to_numeric(df_all.p75_downskill[mask]), equal_var=False))
print ''

mask = df_all.p25_unchanged!='.'

## TOTAL
# upskill vs unchanged
with open(cwd + "/Figures/up_unchange_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_upskill[mask]),pd.to_numeric(df_all.p25_unchanged[mask]), equal_var=False),2)))
with open(cwd + "/Figures/up_unchange_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_upskill[mask]),pd.to_numeric(df_all.p50_unchanged[mask]), equal_var=False),2)))
with open(cwd + "/Figures/up_unchange_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_upskill[mask]),pd.to_numeric(df_all.p75_unchanged[mask]), equal_var=False),2)))
print 'UPSKILL VS. UNCHANGED'
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_unchanged[mask]),pd.to_numeric(df_all.p25_upskill[mask]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_unchanged[mask]),pd.to_numeric(df_all.p50_upskill[mask]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_unchanged[mask]),pd.to_numeric(df_all.p75_upskill[mask]), equal_var=False))
print ''


mask = df_all.p25_unchanged!='.'
## TOTAL
# downskill vs unchanged
with open(cwd + "/Figures/down_unchange_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_downskill[mask]),pd.to_numeric(df_all.p25_unchanged[mask]), equal_var=False),2)))
with open(cwd + "/Figures/down_unchange_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_downskill[mask]),pd.to_numeric(df_all.p50_unchanged[mask]), equal_var=False),2)))
with open(cwd + "/Figures/down_unchange_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_downskill[mask]),pd.to_numeric(df_all.p75_unchanged[mask]), equal_var=False),2)))
print 'DOWNSKILL VS. UNCHANGED'
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_unchanged[mask]),pd.to_numeric(df_all.p25_downskill[mask]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_unchanged[mask]),pd.to_numeric(df_all.p50_downskill[mask]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_unchanged[mask]),pd.to_numeric(df_all.p75_downskill[mask]), equal_var=False))
print ''

mask_r = (df_all.GBRRECDM1==1.0) & (df_all.p25_downskill!='.')
mask_nr = (df_all.GBRRECDM1!=1.0) & (df_all.p25_downskill!='.')
print 'UPSKILL RECESSION VS UPSKILL NO RECESSION'
# TOTAL
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_upskill[mask_r]),pd.to_numeric(df_all.p25_upskill[mask_nr]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_upskill[mask_r]),pd.to_numeric(df_all.p50_upskill[mask_nr]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_upskill[mask_r]),pd.to_numeric(df_all.p75_upskill[mask_nr]), equal_var=False))
print ''
with open(cwd + "/Figures/upRes_upNoRes_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_upskill[mask_r]),pd.to_numeric(df_all.p25_upskill[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/upRes_upNoRes_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_upskill[mask_r]),pd.to_numeric(df_all.p50_upskill[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/upRes_upNoRes_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_upskill[mask_r]),pd.to_numeric(df_all.p75_upskill[mask_nr]), equal_var=False),2)))

mask_r = (df_all.GBRRECDM1==1.0) & (df_all.p25_downskill!='.')
mask_nr = (df_all.GBRRECDM1!=1.0) & (df_all.p25_downskill!='.')
print 'DOWNSKILL RECESSION VS DOWNSKILL NO RECESSION'
# TOTAL
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_downskill[mask_r]),pd.to_numeric(df_all.p25_downskill[mask_nr]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_downskill[mask_r]),pd.to_numeric(df_all.p50_downskill[mask_nr]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_downskill[mask_r]),pd.to_numeric(df_all.p75_downskill[mask_nr]), equal_var=False))
print ''
with open(cwd + "/Figures/downRes_downNoRes_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_downskill[mask_r]),pd.to_numeric(df_all.p25_downskill[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/downRes_downNoRes_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_downskill[mask_r]),pd.to_numeric(df_all.p50_downskill[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/downRes_downNoRes_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_downskill[mask_r]),pd.to_numeric(df_all.p75_downskill[mask_nr]), equal_var=False),2)))

mask_r = (df_all.GBRRECDM1==1.0) & (df_all.p25_unchanged!='.')
mask_nr = (df_all.GBRRECDM1!=1.0) & (df_all.p25_unchanged!='.')
print 'UNCHANGED RECESSION VS UNCHANGED NO RECESSION'
# TOTAL
print ''
print 'TOTAL 25: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p25_unchanged[mask_r]),pd.to_numeric(df_all.p25_unchanged[mask_nr]), equal_var=False))
print 'TOTAL 50: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p50_unchanged[mask_r]),pd.to_numeric(df_all.p50_unchanged[mask_nr]), equal_var=False))
print 'TOTAL 75: '+ str(sps.ttest_ind(pd.to_numeric(df_all.p75_unchanged[mask_r]),pd.to_numeric(df_all.p75_unchanged[mask_nr]), equal_var=False))
print ''
with open(cwd + "/Figures/unchangeRes_unchangeNoRes_total_25.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p25_unchanged[mask_r]),pd.to_numeric(df_all.p25_unchanged[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/unchangeRes_unchangeNoRes_total_50.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p50_unchanged[mask_r]),pd.to_numeric(df_all.p50_unchanged[mask_nr]), equal_var=False),2)))
with open(cwd + "/Figures/unchangeRes_unchangeNoRes_total_75.txt", "w") as text_file:
	text_file.write(str(np.round(sps.ttest_ind(pd.to_numeric(df_all.p75_unchanged[mask_r]),pd.to_numeric(df_all.p75_unchanged[mask_nr]), equal_var=False),2)))

# plot median 	
labels = ['Upskill', 'Downskill', 'Unchanged']
#upskill = [EE_up, EE_up_r, EE_up_nr]
#downskill = [EE_down, EE_down_r, EE_down_nr]
#unchanged = [EE_unchanged, EE_unchanged_r, EE_unchanged_nr]

Whole = [Total_up, Total_down, Total_unchanged]
Recession = [Total_up_r, Total_down_r, Total_unchanged_r]
NoRecession = [Total_up_nr, Total_down_nr, Total_unchanged_nr]

x = np.arange(len(labels))  # the label locations
width = 0.30  # the width of the bars

fig, ax = plt.subplots()
rects1 = ax.bar(x - width, Whole, width, label='Whole Sample',color="gray")
rects2 = ax.bar(x, Recession, width, label='Recession',color="black")
rects3 = ax.bar(x + width, NoRecession, width, label='No Recession',color="white")

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('% Real Wage Change')
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.set_ylim(0,10) #np.max([np.max(Whole),np.max(Recession),np.max(NoRecession)])+5)
ax.legend()



def autolabel(rects):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width()/ 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')


autolabel(rects1)
autolabel(rects2)
autolabel(rects3)

#fig.tight_layout()

plt.savefig(cwd + '/Figures/TotalMedianWages.pdf')
	
