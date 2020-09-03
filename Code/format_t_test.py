import os
cwd = os.getcwd()

with open(cwd + '/Results/t_test_temp.tex', 'r') as file:
	data = file.readlines()
data[0] = ''
data[1] = ''
data[2] = ''
data[6] = 'Recession & \multicolumn{1}{r}{0} & \multicolumn{1}{r}{1} & \multicolumn{1}{r}{Difference} \\\\\n'
data[60] = ''
data[61] = ''
data[62] = ''
data[63] = ''
data[64] = ''
data[65] = ''
data[66] = ''
with open(cwd + '/Results/t_test.tex', 'w') as file:
    file.writelines(data)
