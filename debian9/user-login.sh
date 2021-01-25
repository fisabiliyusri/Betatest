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
data=( `ps aux | grep -i openvpn | awk '{print $2}'`);
echo "----------------------";
echo "Checking OpenVPN login 1";
echo "----------------------";

for PID in "${data[@]}"
do
        #echo "check $PID";
	NUM=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | wc -l`;
	USER=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $14}'`;
	IP=`cat /var/log/auth.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $16}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done
data=( `ps aux | grep -i openvpn | awk '{print $2}'`);
echo "----------------------";
echo "Checking OpenVPN TCP login 1";
echo "----------------------";

for PID in "${data[@]}"
do
        #echo "check $PID";
	NUM=`cat /etc/openvpn/server-tcp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | wc -l`;
	USER=`cat /etc/openvpn/server-tcp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $9}'`;
	IP=`cat /etc/openvpn/server-tcp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done
echo " "
echo " "
done
data=( `ps aux | grep -i openvpn | awk '{print $2}'`);
echo "----------------------";
echo "Checking OpenVPN login 2";
echo "----------------------";

for PID in "${data[@]}"
do
        #echo "check $PID";
	NUM=`cat /etc/openvpn/server-udp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | wc -l`;
	USER=`cat /etc/openvpn/server-udp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $15}'`;
	IP=`cat /etc/openvpn/server-udp.log | grep -i openvpn | grep -i "Accepted password for" | grep "openvpn\[$PID\]" | awk '{print $17}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done
echo "";

echo "------------------------------------------------"
echo " Multi Login = kill "
echo " Cara pakai : kill nomor PID "
echo "------------------------------------------------"

echo "";

echo "Mod by partner SLSSH";

echo "";
