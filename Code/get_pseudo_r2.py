# this is a cheap and dirty fix - CHANGE ME
import os
cwd = os.getcwd()
import numpy as np

temp = np.array([])
with open(cwd + '/Results/EstimationLog.txt', 'r') as file:
    for line in file.readlines():
        if 'Pseudo R2' in line:
            temp = np.append(temp,line[-7:].rstrip())

with open(cwd + '/Results/dh_pseudor2_angSep.txt', 'w') as file:
    file.write(temp[4])
with open(cwd + '/Results/dh_pseudor2_modOfMod.txt', 'w') as file:
    file.write(temp[7])
