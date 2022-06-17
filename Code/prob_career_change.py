# code to create probability of changing careers by SOC digit graphs

#packages
import xml.etree.ElementTree as ET
import csv
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os

cwd = os.getcwd()


# import scalar mult factor (used in hack for weights)
mult_factor=[]
with open(cwd + '/Results/mult_factor.txt') as inputfile:
    for row in csv.reader(inputfile):
        mult_factor.append(int(row[0]))
mult_factor = mult_factor[0]

for i in [1,2,3,4]:
	tree = ET.parse(cwd + "/Results/Hm_data_" + str(i) + "_dem.xml")
	root = tree.getroot()


	master_list = []
	MS_OFFICE_SCHEMA_STR="{urn:schemas-microsoft-com:office:spreadsheet}"
	for child in root[4][0]: # iter through row # <-- should probably do "findall"
		dummy_list = []                         # recursively right through the whole tree
		#print "===="                            # for a more elegant solution
		if "Row" in child.tag:
			#print "Row: ", child.get(MS_OFFICE_SCHEMA_STR + "Index")
			for cell in child.findall(MS_OFFICE_SCHEMA_STR + "Cell"):
				#print "-Cell: ", cell.get(MS_OFFICE_SCHEMA_STR + "StyleID")
				for data in cell.findall(MS_OFFICE_SCHEMA_STR + "Data"):
					#print "--Data: ", data.get(MS_OFFICE_SCHEMA_STR + "Type"), ": ", data.text
					dummy_list = dummy_list + [data.text]
			master_list = master_list +[dummy_list]



	# get data in right format
	master_list[0][0] = 'date'
	if i==1:
		df = pd.DataFrame.from_records(master_list[1:], columns=master_list[0])
		df.date=pd.to_datetime(df.date)
		df.set_index(['date'],inplace=True)
		df.occ_Em_1 = pd.to_numeric(df.occ_Em_1, errors='coerce')/mult_factor
		df.occ_E2E_1 = pd.to_numeric(df.occ_E2E_1, errors='coerce')/mult_factor
		df['prob_1'] = df.occ_Em_1/df.occ_E2E_1
		
	else:
		temp_df =  pd.DataFrame.from_records(master_list[1:], columns=master_list[0])
		temp_df.date=pd.to_datetime(temp_df.date)
		temp_df.set_index(['date'],inplace=True)
		temp_df.iloc[:,0] = pd.to_numeric(temp_df.iloc[:,0], errors='coerce')/mult_factor
		temp_df.iloc[:,1] = pd.to_numeric(temp_df.iloc[:,1], errors='coerce')/mult_factor
		temp_df['prob_' + str(i)] = temp_df.iloc[:,0]/temp_df.iloc[:,1]
		df = df.join(temp_df)
#print df

df_graph = df[['prob_1','prob_2','prob_3','prob_4']].copy() 
df_graph.prob_1 = df_graph.prob_1.rolling(5, center=True).mean()
df_graph.prob_2 = df_graph.prob_2.rolling(5, center=True).mean()
df_graph.prob_3 = df_graph.prob_3.rolling(5, center=True).mean()
df_graph.prob_4 = df_graph.prob_4.rolling(5, center=True).mean()


# get rid of problematic quarters
df_graph.loc[(df.index >'2010q2') & (df.index<'2013q1')] = np.nan
df_graph.loc[(df.index <'2000q1') | (df.index>'2010q4')] = np.nan


recession_start1 = '2008q2'
recession_stop1 = '2010q1' 


# plot
df_graph = df_graph.rename( columns={"prob_1": "1 digit", "prob_2": "2 digit", "prob_3": "3 digit", "prob_4": "4 digit"})
styles=['k-', 'k--', 'k:','k-.']
ax = df_graph.plot(df_graph.index.values,style=styles)
ax.set_xlabel('Date')
ax.set_ylabel('Probability')
plt.axvspan(recession_start1,recession_stop1, color='k', alpha=0.2, lw=0)
# only show 2000s
plt.xlim((123, 163))
plt.savefig(cwd + '/Figures/prob_career_change.pdf')
