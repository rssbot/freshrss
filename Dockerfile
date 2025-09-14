FROM alpine:edge

ENV TZ=Asia/Kolkata
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Add testing repo, install required packages including unzip
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk add --no-cache \
      tzdata \
      apache2 php85-apache2 \
      apache-mod-auth-openidc \
      php85 php85-curl php85-gmp php85-intl php85-mbstring php85-xml php85-zip \
      php85-ctype php85-dom php85-fileinfo php85-iconv php85-json php85-openssl php85-phar php85-session php85-simplexml php85-xmlreader php85-xmlwriter php85-xml php85-tokenizer php85-zlib \
      php85-pdo_sqlite php85-pdo_mysql php85-pdo_pgsql \
      unzip \
    && cp /usr/share/zoneinfo/Asia/Kolkata /etc/localtime \
    && echo "Asia/Kolkata" > /etc/timezone \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /var/www/FreshRSS /run/apache2/
WORKDIR /var/www/FreshRSS

# Copy FreshRSS source files with permissions
COPY --chown=root:www-data . /var/www/FreshRSS
COPY ./Docker/*.Apache.conf /etc/apache2/conf.d/

# Copy and unzip extensions.zip into correct location
COPY extensions.zip /tmp/extensions.zip
RUN unzip /tmp/extensions.zip -d /tmp/ \
    && mv /tmp/extensions/extensions /var/www/FreshRSS/ \
    && chown -R apache:apache /var/www/FreshRSS/extensions/ \
    && chmod -R 755 /var/www/FreshRSS/extensions/ \
    && rm -rf /tmp/extensions /tmp/extensions.zip \
    && apk del unzip

# Setup cronjob to run every hour at minute 0 with minimal logging
RUN echo "0 * * * * . /var/www/FreshRSS/Docker/env.txt; su apache -s /bin/sh -c 'php /var/www/FreshRSS/app/actualize_script.php' > /dev/null 2>&1" > /etc/crontab.freshrss.default

# Disable unnecessary logging
ENV COPY_LOG_TO_SYSLOG=Off
ENV COPY_SYSLOG_TO_STDERR=Off
ENV CRON_MIN=''
ENV DATA_PATH=''
ENV FRESHRSS_ENV=''
ENV LISTEN=''
ENV OIDC_ENABLED=''
ENV TRUSTED_PROXY=''

ENTRYPOINT ["./Docker/entrypoint.sh"]

EXPOSE 80

# Run cron if CRON_MIN set, otherwise start Apache in foreground with optional OpenID flag
CMD ([ -z "$CRON_MIN" ] || crond -d 0) && exec httpd -D FOREGROUND $([ -n "$OIDC_ENABLED" ] && [ "$OIDC_ENABLED" -ne 0 ] && echo "-D OIDC_ENABLED"
