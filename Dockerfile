FROM php:fpm

RUN apt-get update && \
    apt-get install -y \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libc-dev \
    libc6-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    libglib2.0-dev \
    libicu-dev \
    libpcre3-dev \
    libxml2 \
    libxml2-dev \
    libxt-dev \
    libz-dev \
    xml2 \
    zlib1g-dev \
    r-base \
    wget \
    python-pip
  
# PDO
RUN docker-php-ext-install pdo_mysql opcache

RUN mkdir -p /opt/newrelic
WORKDIR /opt/newrelic
RUN wget -r -nd --no-parent -Alinux.tar.gz \
    http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1 \
    && tar -xzf newrelic-php*.tar.gz --strip=1
ENV NR_INSTALL_SILENT true
ENV NR_INSTALL_PHPLIST /usr/local/bin/
RUN bash newrelic-install install
RUN pip install newrelic-plugin-agent
WORKDIR /
RUN mkdir -p /var/log/newrelic
RUN mkdir -p /var/run/newrelic

RUN unlink /usr/local/lib/php/extensions/no-debug-non-zts-20160303/newrelic.so \
	&& cp /opt/newrelic/agent/x64/newrelic-20160303.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/newrelic.so \
        && echo 'extension = "newrelic.so"' > /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo '[newrelic]' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.enabled = true' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.license = ${NEWRELIC_LICENSE}' >> /usr/local/etc/php/conf.d/newrelic.ini \
 	&& echo 'newrelic.appname = ${NEWRELIC_APPNAME}' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.feature_flag=laravel_queue' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& rm -fr /opt/newrelic

WORKDIR /var/www/html

# Cleanup
RUN apt-get clean
RUN rm -fr /usr/src/php/ext

# R packages
RUN R -e "install.packages(c('rjson', 'klaR', 'stringi'), repos='http://cran.rstudio.com/')"
