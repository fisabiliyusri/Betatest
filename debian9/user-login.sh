#!/bin/bash
#
# Script Copyright SLSSH
# Mod by Sulaiman L
# ==========================
# 

data=( `ps aux | grep -i dropbear | awk '{print $2}'`);

echo "-----------------------";
echo "Checking Dropbear login";
echo "-----------------------";

for PID in "${data[@]}"
do
	#echo "check $PID";
	NUM=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l`;
	USER=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}'`;
	IP=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $12}'`;
	if [ $NUM -eq 1 ]; then
		echo "$PID - $USER - $IP";
	fi
done

echo "";

data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

echo "----------------------";
echo "Checking OpenSSH login";
echo "----------------------";

for PID in "${data[@]}"
do
        #echo "check $PID";
	NUM=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | wc -l`;
	USER=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $9}'`;
	IP=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done
echo "----------------------";
echo "Checking OpenVPN login";
echo "----------------------";

for PID in "${data[@]}"
do
        #echo "check $PID";
	NUM=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | wc -l`;
	USER=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $9}'`;
	IP=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done
echo "----------------------";
echo "Checking OpenVPN TCP login";
echo "----------------------";

for PID in "${data[@]}"
if [ -f "/etc/openvpn/server-tcp.log" ]; then
	line=`cat /etc/openvpn/server-tcp.log | wc -l`
	a=$((3+((line-8)/2)))
	b=$(((line-8)/2))
	echo " "
	echo "Memerika User OpenVPN Yang Login";
	echo "(Username - IP - Terkoneksi Sejak)";
	echo "-------------------------------------";
	cat /etc/openvpn/server-tcp.log | head -n $a | tail -n $b | cut -d "," -f 1,2,5 | sed -e 's/,/   /g' > /tmp/vpn-login-db.txt
	cat /tmp/vpn-login-db.txt
fi
echo " "
echo " "
done

echo "";

echo "------------------------------------------------"
echo " Multi Login = kill "
echo " Cara pakai : kill nomor PID "
echo "------------------------------------------------"

echo "";

echo "Mod by partner SLSSH";

echo "";
