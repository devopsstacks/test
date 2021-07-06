FROM amazonlinux:2

# Update latest distro & installing tools
RUN yum update -y && yum install -y wget tar

# Install NGINX
COPY nginx.repo /etc/yum.repos.d/nginx.repo
RUN yum clean all && yum -y install nginx && \
    rm -f /etc/nginx/conf.d/*.conf

# Install PHP 7.4
RUN amazon-linux-extras install -y epel && \
    amazon-linux-extras install -y php7.4 && \
    yum -y install php-gd php-soap php-mbstring php-ldap php-xml \
    php-pecl-apcu php-opcache libc-client-devel php-devel php-pear gcc uw-imap-static libxml2-devel php-bcmath \
    ImageMagick ImageMagick-devel && \
    pecl install imagick && \
    yum groupinstall -y "Development Tools"


# Install supervisor
RUN yum install -y supervisor
COPY config/supervisord.d /etc/supervisord.d
COPY config/supervisord.conf /etc/supervisord.conf


# Install NodeJS
RUN yum install -y gcc-c++ make sudo && \
    curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && \
    yum install -y nodejs

# Install Docker
RUN amazon-linux-extras install docker && \
    usermod -aG docker nginx


# Install Clients for MySQL and Redis
RUN rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --disable mysql80-community && \
    yum-config-manager --enable mysql57-community && \
    yum -y install mysql-community-client redis

# New Relic
RUN rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && yum install -y newrelic-php5


CMD ["/bin/bash"]
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80
