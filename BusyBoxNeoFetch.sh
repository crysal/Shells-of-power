echo -e '        #####           '$(cat /etc/passwd | grep root | cut -d ":" -f 1)@$(uname -a | awk '{print $2}')
echo -e '       #######          '"------------------"
echo -e '       ##\033[1;33mO\033[0;37m#\033[1;33mO\033[0;37m##          ''\033[1;33mOS:\033[0;37m '$(uname -a | awk '{print $1,$3}')
echo -e '       \033[0;37m#\033[1;33m#####\033[0;37m#          ''\033[1;33mKernel:\033[0;37m '$(uname -a | awk '{print $3}')
echo -e '     \033[0;37m##\033[1;33m#######\033[0;37m##        ''\033[1;33mUptime:\033[0;37m '$(uptime | awk '{print $3,$4}') $(echo $(($(uptime | awk '{print $1}' | cut -d ":" -f 1)-$(uptime | awk '{print $5}' | cut -d ":" -f 1))) | sed 's/-//g')" hours," $(echo $(($(echo $(uptime | awk '{print $1}' | cut -d ":" -f 2))-$(echo $(uptime | awk '{print $5}' | cut -d ":" -f 2 | sed 's/,//g')))) | sed 's/-//g')" mins"
echo -e '    ##\033[1;33m#########\033[0;37m##       ''\033[1;33mShell:\033[0;37m '$SHELL
echo -e '   #\033[1;33m############\033[0;37m##      ''\033[1;33mResolution:\033[0;37m SKIPPED'
echo -e '   #\033[1;33m############\033[0;37m###     ''\033[1;33mTerminal:\033[0;37m '
echo -e '  \033[1;33m##\033[0;37m#\033[1;33m###########\033[0;37m##\033[1;33m#     ''\033[1;33mCPU:\033[0;37m '$(cat /proc/cpuinfo | grep 'cpu model' | sed 's/.*://g') $(cat /proc/cpuinfo | grep 'BogoMIPS' | sed 's/.*:/@/g' | sed 's/$/ BogoMIPS/g')
echo -e '\033[1;33m######\033[0;37m#\033[1;33m#######\033[0;37m#\033[1;33m####### ''\033[1;33mMemory:\033[0;37m '$(($(echo $(cat /proc/meminfo | grep "Mem" | awk {'print $2}') | awk '{print $1}') - $(echo $(cat /proc/meminfo | grep "Mem" | awk {'print $2}') | awk '{print $2}')))"kB / "$(cat /proc/meminfo | grep "MemTotal" | awk {'print $2}')"kB"
echo -e '\033[1;33m#######\033[0;37m#\033[1;33m######\033[0;37m#\033[1;33m########'
echo -e '  \033[1;33m####\033[0;37m########\033[1;33m####\033[0;37m'
