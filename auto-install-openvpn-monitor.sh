#!/bin/bash
# Install dependencies and configure apache
```shell
apt-get -y install python-geoip python-ipaddr python-humanize python-bottle python-semantic-version apache2 libapache2-mod-wsgi git wget geoip-database-extra
echo "WSGIScriptAlias /openvpn-monitor /var/www/html/openvpn-monitor/openvpn-monitor.py" > /etc/apache2/conf-available/openvpn-monitor.conf
a2enconf openvpn-monitor
systemctl restart apache2
a2enconf openvpn-monitor
/etc/init.d/apache2 restart
```

# Checkout OpenVPN-Monitor
```shell
cd /var/www/html
git clone https://github.com/furlongm/openvpn-monitor.git
```

#
```shell
cd /var/www/html/openvpn-monitor
python openvpn-monitor.py
```

#
```shell
cd /var/www/html/openvpn-monitor
python openvpn-monitor.py -d
```

