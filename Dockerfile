FROM ubuntu:14.04

MAINTAINER Denis Neuling (denisneuling@gmail.com)

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install curl -y

RUN curl --silent http://packages.icinga.org/icinga.key | apt-key add -
RUN echo 'deb http://packages.icinga.org/ubuntu icinga-trusty main' > /etc/apt/sources.list.d/icinga-main-trusty.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install \
    nginx  \
    icingaweb2 \
    ruby \
    php5 \
    php5-intl \
    php5-imagick \
    php5-gd \
    php5-mysql \
    php5-pgsql \
    php5-curl \
    php5-fpm \
    mysql-client \
    postgresql-client \
    -y

RUN /usr/bin/icingacli setup config directory

RUN gem install tiller
ADD etc/tiller /etc/tiller

ADD etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default

RUN usermod -a -G icingaweb2 www-data;
RUN chmod -R 777 /usr/share/icingaweb2
RUN chown -R www-data. /usr/share/icingaweb2 /usr/share/php/

ADD usr/bin/icingaweb2-migrate /usr/bin/icingaweb2-migrate
RUN chmod +x /usr/bin/icingaweb2-migrate

RUN mkdir -p /etc/icingaweb2/enabledModules
RUN ln -s /usr/share/icingaweb2/modules/monitoring /etc/icingaweb2/enabledModules/monitoring
RUN ln -s /usr/share/icingaweb2/modules/setup /etc/icingaweb2/enabledModules/setup

EXPOSE 80

CMD tiller -d && /usr/bin/icingaweb2-migrate && service php5-fpm start && nginx -g 'daemon off;'
