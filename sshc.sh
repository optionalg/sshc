#! /bin/bash
# Programming and idea by : E2MA3N [Iman Homayouni]
# Gitbub : https://github.com/e2ma3n
# Email : e2ma3n@Gmail.com
# Website : http://OSLearn.ir
# License : GPL v3.0
# sshc v4.0 - core [SSH Management Console]
#--------------------------------------------------------#

# check root privilege
[ "`whoami`" != "root" ] && echo -e '[-] Please use root user or sudo' && exit 1


# data base location , Don not change this form
database_en="/opt/sshc_v4/sshc.database.en"


# print header on terminal
reset
echo '[+] ------------------------------------------------------------------- [+]'
echo -e "[+] Programming and idea by : \e[1mE2MA3N [Iman Homayouni]\e[0m"
echo '[+] License : GPL v3.0'
echo -e '[+] sshc v4.0 \n'


# check encrypted database
if [ ! -f $database_en ] ; then
	echo -e "[-] Error: $database_en not found"
	echo '[+] ------------------------------------------------------------------- [+]'
	exit 1
fi


# decrypt database
echo -en "[+] Enter password: " ; read -s pass
database_de=`openssl aes-256-cbc -pass pass:$pass -d -a -in $database_en 2> /dev/null`
if [ "$?" != "0" ] ; then
	echo -e "\n[-] Error: Database can not decrypted."
	echo '[+] ------------------------------------------------------------------- [+]'
	exit 1
else
	echo
fi


# print servers informations on terminal
echo -e "\n 0) Edite Database"
var0=`echo "$database_de" | wc -l`
var0=`expr $var0 - 12`
for (( i=1 ; i <= $var0 ; i++ )) ; do
	echo -ne " $i) " ; echo "$database_de" | tail -n $i | head -n 1 | cut -d " " -f 1,2 | tr " " @
done


# edite database
function edit_db {
	echo "$database_de" > /opt/sshc_v4/sshc.database.de
	nano /opt/sshc_v4/sshc.database.de
	echo -en "[+] encrypt new database, Please type your password: " ; read -s pass
	openssl aes-256-cbc -pass pass:$pass -a -salt -in /opt/sshc_v4/sshc.database.de -out $database_en
	rm -f /opt/sshc_v4/sshc.database.de &> /dev/null
	echo -e "\n[+] Done, New database saved and encrypted"
	echo '[+] ------------------------------------------------------------------- [+]'
	exit 0
}


# select server for continue
while :; do
	echo -en '\e[0m\n[+] Select your server/option or type quit for exit: ' ; read var1

	if [ "$var1" = "0" ] ; then
		edit_db
	fi

	if [ "$var1" -le "$var0" ] 2> /dev/null ; then
		break
	elif [ "$var1" = "quit" ] ; then
		echo "[+] Bye Bye"
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1
	else
		echo "[-] Error: bad input"
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1
	fi
done


# connect to server
function function_1 {
	password=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 4`
	username=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 1`
	ip_address=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 2`
	ssh_port=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 3`
	echo '[+] ------------------------------------------------------------------- [+]'
	sshpass -p "$password" ssh -o StrictHostKeyChecking=no -l $username $ip_address -p $ssh_port
}


# add your ip address to firewall
function function_2 {
	if [ "`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 1`" != "root" ] ; then
		echo "[-] Error: Your user is not root, we can not add your ip to firewall"
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1
	fi
	
	password=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 4`
	username=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 1`
	ssh_port=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 3`
	ip_address=`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 2`
	
	for (( i=1 ; i < 4 ; i++ )) ; do
		public_ip=`curl ipecho.net/plain 2> /dev/null`
		if [ ! -z "$public_ip" ]; then
			break
		fi
	done
	
	echo -en "[+] $public_ip your public IP Address ? [y/n]: " ; read var3
	if [ "$var3" = "y" ] ; then
		sshpass -p "$password" ssh -o StrictHostKeyChecking=no -l $username $ip_address -p $ssh_port "iptables -I INPUT -s $public_ip -j ACCEPT" &> /dev/null
		if [ "$?" != "0" ] ; then
			echo "[-] Error: Can not connect to server."
			echo '[+] ------------------------------------------------------------------- [+]'
			exit 1
		fi
	elif [ "$var3" = "n" ] ; then
		echo '[-] Are you shore ? Please try again'
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1
	else
		echo "[-] Error: Bad input"
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1
	fi
}


# status, checking up or down 
ping -c 1 `echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 2` &> /dev/null
if [ "$?" = "0" ] ; then
	echo -ne "\n You selected: \e[92m" ; echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 2 
else
	echo -ne "\n You selected: \e[91m" ; echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 2
fi


if [ "`echo "$database_de" | tail -n $var1 | head -n 1 | cut -d " " -f 1`" != "root" ] ; then
	echo -e "\e[0m 1) Connect to server"
else
	echo -e "\e[0m 1) Connect to server"
	echo -e " 2) Open your public IP address in server (Firewall)"
	echo -e " 3) Both"	
fi

echo -en "\n[+] Select your option or type quit for exit: " ; read var2

case $var2 in
	1) function_1
		exit 0 ;;

	2) function_2 
		echo "[+] Done"
		echo '[+] ------------------------------------------------------------------- [+]' ;;

	3) function_2
		echo "[+] Done"
		function_1 ;;
	
	quit) echo "[+] Bye Bye"
			echo '[+] ------------------------------------------------------------------- [+]'
			exit 0 ;;
	
	*) echo "[-] Error: Bad input"
		echo '[+] ------------------------------------------------------------------- [+]'
		exit 1 ;;
esac
