import os
cwd = os.getcwd()

with open(cwd + '/Results/returns_skill_2000s_temp.tex', 'r') as file:
	data = file.readlines()
data[0] = data[1]
data[1]=''
data[4] = '& \multicolumn{1}{c}{$\ln w_{it}$} \\\ \n'
data[23]=''
data[25]=''
data[26]=''
data[27]=''
data[29]=''
with open(cwd + '/Results/returns_skill_2000s.tex', 'w') as file:
    file.writelines(data)
