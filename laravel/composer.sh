chown -R www-data:www-data /var/www/
chmod -R  755 /var/www/
chmod -R 777 /var/www/storage
rm -rf composer.lock 
rm -rf vendor
composer install 
composer require laravel/framework 
composer require laravel/laravel
composer require  psr/http-message:^1.0
composer require phpoffice/phpspreadsheet
composer require maatwebsite/excel:3.1.45 -W
composer require stevebauman/location
composer require beyondcode/laravel-websockets
composer require pusher/pusher-php-server
rm -rf bootstrap/cache/packages.php
composer update
composer dump-autoload
composer require tymon/jwt-auth
composer install
composer update --no-scripts
php artisan config:cache
php artisan cache:clear
php artisan optimize
#php artisan migrate:status
#chown -R www-data:www-data /var/www/html/
chmod -R  755 /var/www/
chmod -R 777 /var/www/storage
