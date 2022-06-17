import os
cwd = os.getcwd()
import numpy as np

list_2q = np.loadtxt(cwd + "/temp/2q_persid.txt")
list_5q = np.loadtxt(cwd + "/temp/5q_persid.txt")

list_both = np.intersect1d(list_2q,list_5q)
list_not_5q = np.setdiff1d(list_2q,list_5q)

np.savetxt(cwd + '/temp/2q_not_5q.txt',list_not_5q,fmt='%i')