FROM freshrss/freshrss:latest

COPY extensions.zip /tmp/extensions.zip

RUN apt-get update && apt-get install -y unzip \
    && unzip /tmp/extensions.zip -d /var/www/FreshRSS/ \
    && chown -R www-data:www-data /var/www/FreshRSS/extensions/ \
    && chmod -R 755 /var/www/FreshRSS/extensions/ \
    && rm /tmp/extensions.zip \
    && apt-get remove --purge -y unzip \
    && apt-get autoremove -y \
    && apt-get clean

# Environment variables for FreshRSS configuration
ENV TZ=Asia/Kolkata \
    COPY_LOG_TO_SYSLOG=Off \
    COPY_SYSLOG_TO_STDERR=Off \
    CRON_MIN='0' \
    DATA_PATH='' \
    FRESHRSS_ENV='production' \
