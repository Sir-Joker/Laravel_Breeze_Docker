#!/bin/sh

# Befülle .env.example
sed -i "/APP_NAME=/c\\APP_NAME=$APP_NAME" /var/www/html/.conf.env
sed -i "/APP_URL=/c\\APP_URL=$APP_URL" /var/www/html/.conf.env
sed -i "/DB_CONNECTION=/c\\DB_CONNECTION=$DB_CONNECTION" /var/www/html/.conf.env
sed -i "/DB_HOST=/c\\DB_HOST=$DB_HOST" /var/www/html/.conf.env
sed -i "/DB_PORT=/c\\DB_PORT=$DB_PORT" /var/www/html/.conf.env
sed -i "/DB_DATABASE=/c\\DB_DATABASE=$DB_DATABASE" /var/www/html/.conf.env
sed -i "/DB_USERNAME=/c\\DB_USERNAME=$DB_USERNAME" /var/www/html/.conf.env
sed -i "/DB_PASSWORD=/c\\DB_PASSWORD=$DB_PASSWORD" /var/www/html/.conf.env
sed -i "/MAIL_MAILER=/c\\MAIL_MAILER=$MAIL_MAILER" /var/www/html/.conf.env
sed -i "/MAIL_HOST=/c\\MAIL_HOST=$MAIL_HOST" /var/www/html/.conf.env
sed -i "/MAIL_PORT=/c\\MAIL_PORT=$MAIL_PORT" /var/www/html/.conf.env
sed -i "/MAIL_USERNAME=/c\\MAIL_USERNAME=$MAIL_USERNAME" /var/www/html/.conf.env
sed -i "/MAIL_PASSWORD=/c\\MAIL_PASSWORD=$MAIL_PASSWORD" /var/www/html/.conf.env
sed -i "/MAIL_ENCRYPTION=/c\\MAIL_ENCRYPTION=$MAIL_ENCRYPTION" /var/www/html/.conf.env
sed -i "/MAIL_FROM_ADDRESS=/c\\MAIL_FROM_ADDRESS=$MAIL_FROM_ADDRESS" /var/www/html/.conf.env
sed -i "/MAIL_FROM_NAME=/c\\MAIL_FROM_NAME=$MAIL_FROM_NAME" /var/www/html/.conf.env

cp /var/www/html/.conf.env /var/www/html/.env
chown www-data:www-data /var/www/html/.env
php artisan key:generate
php artisan migrate --force

if [ "$APP_DOMAIN" != "localhost" ];
	then
    # Request certificate
    certbot --apache --non-interactive --agree-tos --email $MAIL_FROM_ADDRESS -d $APP_DOMAIN
    # Add cron job for renewal
    echo "0 0,12 * * * root certbot renew --quiet" >> /etc/crontab
fi


# Führe die Migrationen aus
php artisan migrate --force

# Starte den Apache-Webserver
service ssh start
apache2ctl -D FOREGROUND
