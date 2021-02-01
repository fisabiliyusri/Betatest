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
wget -O /etc/openvpn/client-udp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-udp.conf"
sed -i $MYIP2 /etc/openvpn/client-udp.ovpn;
echo '<ca>' >> /etc/openvpn/client-udp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-udp.ovpn
echo '</ca>' >> /etc/openvpn/client-udp.ovpn
cp /etc/openvpn/client-udp.ovpn /home/vps/public_html

#buat tcp
wget -O /etc/openvpn/client-tcp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-tcp.conf"
sed -i $MYIP2 /etc/openvpn/client-tcp.ovpn;
echo '<ca>' >> /etc/openvpn/client-tcp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-tcp.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp.ovpn
cp /etc/openvpn/client-tcp.ovpn /home/vps/public_html/

#buat ssl
wget -O /etc/openvpn/569client-ssl.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/569client-ssl.conf"
sed -i $MYIP2 /etc/openvpn/569client-ssl.ovpn;
echo '<ca>' >> /etc/openvpn/569client-ssl.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/569client-ssl.ovpn
echo '</ca>' >> /etc/openvpn/569client-ssl.ovpn
cp /etc/openvpn/569client-ssl.ovpn /home/vps/public_html/


# 
echo -e "============================="
echo -e "Mod by Sulaiman L" 
echo -e "=============================" 
echo -e "Server OpenVPN Berhasil Di Perbaiki"
echo -e "Done"
echo -e "=============================" 
echo -e ""
