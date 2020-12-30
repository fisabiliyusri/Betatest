#!/bin/bash
# Script restart service dropbear, webmin, squid3, openvpn, openssh
# Created by partner whitevps
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid3 restart
/etc/init.d/webmin restart
/etc/init.d/php5-fpm restart
service squid restart
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
service cron restart
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
exit
