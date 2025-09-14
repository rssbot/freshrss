FROM freshrss/freshrss:latest

# Copy all extensions from your GitHub repo to FreshRSS extensions directory
COPY extensions/ /var/www/FreshRSS/extensions/

# Set proper ownership and permissions for web server
RUN chown -R www-data:www-data /var/www/FreshRSS/extensions/ \
    && chmod -R 755 /var/www/FreshRSS/extensions/

# Use the default FreshRSS startup command
CMD ["apache2-foreground"]
