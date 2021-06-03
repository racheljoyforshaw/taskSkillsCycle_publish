# encoding=utf8

import json
from urllib.request import urlopen
import csv
import numpy as np
import os
from itertools import chain
import pandas as pd

cwd = os.getcwd() # CHANGE BACK

# define a function that gets data from LMIforall API
def get_Data(method,parameter,value=''):
    """ Return data from LMIforall API
    IN:
    method: string. see list of methods at http://api.lmiforall.org.uk/#/
        e.g. 'o-net'
    parameter: string. see parameters of methods at above url
        e.g. 'abilities'
    value: optional string. see values of methods at above url
        e.g. '27-2041.01' (O*NET occupation code for 'Music Director')
    """
    if value == '':
         data = urlopen("http://api.lmiforall.org.uk/api/v1/" + method +
                           '/'+ parameter)
    else:
        data = urlopen("http://api.lmiforall.org.uk/api/v1/" + method +
                           '/'+ parameter + '/' + value)
        
    wjson = data.read()
    wjdata = json.loads(wjson)
    return wjdata

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


# write to csv
def write_csv(filename,method,weighting,dict1,dict2,ALM=None):
    # check if same dictionary
    isSameDict = dict1==dict2
    # open up the csv file to write to
    with open(cwd + '/Inputs/' + filename, 'w') as csvfile:
        fieldnames = ['SOCcode1','SOCcode2',method]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        if isSameDict:
            # calculate upper triangular of cross-angularSeparation matrix
            for i in range(len(dict1[weighting].keys())):
                for j in range(i+1):
                    socCode1 = dict1[weighting].keys()[i]
                    socCode2 = dict2[weighting].keys()[j]
                    if method=='angSep':
                        writer.writerow({'SOCcode1':socCode1,'SOCcode2':socCode2, \
                        method:angularSeparation(socCode1,socCode2,weighting,dict1,dict2,ALM)})
                    elif method=='modOfMod':
                        writer.writerow({'SOCcode1':socCode1,'SOCcode2':socCode2, \
                        method:modOfMod(socCode1,socCode2,weighting,dict1,dict2,ALM)})
                    # plus upper triangular of reverse cross-angularSeparation matrix minus the diagonal
                    # (on diagonal the two codes are the same)
                    if socCode1!=socCode2:
                        if method=='angSep':
                            writer.writerow({'SOCcode1':socCode2,'SOCcode2':socCode1, \
                            method:angularSeparation(socCode2,socCode1,weighting,dict2,dict1,ALM)})
                        elif method=='modOfMod':
                            writer.writerow({'SOCcode1':socCode2,'SOCcode2':socCode1, \
                            method:modOfMod(socCode2,socCode1,weighting,dict2,dict1,ALM)})
        else:
            # different dictionaries, so just calculate the entire matrix
            for i in range(max(len(dict1[weighting].keys()),len(dict2[weighting].keys()))): # row
                for j in range(min(len(dict1[weighting].keys()),len(dict2[weighting].keys()))): # column
                    if len(dict1[weighting].keys())>=len(dict2[weighting].keys()):
                        socCode1 = dict1[weighting].keys()[i]
                        socCode2 = dict2[weighting].keys()[j]
                    else:
                        socCode1 = dict1[weighting].keys()[j]
                        socCode2 = dict2[weighting].keys()[i]
                    if method=='angSep':
                        writer.writerow({'SOCcode1':socCode1,'SOCcode2':socCode2, \
                        method:angularSeparation(socCode1,socCode2,weighting,dict1,dict2,ALM)})
                    elif method=='modOfMod':
                        writer.writerow({'SOCcode1':socCode1,'SOCcode2':socCode2, \
                        method:modOfMod(socCode1,socCode2,weighting,dict1,dict2,ALM)})
  
  #############################################################################################################################
# make a dictionary for the ONET codes and put in excel file
with open(cwd + '/Inputs/ONETdata.csv', 'w') as csvfile:
    fieldnames = ['onetCode','parameter','task','scale', 'value']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    ONETdict = {}
    for onetCode in ONETcodes:
        # add O*NET code
        ONETdict[onetCode] = {}
        # loop through skills, abilities, etc...
        for parameter in taskDict.keys():
            # empty entries for skills, abilities, interests and knowledge
            ONETdict[onetCode][parameter] = {}
            temp_data = get_Data('o-net',parameter,onetCode) # get ONET data
            for scale in range(len(temp_data['scales'])):
                ONETdict[onetCode][parameter][temp_data['scales'][scale]['id']] = {}
                for task in range(len(temp_data['scales'][scale][parameter])):
                    ONETdict[onetCode][parameter][temp_data['scales'][scale]['id']][temp_data['scales'][scale][parameter][task]['name']] =\
                    (temp_data[u'scales'][scale][parameter][task][u'value'] - \
                                scalesDict[temp_data[u'scales'][scale][u'id']]['min'])/scalesDict[temp_data[u'scales'][scale][u'id']]['scalingFactor']
                    writer.writerow({'onetCode':onetCode,'parameter':parameter, \
                                     'task':temp_data['scales'][scale][parameter][task]['name'], \
                                     'scale':temp_data['scales'][scale]['id'],\
                                     'value':ONETdict[onetCode][parameter][temp_data['scales'][scale]['id']][temp_data['scales'][scale][parameter][task]['name']]})
                                     
###########################################################################################################################
# MAIN CLASS - to create SOC-ONET dictionaries
#############################################################################################################################
class SOCdict:
    # initialise the class
    def __init__(self, name):
        self.name = name
        self.year = self.name[3:]
        self.mapping = {}
        self.dict = {}
    
    # add mapping dictionaries
    #def add_CASCOTmapping(self, CASCOTdata):
    #    # import CASCOT mapping from csv
    #    CASCOTtemp= np.zeros((1,3))
    #    data = list(csv.reader(open(CASCOTdata)))
    #    for line in data:
    #        CASCOTtemp = \
    #        np.vstack((CASCOTtemp,\
    #                   np.hstack((line[2],line[1],line[0])))) # score in 0, O*NET in 1, SOCcode in 2
    #    # remove first 2 lines - just header
    #    CASCOTtemp = CASCOTtemp[2:]
    #    # take only unique values
    #    CASCOTtemp = np.unique(CASCOTtemp,axis=0)
    #    # add to self
    #    self.CASCOTmapping.append(CASCOTtemp)
    #    self.CASCOTmapping = self.CASCOTmapping[0]
    
    def add_mapping(self,data,mapping_type):
        if mapping_type=='CASCOT':
            # import CASCOT mapping from csv
            temp= np.zeros((1,3))
            temp_data = list(csv.reader(open(data)))
            for line in temp_data:
                temp = \
                np.vstack((temp,\
                       np.hstack((line[2],line[1],line[0])))) # score in 0, O*NET in 1, SOCcode in 2
            # remove first 2 lines - just header
            temp = temp[2:]
            # take only unique values
            temp = np.unique(temp,axis=0)
        elif mapping_type=='rawAverage':
            # import socCode mapping from csv
            temp2= np.zeros((1,3))
            temp_data = list(csv.reader(open(data)))
            for line in temp_data:
                temp2 = \
                    np.vstack((temp2,\
                        np.hstack((line[0],line[1],line[2])))) # 90 in 0, 2000 in 1, 2010 in 2
            # remove first 2 lines - just header
            temp2 = temp2[2:]
            # choose correct column of socCode data
            if self.year=='90':
                column = 0
            elif self.year=='2000':
                column = 1
            elif self.year=='2010':
                column = 2
            # set up array with socCodes in first column, onetCodes in second
            temp = np.zeros((1,2))
            for socCode in np.unique(temp2[:,column]):
                # find the matching 2010 codes
                if column==2:
                    soc2010codes = [socCode]
                else:
                    soc2010codes = temp2[:,2][[item for item in range(len(temp2[:,2])) if temp2[item,column] == socCode]]
                # find the matching O*NET codes
                onetCodes = np.array('deleteMe')
                for soc2010code in soc2010codes:
                    onetCodes = np.append(onetCodes, SOC2010_ONETmapping[:,1][[item for item in range(len(SOC2010_ONETmapping[:,1])) \
                            if  SOC2010_ONETmapping[item,0]==soc2010code]])
                onetCodes = np.unique(onetCodes[1:])
                for onetCode in onetCodes:
                    temp = np.vstack((temp,\
                            np.hstack((socCode,onetCode))))
            temp = temp[1:,:]
    
        # add to self
        self.mapping[mapping_type] = {}
        self.mapping[mapping_type] = temp
        
        
    #def add_rawAverageMapping(self, rawAverageData):
    #    # import raw average mapping from csv
    #    rawAverageTemp= np.zeros((1,3))
    #    data = list(csv.reader(open(rawAverageData)))
    #    for line in data:
    #        rawAverageTemp = \
    #        np.vstack((rawAverageTemp,\
    #                   np.hstack((line[0],line[1],line[2])))) # 90 in 0, 2000 in 1, 2010 in 2
    #    # remove first 2 lines - just header
    #    rawAverageTemp = rawAverageTemp[2:]
    #    # take only unique values
    #    rawAverageTemp = np.unique(rawAverageTemp,axis=0)
    #    # add to self
    #    self.rawAverageMapping.append(rawAverageTemp)
    #    self.rawAverageMapping = self.rawAverageMapping[0]
    
    # create a dictionary with O*NET data
    def create_dict(self,mapping_list,isWeighted):
        for mapping in mapping_list:
            # add the mapping
            self.dict[mapping] = {}
            for socCode in np.unique(self.mapping[mapping][:,0]): # for each socCode in mapping dictionary
                # add the socCode
                self.dict[mapping][socCode] = {}
                # find all matching onet codes
                temp_onet = [item for item in range(len(self.mapping[mapping][:,1])) \
                         if self.mapping[mapping][item,0] == socCode]
                # make an entry for the onetCodes and weights
                self.dict[mapping][socCode]['onetCodes'] = self.mapping[mapping][:,1][temp_onet]
                self.dict[mapping][socCode]['weights'] = {}
                # loop through skills, abilities, etc...
                for parameter in taskDict.keys():
                    # parameters
                    self.dict[mapping][socCode][parameter] = {}
                    # add the weight
                    if isWeighted:
                        self.dict[mapping][socCode]['weights'][parameter] = self.mapping[mapping][:,2][temp_onet].astype(float)
                    else:
                        self.dict[mapping][socCode]['weights'][parameter] = np.ones(len(temp_onet))
                    # tasks
                    for task in taskDict[parameter]:
                        self.dict[mapping][socCode][parameter][task] = {}
                        tempArray_LV = []
                        # for each onet code
                        for onetCode in range(len(self.dict[mapping][socCode]['onetCodes'])):
                            try:
                                # add data from the ONET dictionary - level
                                tempArray_LV = \
                                    np.append(tempArray_LV, \
                                          ONETdict[self.dict[mapping][socCode]['onetCodes'][onetCode]][parameter]['LV'][task])
                                
                            except:
                                # no data
                                tempArray_LV = np.append(tempArray_LV, 5000.0)
                                
                        # add data
                        self.dict[mapping][socCode][parameter][task]['LV'] = tempArray_LV
                    
                    # Figure out 'missing' and 'zero' data
                    # set the weight to zero for missing data
                    # here: 'missing' if all parameter data is empty for given onetCode
                    lst  = [x['LV'] for x in self.dict[mapping][socCode][parameter].values()]
                    for arrayPos in range(len(lst[0])):
                        temp =[item[arrayPos] for item in lst]
                        if all(item == 5000.0 for item in temp):
                            self.dict[mapping][socCode]['weights'][parameter][arrayPos] = 0.0
                    # set the data to zero for missing instances
                    # here: 'missing' for a single o*net, single task
                    for task in taskDict[parameter]:
                        for onetCode in range(len(self.dict[mapping][socCode]['onetCodes'])):
                            if self.dict[mapping][socCode][parameter][task]['LV'][onetCode]==5000.0:
                                self.dict[mapping][socCode][parameter][task]['LV'][onetCode]=0.0
                            
                   
                # get rid of socCode if all data missing
                temp = [item for sublist in self.dict[mapping][socCode]['weights'].values() for item in sublist]
                if all(item == 0.0 for item in temp):
                    del self.dict[mapping][socCode]
                    continue
                # calculate the averages
                for parameter in taskDict.keys():
                    # renormalise between 0 and 1
                    if np.sum(self.dict[mapping][socCode]['weights'][parameter])==0.0:
                        print(socCode, parameter)
                    elif isWeighted:
                        self.dict[mapping][socCode]['weights'][parameter] = self.dict[mapping][socCode]['weights'][parameter]/\
                            np.sum(self.dict[mapping][socCode]['weights'][parameter])
                    for task in taskDict[parameter]:
                        if isWeighted:
                            # weighted average
                            self.dict[mapping][socCode][parameter][task]['average'] = np.dot(self.dict[mapping][socCode][parameter][task]['LV'],\
                                                                            self.dict[mapping][socCode]['weights'][parameter].astype(float))
                        else:
                            # straight average
                            self.dict[mapping][socCode][parameter][task]['average'] = np.dot(self.dict[mapping][socCode][parameter][task]['LV'],\
                                                                            self.dict[mapping][socCode]['weights'][parameter].astype(float))/\
                            np.sum(self.dict[mapping][socCode]['weights'][parameter].astype(float))
                            
#############################################################################################################################
# import O*NET codes from csv

# first the mapping between SOC codes
ONETcodes = []
data = list(csv.reader(open(cwd + "/Inputs/ONETcodes.csv")))
for line in data:
    ONETcodes = np.append(ONETcodes,line[0])
# remove first 2 lines - just header
ONETcodes = np.unique(ONETcodes[2:],axis=0)

del data, line

#############################################################################################################################
# make a dictionary of all skills, abilities, interests and knowledge
taskDict = {}
taskDict['skills'] = []
taskDict['abilities'] = []
#taskDict['interests'] = []
taskDict['knowledge'] = []
wjdata_id = get_Data('o-net','identifiers')
  
for line in range(0,len(wjdata_id)):
    # NOTE: can't simplify this because of inconsistencies in naming conventions
    # in the LMI (here 'skill', elsewhere 'skills')
    if wjdata_id[line][u'category']=='skill':
        taskDict['skills'] = np.append(taskDict['skills'], wjdata_id[line][u'name'])
    elif wjdata_id[line][u'category']=='ability':
        taskDict['abilities'] = np.append(taskDict['abilities'], wjdata_id[line][u'name'])
    #elif wjdata_id[line][u'category']=='interest':
    #    taskDict['interests'] = np.append(taskDict['interests'], wjdata_id[line][u'name'])
    elif wjdata_id[line][u'category']=='knowledge':
        taskDict['knowledge'] = np.append(taskDict['knowledge'], wjdata_id[line][u'name'])

# get data to normalise all the scores (they have different ranges)
scales_Data = get_Data('o-net','scales')
scalesDict= {}
for line in range(0,len(scales_Data)):
    scalesDict[scales_Data[line][u'id']]= {} # id
    scalesDict[scales_Data[line][u'id']]['min'] = scales_Data[line][u'min'] # min
    scalesDict[scales_Data[line][u'id']]['max'] = scales_Data[line][u'max'] # max
    scalesDict[scales_Data[line][u'id']]['scalingFactor'] = scalesDict[scales_Data[line][u'id']]['max'] - \
        scalesDict[scales_Data[line][u'id']]['min'] # max normalised to zero - min

del scales_Data, wjdata_id, line

# import file names to be created from csv

fileNames = {}
data = list(csv.reader(open(cwd +"/Inputs/ListOfAllAngSepFiles.csv")))
for column in range(1,len(data[0])):
    fileNames[data[0][column]] = {}
    for line in data[1:]:
        fileNames[data[0][column]][line[0]] = line[column]
        
del data, column, line

# import socCode mapping between years
temp_socData = np.zeros((1,3))
temp_data = list(csv.reader(open(cwd +'/Inputs/UniqueSOC2010.csv')))
for line in temp_data:
    temp_socData = \
    np.vstack((temp_socData,\
               np.hstack((line[0],line[1],line[2])))) # 90 in 0, 2000 in 1, 2010 in 2
# remove first 2 lines - just header
temp_socData = temp_socData[2:]
# take only unique values
temp_socData = np.unique(temp_socData,axis=0)
    
SOC2010_ONETmapping = np.zeros((1,2))
for socCode in temp_socData[:,2]:
    # find matching O*NET codes
    temp_onet = get_Data('o-net','soc2onet',str(socCode))
    for onetCode in range(len(temp_onet[u'onetCodes'])):
        SOC2010_ONETmapping = np.vstack((SOC2010_ONETmapping,np.hstack((socCode,temp_onet[u'onetCodes'][onetCode][u'code']))))
        
# CREATE DICTIONARIES, OUTPUT angularSeparation AND modOfMod TO EXCEL FILES
# create dictionaries of ONET scores and weightings for each year
SOC90 = SOCdict('SOC90')
SOC2000 = SOCdict('SOC2000')
SOC2010 = SOCdict('SOC2010')
# add mappings
# CASCOT
SOC90.add_mapping(cwd +'/Inputs/CASCOT2011ONETMatches_90.csv','CASCOT')
SOC2000.add_mapping(cwd +'/Inputs/CASCOT2011ONETMatches_2000.csv','CASCOT')
SOC2010.add_mapping(cwd +'/Inputs/CASCOT2011ONETMatches_2010.csv','CASCOT')
# Raw Average
SOC90.add_mapping(cwd +'/Inputs/UniqueSOC2010.csv','rawAverage')
SOC2000.add_mapping(cwd +'/Inputs/UniqueSOC2010.csv','rawAverage')
SOC2010.add_mapping(cwd +'/Inputs/UniqueSOC2010.csv','rawAverage')
# create dictionaries
# CASCOT
SOC90.create_dict(['CASCOT'],isWeighted=True)
SOC2000.create_dict(['CASCOT'],isWeighted=True)
SOC2010.create_dict(['CASCOT'],isWeighted=True)
# Raw Average
SOC90.create_dict(['rawAverage'],isWeighted=False)
SOC2000.create_dict(['rawAverage'],isWeighted=False)
SOC2010.create_dict(['rawAverage'],isWeighted=False)

# output files for each method
for year in ['90','2000','2010']:
    for method in ['angSep','modOfMod']:
        for weighting in ['CASCOT']: # fileNames.keys():
            write_csv(method + fileNames[weighting][year + 's'],method,weighting,eval('SOC'+ year + '.dict'),eval('SOC'+ year + '.dict'))
            
##### motivation - distributions of within/across moves

from itertools import chain
# find all combinations of angular separation

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

import pandas as pd
df_diff = pd.DataFrame({'diff':all_angSep_diff1Digit_list})
df_same = pd.DataFrame({'same':all_angSep_same1Digit_list})

# quantiles of distribution

import pandas as pd
df_diff = pd.DataFrame({'diff':all_angSep_diff1Digit_list})
df_same = pd.DataFrame({'same':all_angSep_same1Digit_list})


#print df_diff['diff'].quantile([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1])
#print 'mean ' + str(df_diff['diff'].mean())
#print 'std ' + str(df_diff['diff'].std())

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
