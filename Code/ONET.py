# encoding=utf8

import json
import urllib2
import csv
import numpy as np
import os
from itertools import chain
import pandas as pd

cwd = os.getcwd()

####################################### Set up SOC dictionary #######################################



####################################### Functions #######################################


# define task distance measure
def angularSeparation(soc1,soc2,weighting,dict1,dict2,ALM=None):
    """ Returns Gathmann & Schönberg (2010) measure of 
    angular separation
    IN: 
    soc1: SOC code for occupation 1 (o) in dict1
    soc2: SOC code for occupation 2 (o') in dict2
    weighting: 'CASCOT'
    dict1: originating SOC dictionary
    dict2: other SOC dictionary
    OUT:
    1-\frac{\sum_{t=1}^{T}(q_{t,o}\times q_{t,o'})}{((\sum_{t=1}^{T} q_{t,o}^2)\times(\sum_{t=1}^{T} q_{t,o'}^2))^{(1/2)}}
    return is 1 if occupations are completely different in every task, 0 if occupations the same in every task
    will be continuous measure between 0 and 1
    """
    if dict1==dict2 and soc1==soc2:
        return 0.0 
    else:
        # create an empty array
        temp_len = 0
        # calculate total length needed for the empty array
        for parameter in taskDict.keys():
            temp_len = temp_len + len(taskDict[parameter])
        numerator_temp = np.zeros((temp_len,1))
        denom_temp1 = np.zeros(numerator_temp.shape)
        denom_temp2 = np.zeros(numerator_temp.shape)
        t = 0
        for parameter in taskDict.keys(): # skill/ability/knowledge
            # looking at ALM subset of tasks?
            if ALM!=None:
                taskList = ONET_ALM[ALM]
            else:
                taskList = taskDict
            for task in taskList[parameter]: # type of skill...etc
                numerator_temp[t] = dict1[weighting][soc1][parameter][task]['average']*dict2[weighting][soc2][parameter][task]['average']
                denom_temp1[t] = dict1[weighting][soc1][parameter][task]['average']**2.0
                denom_temp2[t] = dict2[weighting][soc2][parameter][task]['average']**2.0
                t = t+1
        # deal with task data all zeros 
        if (np.sum(denom_temp1)*np.sum(denom_temp2))==0.0:
            angSep=1.0
        else:
            angSep = np.abs(1.0-(np.sum(numerator_temp)/((np.sum(denom_temp1)*np.sum(denom_temp2))**(1.0/2.0))))
        # deal with rounding error (in cross-year dictionaries)
        if angSep<1e-08:
            return 0.0
        else:
            return angSep
        
# define skill distance measure
def modOfMod(soc1,soc2,weighting,dict1,dict2,ALM=None):
    """ Returns measure of separation on scale information
    IN: 
    soc1: SOC code for occupation 1 (o) in dict1
    soc2: SOC code for occupation 2 (o') in dict2
    weighting: 'CASCOT'
    dict1: originating SOC dictionary
    dict2: other SOC dictionary
    OUT:
    0 if occupations the same level in every skill
    -1/1 if occupations different level in every skill
    will be continuous measure between -1 and 1
    """
    if dict1==dict2 and soc1==soc2:
        return 0.0
    else:
        # create an empty array
        temp_len = 0
        # calculate total length needed for the empty array
        for parameter in taskDict.keys():
            temp_len = temp_len + len(taskDict[parameter])
        numerator_temp1 = np.zeros((temp_len,1))
        numerator_temp2 = np.zeros((temp_len,1))
        t = 0
        for parameter in taskDict.keys(): # skill/ability/knowledge
            # looking at ALM subset of tasks?
            if ALM!=None:
                taskList = ONET_ALM[ALM]
            else:
                taskList = taskDict
            for task in taskList[parameter]: # type of skill...etc
                numerator_temp1[t] = dict1[weighting][soc1][parameter][task]['average']**2.0
                numerator_temp2[t] = dict2[weighting][soc2][parameter][task]['average']**2.0
                t = t+1
        modOfMod = ((np.sqrt(np.sum(numerator_temp2))\
                     - np.sqrt(np.sum(numerator_temp1)))/np.sqrt(t)) + 0 # this is to avoid returning negative zero
        # deal with rounding error (in cross-year dictionaries)
        if np.abs(modOfMod)<1e-08:
            return 0.0
        else:
            return modOfMod


####################################### Calculate distributions of within/across moves #######################################

# find all one-digit possibilities
SOC_1digits = []
for key in SOC2010.dict['CASCOT'].keys():
    SOC_1digits.append(key[0])
SOC_1digits = np.unique(SOC_1digits)


# find all possible within moves
all_angSep_same1Digit = []
all_angSep_same1Digit_list = []
for socDigit in SOC_1digits:
    keys=[]
    for key in SOC2010.dict['CASCOT'].keys():
        if socDigit==key[0]:
            keys.append(key)
    all_angSep_same1Digit.append(np.zeros((len(keys),len(keys))))
    i = 0
    j = 0
    for key1 in keys:
        for key2 in keys:
            all_angSep_same1Digit[int(socDigit)-1][i,j] = angularSeparation(key1,key2,'CASCOT',SOC2010.dict,SOC2010.dict,ALM=None)
            j = j + 1  
        i = i + 1
        j=0
    temp = np.triu(all_angSep_same1Digit[int(socDigit)-1]).tolist()
    all_angSep_same1Digit_list.append(list(chain.from_iterable(temp)))
all_angSep_same1Digit_list = list(chain.from_iterable(all_angSep_same1Digit_list))


# find all possible across moves
all_angSep_diff1Digit = []
all_angSep_diff1Digit_list = []
for socDigit in SOC_1digits:
    keys=[]
    for key in SOC2010.dict['CASCOT'].keys():
        if socDigit!=key[0]:
            keys.append(key)
    all_angSep_diff1Digit.append(np.zeros((len(keys),len(keys))))
    i = 0
    j = 0
    for key1 in keys:
        for key2 in keys:
            all_angSep_diff1Digit[int(socDigit)-1][i,j] = angularSeparation(key1,key2,'CASCOT',SOC2010.dict,SOC2010.dict,ALM=None)
            j = j + 1  
        i = i + 1
        j=0
    temp = np.triu(all_angSep_diff1Digit[int(socDigit)-1]).tolist()
    all_angSep_diff1Digit_list.append(list(chain.from_iterable(temp)))
all_angSep_diff1Digit_list = list(chain.from_iterable(all_angSep_diff1Digit_list))

import matplotlib.pyplot as plt
#%matplotlib inline
import seaborn as sn
sn.set_style('white')
# plot the angular separation distribution (within)
all_angSep_same1Digit_list = np.array(all_angSep_same1Digit_list)
#plt.hist(all_angSep_same1Digit_list[np.nonzero(all_angSep_same1Digit_list)], bins=100, color = "grey", ec="black")
#plt.title('Angular Separation Scores of Within-Occupation Moves')
plt.xlabel('Score')
plt.ylim([0,0.035])
plt.xlim([0,0.4])
ax1 = plt.gca()
mydata1 =all_angSep_same1Digit_list[np.nonzero(all_angSep_same1Digit_list)]
ax1.hist(mydata1, weights=np.zeros_like(mydata1) + 1. / mydata1.size, bins=100)
#ax.annotate("Mean=" + str(np.round(np.mean(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-1000))
#ax.annotate("Median=" + str(np.round(np.median(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-2000))
#ax.annotate("StDev=" + str(np.round(np.std(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-3000))
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
plt.rc('font', size=16)
plt.rc('axes', titlesize=16)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
plt.rc('font', size=16)
plt.rc('axes', titlesize=16)
plt.ylabel('Number of Occupation Pairs')
plt.draw()
plt.savefig(cwd + '/Figures/all_angSep_same1Digit_nonzero.pdf')
plt.close()

all_angSep_diff1Digit_list = np.array(all_angSep_diff1Digit_list)
#plt.hist(all_angSep_same1Digit_list[np.nonzero(all_angSep_same1Digit_list)], bins=100, color = "grey", ec="black")
#plt.title('Angular Separation Scores of Within-Occupation Moves')
plt.xlabel('Score')
plt.ylim([0,0.035])
plt.xlim([0,0.4])
ax2 = plt.gca()
mydata2 =all_angSep_diff1Digit_list[np.nonzero(all_angSep_diff1Digit_list)]
ax2.hist(mydata2, weights=np.zeros_like(mydata2) + 1. / mydata2.size, bins=100)
#ax.annotate("Mean=" + str(np.round(np.mean(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-1000))
#ax.annotate("Median=" + str(np.round(np.median(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-2000))
#ax.annotate("StDev=" + str(np.round(np.std(all_angSep_same1Digit_list),2)),xy=(max(all_angSep_same1Digit_list)-0.05,6000-3000))
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
plt.rc('font', size=16)
plt.rc('axes', titlesize=16)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
plt.rc('font', size=16)
plt.rc('axes', titlesize=16)
plt.ylabel('Number of Occupation Pairs')
plt.draw()
plt.savefig(cwd + '/Figures/all_angSep_diff1Digit_nonzero.pdf')

# quantiles of distribution


df_diff = pd.DataFrame({'diff':all_angSep_diff1Digit_list})
df_same = pd.DataFrame({'same':all_angSep_same1Digit_list})



df_test = pd.DataFrame({'Across 1-digit':df_diff['diff'].quantile([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1])})
with open(cwd + "/Figures/angSep_diff_quantile.txt", "w") as text_file:
    text_file.write(df_test.to_latex())
    

with open(cwd + "/Figures/angSep_diff_mean.txt", "w") as text_file:
    text_file.write(str(df_diff['diff'].mean()))
    
with open(cwd + "/Figures/angSep_diff_sd.txt", "w") as text_file:
    text_file.write(str(df_diff['diff'].std()))
    
    
#print df_same['same'].quantile([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1])
#print 'mean ' + str(df_same['same'].mean())
#print 'std ' + str(df_same['same'].std())

df_test = pd.DataFrame({'Within 1-digit':df_same['same'].quantile([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1])})
with open(cwd + "/Figures/angSep_same_quantile.txt", "w") as text_file:
    text_file.write(df_test.to_latex())
    
with open(cwd + "/Figures/angSep_same_mean.txt", "w") as text_file:
    text_file.write(str(df_same['same'].mean()))
    
with open(cwd + "/Figures/angSep_same_sd.txt", "w") as text_file:
    text_file.write(str(df_same['same'].std()))
