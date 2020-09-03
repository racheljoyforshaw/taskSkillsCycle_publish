import os

cwd = os.getcwd()
#print cwd

# import & get just one date
with open(cwd + '/Results/max_date.txt', 'r') as file:
	data = file.readlines()
with open(cwd + '/Results/max_date.txt', 'w') as file:
	file.write(data[0][:6])
	
with open(cwd + '/Results/min_date.txt', 'r') as file:
	data = file.readlines()
with open(cwd + '/Results/min_date.txt', 'w') as file:
	file.write(data[0][:6])
