FROM ubuntu:trusty
MAINTAINER Patrick Oberdorf <patrick@oberdorf.net>

ENV VERSION 3.4.7-1

RUN apt-get update
RUN apt-get install -y \
	wget \
	git \
	supervisor \
	mysql-client \
	apache2 \
	libapache2-mod-php5 \
	php5-mcrypt \
	php5-mysqlnd \
	&& apt-get clean
### PDNS ###
RUN cd /tmp && wget https://downloads.powerdns.com/releases/deb/pdns-static_${VERSION}_amd64.deb && dpkg -i pdns-static_${VERSION}_amd64.deb
RUN useradd --system pdns

ADD assets/pdns/pdns.conf /etc/powerdns/pdns.conf
ADD assets/pdns/pdns.d/ /etc/powerdns/pdns.d/
ADD assets/mysql/pdns.sql /pdns.sql

### APACHE2/POWERADMIN ###
RUN mkdir -p /var/lock/apache2 /var/run/apache2
RUN php5enmod mcrypt
RUN rm -R /var/www/html/* \
	&& cd /var/www/html \
	&& git clone https://github.com/poweradmin/poweradmin.git . \
	&& git checkout c49908ecaa2a43015e53b3749ff9191e44a83a85 \
	&& rm -R /var/www/html/install

ADD assets/poweradmin/config.inc.php /var/www/html/inc/config.inc.php
ADD assets/mysql/poweradmin.sql /poweradmin.sql
RUN chown -R www-data:www-data /var/www/html/

### SUPERVISOR ###
ADD assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD start.sh /start.sh

EXPOSE 53 80
EXPOSE 53/udp

CMD ["/bin/bash", "/start.sh"]
