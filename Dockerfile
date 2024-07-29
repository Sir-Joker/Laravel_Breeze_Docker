# Basis-Image verwenden
FROM ubuntu:latest

# Umgebungsvariablen setzen, um keine interaktiven Eingaben während der Installation zu erfordern
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_HOME=/root/composer
ENV PATH=$COMPOSER_HOME/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER=1

# Update der Paketliste und Installation der benötigten Pakete
RUN apt-get update && \
    apt-get install -y apache2 php8.3 libapache2-mod-php8.3 php8.3-xml php8.3-dom php8.3-mbstring php8.3-mysql php8.3-zip php8.3-curl php8.3-gd openssh-server wget curl unzip git npm cron vim nano mysql-client certbot python3-certbot-apache cron && \
	apt-get update && \
	apt-get upgrade -y && \
    apt-get clean

# Composer installieren
RUN wget https://getcomposer.org/installer -O composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Laravel Installer installieren
RUN composer global require laravel/installer

# Benutzer lara erstellen und ssh konfigurieren
RUN useradd -m -s /bin/bash lara && \
    echo 'lara:password' | chpasswd && \
    mkdir /home/lara/.ssh && \
    chown -R lara:lara /home/lara/.ssh && \
    echo 'lara ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Apache2 und SSHD Ports freigeben
EXPOSE 80 443 22

# Laravel installieren und Projekt erstellen
WORKDIR /var/www/html
RUN laravel new laravel-app && \
    mv laravel-app/* . && \
    rm -rf laravel-app

# Kopiere .env Beispiel und konfiguriere es
COPY .env.example .env
COPY .env.example .conf.env
COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh 

RUN php artisan key:generate

# Abhängigkeiten und Laravel Breeze installieren und konfigurieren
RUN composer require laravel/breeze --dev && \
    php artisan breeze:install blade --no-interaction && \
    npm install && \
    npm run build

# Rechte ändern
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    find /var/www/html -type d -exec chmod 755 {} \;

# Warte-Skript für MySQL
COPY wait-for-mysql.sh /usr/local/bin/wait-for-mysql.sh
RUN chmod +x /usr/local/bin/wait-for-mysql.sh

# Apache2 konfigurieren
COPY apache-laravel.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite ssl

# Apache2 und SSHD starten
CMD ["sh", "-c", "service ssh start && apache2ctl -D FOREGROUND"]
