# this is a cheap and dirty fix - CHANGE ME
import os
cwd = os.getcwd()
import numpy as np
import re


temp = np.array([])
with open(cwd + '/Results/EstimationLog.txt', 'r') as file:
    for line in file.readlines():
        if 'Pseudo R2' in line:
            temp = np.append(temp,line[-7:].rstrip())
            
temp_N = np.array([])
with open(cwd + '/Results/EstimationLog.txt', 'r') as file:
    for line in file.readlines():
        if 'Number of obs' in line:
            temp_N = np.append(temp_N,line[-7:].rstrip())
            
temp_LL = np.array([])
with open(cwd + '/Results/EstimationLog.txt', 'r') as file:
    for line in file.readlines():
        result = re.search('{txt}Log likelihood = {res}(.*){txt}', line)
        result2 = re.search('{txt}Log pseudolikelihood = {res}(.*){txt}', line)
        if result!= None:
            temp_LL = np.append(temp_LL,result.group(1))
        elif result2!= None:
            temp_LL = np.append(temp_LL,result2.group(1))
         

with open(cwd + '/Results/dh_pseudor2_angSep_probit.txt', 'w') as file:
    file.write(temp[2])
with open(cwd + '/Results/dh_N_angSep_probit.txt', 'w') as file:
    file.write(temp_N[2])
with open(cwd + '/Results/dh_LL_angSep_probit.txt', 'w') as file:
    file.write(temp_LL[2])
    
    
with open(cwd + '/Results/dh_pseudor2_angSep.txt', 'w') as file:
    file.write(temp[4])
with open(cwd + '/Results/dh_N_angSep.txt', 'w') as file:
    file.write(temp_N[4])
with open(cwd + '/Results/dh_LL_angSep.txt', 'w') as file:
    file.write(temp_LL[4])
    
    
with open(cwd + '/Results/dh_pseudor2_modOfMod_probit.txt', 'w') as file:
    file.write(temp[5])
with open(cwd + '/Results/dh_N_modOfMod_probit.txt', 'w') as file:
    file.write(temp_N[5])
with open(cwd + '/Results/dh_LL_modOfMod_probit.txt', 'w') as file:
    file.write(temp_LL[5])
    
with open(cwd + '/Results/dh_pseudor2_modOfMod.txt', 'w') as file:
    file.write(temp[7])
with open(cwd + '/Results/dh_N_modOfMod.txt', 'w') as file:
    file.write(temp_N[7])
with open(cwd + '/Results/dh_LL_modOfMod.txt', 'w') as file:
    file.write(temp_LL[7])
    
with open(cwd + '/Results/tobit4_pseudor2_angSep.txt', 'w') as file:
    file.write(temp[9])
with open(cwd + '/Results/tobit4_N_angSep.txt', 'w') as file:
    file.write(temp_N[9])
with open(cwd + '/Results/tobit4_LL_angSep.txt', 'w') as file:
    file.write(temp_LL[9])

with open(cwd + '/Results/tobit4_pseudor2_modOfMod.txt', 'w') as file:
    file.write(temp[10])
with open(cwd + '/Results/tobit4_N_modOfMod.txt', 'w') as file:
    file.write(temp_N[10])
with open(cwd + '/Results/tobit4_LL_modOfMod.txt', 'w') as file:
    file.write(temp_LL[10])
    
with open(cwd + '/Results/tobit1_pseudor2_angSep.txt', 'w') as file:
    file.write(temp[11])
with open(cwd + '/Results/tobit1_N_angSep.txt', 'w') as file:
    file.write(temp_N[11])
with open(cwd + '/Results/tobit1_LL_angSep.txt', 'w') as file:
    file.write(temp_LL[11])

with open(cwd + '/Results/tobit1_pseudor2_modOfMod.txt', 'w') as file:
    file.write(temp[12])
with open(cwd + '/Results/tobit1_N_modOfMod.txt', 'w') as file:
    file.write(temp_N[12])
with open(cwd + '/Results/tobit1_LL_modOfMod.txt', 'w') as file:
    file.write(temp_LL[12])




