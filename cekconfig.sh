# !/bin/bash
# cekconfig = melihat daftar config

IP=`curl ipv4.icanhazip.com`
echo -e "  List Config Yang Tersedia" | lolcat
echo -e "============================="| lolcat
cd /var/www/openvpn
ls
echo -e " Semua Config" | lolcat
echo -e "http://$IP:85/configs.zip" | lolcat
echo -e "http://$IP:85/index.html" | lolcat
echo -e "=============================" | lolcat
echo -e "  Config .ehi (HTTP Injector) " | lolcat
echo -e "  Config .ovpn (OpenVPN)" | lolcat
echo -e "(OpenVPN HTTP Custom(Open Cfg VPN))" | lolcat
echo -e "  Mod by Sulaiman L"  | lolcat
