##############################################################################################################
### This file was forked and adapted from https://github.com/KaiHofstetter/docker-wordpress-cli
### kaihofstetter/wordpress-cli (Kai Hofstetter <kai.hofstetter@gmx.de>)
### It was updated to use the latest Ubuntu LTS (18.04), Wordpress 5.2.2, PHP 7.2, MySQL 5.7 and wp-cli 2.2.0.                                                                     	#
### Also added additional PHP packages, and changed download source to latest version
### using English (Canada) language
#########################################################################################################

FROM ubuntu:latest
MAINTAINER Shaun Assam <sassam [at] fedoraproject.org>

# Install lamp stack plus curl
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php php php-mysql php-gd php-xml php-xmlrpc php-ldap php-mbstring php-odbc php-pear php-snmp php-curl mcrypt php-soap mysql-server nano vim wget curl

# Download WordPress
RUN wget "https://en-ca.wordpress.org/latest-en_CA.tar.gz" && \
    rm /var/www/html/index.html && \
    tar -xzf latest-en_CA.tar.gz -C /var/www/html --strip-components=1 && \
    rm latest-en_CA.tar.gz
 
# Download WordPress CLI
RUN cli_version=2.2.0 && \
    curl -L "https://github.com/wp-cli/wp-cli/releases/download/v${cli_version}/wp-cli-${cli_version}.phar" > /usr/bin/wp && \
    chmod +x /usr/bin/wp

# WordPress configuration
ADD wp-config.php /var/www/html/wp-config.php

# Apache access
RUN chown -R www-data:www-data /var/www/html

# Add configuration script
ADD config_and_start_mysql.sh /config_and_start_mysql.sh
ADD config_apache.sh /config_apache.sh
ADD config_wordpress.sh /config_wordpress.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# MySQL environment variables
ENV MYSQL_WP_USER WordPress
ENV MYSQL_WP_PASSWORD secret

# WordPress environment variables
ENV WP_URL localhost
ENV WP_TITLE WordPress Demo
ENV WP_ADMIN_USER admin_user
ENV WP_ADMIN_PASSWORD secret
ENV WP_ADMIN_EMAIL test@test.com

EXPOSE 80 3306
CMD ["/run.sh"]
