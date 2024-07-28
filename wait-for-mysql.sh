#!/bin/sh

# Warte, bis MySQL verfügbar ist
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    echo "Waiting for MySQL to be available..."
    sleep 2
done

# Führe die Migrationen aus
php artisan migrate --force

# Starte den Apache-Webserver
service ssh start
apache2ctl -D FOREGROUND
