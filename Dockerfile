# # #
# Docker image for a complete palava.tv WebRTC application
# # #

FROM ubuntu:trusty
MAINTAINER palava e. V. <contact@palava.tv>
ENV DEBIAN_FRONTEND noninteractive

## PULL UPGRADES
RUN \
	apt-get -y update && \
	apt-get -y upgrade

## APT PACKAGES
RUN \ 
	apt-get -y install software-properties-common git-core curl \
	                   build-essential libstdc++6 ruby ruby-dev \
			   supervisor

## ADD PPAS
RUN \
	add-apt-repository -y ppa:rwky/redis && \
	add-apt-repository -y ppa:nginx/stable && \
	apt-get -y update

## INSTALL REDIS
RUN \
	apt-get -y install redis-server && \
	sed -i "s/^# bind 127.0.0.1$/bind 127.0.0.1/g" /etc/redis/redis.conf

## INSTALL NGINX
RUN \
	apt-get -y install nginx && \
	echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
	chown -R www-data:www-data /var/lib/nginx

## INSTALL REQUIRED GEMS
RUN \
	gem install bundler palava_machine middleman

## CREATE USER
RUN adduser --disabled-password --home /home/palava --gecos "" palava

## PULL PORTAL
RUN git clone --recursive https://github.com/palavatv/palava-portal.git /home/palava/portal
WORKDIR /home/palava/portal
RUN bundle --without development:test --deployment

## DOCKER SETTINGS
VOLUME ["/etc/nginx/certs"]
EXPOSE 80 443

## CONFIGURE SUPERVISOR && NGINX
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD palava.nginx /etc/nginx/sites-available/palava

## LAUNCH SETTINGS
WORKDIR /home/palava
ADD start-palava.sh /home/palava/
CMD ['./start-palava.sh']

