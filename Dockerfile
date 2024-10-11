FROM wordpress:latest

# Change Apache port from 80 to 8080
RUN sed -i 's/80/8080/' /etc/apache2/ports.conf /etc/apache2/sites-enabled/000-default.conf

# Use the development PHP configuration file
RUN mv "$PHP_INI_DIR"/php.ini-development "$PHP_INI_DIR"/php.ini

# Install dependencies (mariadb-client, netcat-openbsd, sudo, less, git, unzip)
RUN apt-get update && \
    apt-get install -yq mariadb-client netcat-openbsd sudo less git unzip

# Install WP-CLI
RUN curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp && \
    mkdir /var/www/.wp-cli && \
    chown www-data:www-data /var/www/.wp-cli

# Install Composer
RUN curl -sL https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir /var/www/.composer && \
    chown www-data:www-data /var/www/.composer

# Allow Composer to install plugins globally
RUN sudo -u www-data composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true

# Install phpunit, phpcs, and wpcs (WordPress Coding Standards)
RUN sudo -u www-data composer global require \
    phpunit/phpunit \
    dealerdirect/phpcodesniffer-composer-installer \
    phpcompatibility/phpcompatibility-wp \
    automattic/vipwpcs

# Ensure WordPress has write permissions on the Linux host
RUN chown -R www-data:www-data /var/www/html

# Include Composer-installed executables in $PATH
ENV PATH="/var/www/.composer/vendor/bin:${PATH}"

# Expose the port used by Apache
EXPOSE 8080
