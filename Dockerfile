FROM ubuntu:trusty
MAINTAINER Patrick Oberdorf <patrick@oberdorf.net>

ENV VERSION 3.4.7-1

RUN apt-get update && apt-get install -y \
	wget \
	git \
	supervisor \
	mysql-client \
	nginx \
	php5-fpm \
	php5-mcrypt \
	php5-mysqlnd \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### PDNS ###
RUN cd /tmp && wget https://downloads.powerdns.com/releases/deb/pdns-static_${VERSION}_amd64.deb && dpkg -i pdns-static_${VERSION}_amd64.deb && rm pdns-static_${VERSION}_amd64.deb
RUN useradd --system pdns

COPY assets/nginx/nginx.conf /etc/nginx/nginx.conf
COPY assets/nginx/vhost.conf /etc/nginx/sites-enabled/vhost.conf
COPY assets/nginx/fastcgi_params /etc/nginx/fastcgi_params

COPY assets/php/php.ini /etc/php5/fpm/php.ini
COPY assets/php/php-cli.ini /etc/php5/cli/php.ini

COPY assets/pdns/pdns.conf /etc/powerdns/pdns.conf
COPY assets/pdns/pdns.d/ /etc/powerdns/pdns.d/
COPY assets/mysql/pdns.sql /pdns.sql

### PHP/Nginx ###
RUN rm /etc/nginx/sites-enabled/default
RUN php5enmod mcrypt
RUN mkdir -p /var/www/html/ \
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
