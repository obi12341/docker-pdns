#!/bin/bash
MYSQL_HOST=db
if [ -z "$DB_ENV_MYSQL_USER" ]; then
	MYSQL_USER=root
else
	MYSQL_USER=${DB_ENV_MYSQL_USER}
fi
if [ -z "$DB_ENV_MYSQL_PASSWORD" ]; then
	MYSQL_PASSWORD=${DB_ENV_MYSQL_ROOT_PASSWORD}
else
	MYSQL_PASSWORD=${DB_ENV_MYSQL_PASSWORD}
fi
if [ -z "$DB_ENV_MYSQL_DATABASE" ]; then
	MYSQL_DB=pdns
else
	MYSQL_DB=${DB_ENV_MYSQL_DATABASE}
fi

PDNS_ALLOW_AXFR_IPS=${PDNS_ALLOW_AXFR_IPS:-127.0.0.1}
PDNS_MASTER=${PDNS_MASTER:-yes}
PDNS_SLAVE=${PDNS_SLAVE:-no}
PDNS_CACHE_TTL=${PDNS_CACHE_TTL:-20}
PDNS_DISTRIBUTOR_THREADS=${PDNS_DISTRIBUTOR_THREADS:-3}
PDNS_RECURSIVE_CACHE_TTL=${PDNS_RECURSIVE_CACHE_TTL:-10}
POWERADMIN_HOSTMASTER=${POWERADMIN_HOSTMASTER:-}
POWERADMIN_NS1=${POWERADMIN_NS1:-}
POWERADMIN_NS2=${POWERADMIN_NS2:-}

until nc -z db 3306; do
    echo "$(date) - waiting for mysql..."
    sleep 1
done

if mysql -u root -p${MYSQL_PASSWORD} --host=db "${MYSQL_DB}" >/dev/null 2>&1 </dev/null
then
	echo "Database ${MYSQL_DB} already exists"
else
	mysql -u root -p${MYSQL_PASSWORD} --host=db -e "CREATE DATABASE ${MYSQL_DB}"
	mysql -u root -p${MYSQL_PASSWORD} --host=db pdns < /pdns.sql
	mysql -u root -p${MYSQL_PASSWORD} --host=db pdns < /poweradmin.sql
	rm /pdns.sql /poweradmin.sql
fi

### PDNS
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{PDNS_ALLOW_AXFR_IPS}}/${PDNS_ALLOW_AXFR_IPS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_MASTER}}/${PDNS_MASTER}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_SLAVE}}/${PDNS_SLAVE}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_CACHE_TTL}}/${PDNS_CACHE_TTL}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_DISTRIBUTOR_THREADS}}/${PDNS_DISTRIBUTOR_THREADS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_RECURSIVE_CACHE_TTL}}/${PDNS_RECURSIVE_CACHE_TTL}/" /etc/powerdns/pdns.conf

### POWERADMIN
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_HOSTMASTER}}/${POWERADMIN_HOSTMASTER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS1}}/${POWERADMIN_NS1}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS2}}/${POWERADMIN_NS2}/" /var/www/html/inc/config.inc.php

exec /usr/bin/supervisord
