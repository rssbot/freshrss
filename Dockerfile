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

CMD ["apache2-foreground"]
