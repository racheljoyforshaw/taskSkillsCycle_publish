import os
cwd = os.getcwd()

with open(cwd + '/Results/dh_temp_ALL.tex', 'r') as file:
	data = file.readlines()
data[0] =''
data[4] = ' &\multicolumn{1}{c}{(1)Probit}  &\multicolumn{6}{c}{(2) Double Hurdle}  \\\\ \cmidrule(l{2pt}r{2pt}){1-2} \cmidrule(l{2pt}r{2pt}){3-7} \n'
data[5] = ' &\multicolumn{1}{c}{$\Delta$1-digit SOC} &\multicolumn{3}{c}{$\Delta$Tasks} &\multicolumn{3}{c}{$\Delta$Skills}  \\\\\n'
data[6] = ' &\multicolumn{1}{c}{All} &  &\multicolumn{1}{c}{All} &\multicolumn{1}{c}{EE} data[5] &\multicolumn{1}{c}{IE & UE} &  &\multicolumn{1}{c}{All} &\multicolumn{1}{c}{EE} &\multicolumn{1}{c}{IE & UE}'
#temp = data[57:71]
#data[57] = ''
#data[58:72] = temp
#data[61] = 'N & \input{../Results/tobit4_N_angSep.txt}  & \input{../Results/tobit4_N_modOfMod.txt} & \input{../Results/tobit1_N_angSep.txt}  & \input{../Results/tobit1_N_modOfMod.txt}  & \input{../Results/dh_N_angSep_probit.txt}  &\input{../Results/dh_N_angSep.txt}  & \input{../Results/dh_N_modOfMod_probit.txt} & \input{../Results/dh_N_modOfMod.txt}  \\\\\n'
#data[62] = 'APE & \input{../Results/APEfactor_angSep_CASCOT.txt}  & \input{../Results/APEfactor_modOfMod_CASCOT.txt} & \input{../Results/APEfactor_angSep_CASCOT.txt}  & \input{../Results/APEfactor_modOfMod_CASCOT.txt}  & \input{../Results/APEfactor_angSep_CASCOT.txt}  & - & \input{../Results/APEfactor_modOfMod_CASCOT.txt} & - \\\\\n'
#data[63] = ''
data[64] = 'Pseudo R$^{2}$ & \input{../Results/tobit4_pseudor2_angSep.txt}  & \input{../Results/tobit4_pseudor2_modOfMod.txt} & \input{../Results/tobit1_pseudor2_angSep.txt}  & \input{../Results/tobit1_pseudor2_modOfMod.txt}  & \input{../Results/dh_pseudor2_angSep_probit.txt}  &\input{../Results/dh_pseudor2_angSep.txt}  & \input{../Results/dh_pseudor2_modOfMod_probit.txt} & \input{../Results/dh_pseudor2_modOfMod.txt}  \\\\\n'
#data[65] = 'Log Likelihood & \input{../Results/tobit4_LL_angSep.txt}  & \input{../Results/tobit4_LL_modOfMod.txt} & \input{../Results/tobit1_LL_angSep.txt}  & \input{../Results/tobit1_LL_modOfMod.txt}  & \input{../Results/dh_LL_angSep_probit.txt}  &\input{../Results/dh_LL_angSep.txt}  & \input{../Results/dh_LL_modOfMod_probit.txt} & \input{../Results/dh_LL_modOfMod.txt}  \\\\\n'
#data[66] = '\hline \\\\\n '
#data[67] = ''
#data[68] = ''
#data[71] = ''
with open(cwd + '/Results/reg_ALL.tex', 'w') as file:
    file.writelines(data)
    
    
    
    
    
    
