FROM ubuntu:xenial
MAINTAINER Patrick Oberdorf <patrick@oberdorf.net>

COPY assets/apt/preferences.d/pdns /etc/apt/preferences.d/pdns
RUN apt-get update && apt-get install -y curl sudo \
	&& curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add - \
	&& echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu xenial-auth-40 main" > /etc/apt/sources.list.d/pdns.list

RUN apt-get update && apt-get install -y \
	wget \
	netcat-openbsd \
	git \
	supervisor \
	mysql-client \
	nginx \
	php7.0-fpm \
	php7.0-mcrypt \
	php7.0-mysqlnd \
	pdns-server \
	pdns-backend-mysql \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### PDNS ###

#RUN cd /tmp && wget https://downloads.powerdns.com/releases/deb/pdns-static_${VERSION}_amd64.deb && dpkg -i pdns-static_${VERSION}_amd64.deb && rm pdns-static_${VERSION}_amd64.deb
#RUN useradd --system pdns

COPY assets/nginx/nginx.conf /etc/nginx/nginx.conf
COPY assets/nginx/vhost.conf /etc/nginx/sites-enabled/vhost.conf
COPY assets/nginx/fastcgi_params /etc/nginx/fastcgi_params

COPY assets/php/php.ini /etc/php/7.0/fpm/php.ini
COPY assets/php/php-cli.ini /etc/php/7.0/cli/php.ini

COPY assets/pdns/pdns.conf /etc/powerdns/pdns.conf
COPY assets/pdns/pdns.d/ /etc/powerdns/pdns.d/
COPY assets/mysql/pdns.sql /pdns.sql

### PHP/Nginx ###
RUN rm /etc/nginx/sites-enabled/default
RUN phpenmod mcrypt
RUN mkdir -p /run/php/
RUN mkdir -p /var/www/html/ \
	&& cd /var/www/html \
	&& rm -rf /var/www/html/* \
	&& git clone https://github.com/poweradmin/poweradmin.git . \
	&& git checkout b27f28b2d586afb201904437605be988ee048c22 \
	&& rm -R /var/www/html/install

COPY assets/poweradmin/config.inc.php /var/www/html/inc/config.inc.php
COPY assets/mysql/poweradmin.sql /poweradmin.sql
RUN chown -R www-data:www-data /var/www/html/ \
	&& chmod 644 /etc/powerdns/pdns.d/pdns.*

### SUPERVISOR ###
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

EXPOSE 53 80
EXPOSE 53/udp

CMD ["/bin/bash", "/start.sh"]
