# !/bin/bash
# openvpn config
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
# hapus
rm -rf /etc/openvpn/client-udp.ovpn
rm -rf /etc/openvpn/client-tcp.ovpn
rm -rf /etc/openvpn/569client-ssl.ovpn
rm -rf /home/vps/public_html/client-udp.ovpn
rm -rf /home/vps/public_html/client-tcp.ovpn
rm -rf /home/vps/public_html/569client-ssl.ovpn

# buat udp
cd /etc/openvpn/
wget -O /etc/openvpn/client-udp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-udp.ovpn"
sed -i $MYIP2 /etc/openvpn/client-udp.ovpn;
cp /etc/openvpn/client-udp.ovpn /home/vps/public_html

#buat tcp
wget -O /etc/openvpn/client-tcp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-tcp.ovpn"
sed -i $MYIP2 /etc/openvpn/client-tcp.ovpn;
cp /etc/openvpn/client-tcp.ovpn /home/vps/public_html/

#buat ssl
wget -O /etc/openvpn/569client-ssl.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-ssl.ovpn"
sed -i $MYIP2 /etc/openvpn/569client-ssl.ovpn;
cp /etc/openvpn/569client-ssl.ovpn /home/vps/public_html/


# 
echo -e "============================="
echo -e "Mod by Sulaiman L" 
echo -e "=============================" 
echo -e "Server OpenVPN Berhasil Di Perbaiki"
echo -e "Done"
echo -e "=============================" 
echo -e ""
