#!/bin/bash

DB_NAME ="${dbname}"
DB_USER ="${dbuser}"
DB_PASSWORD ="${dbpass}"
DB_HOST="${dbhost}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apache2 php libapache2-mod-php php-mysql
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo rm -rf /var/www/html/*
sudo cp -r /tmp/wordpress/* /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/g" /var/www/html/wp-config.php
sudo systemctl restart apache2
#=======================================================================================================================================
sudo apt install php-redis -y
sudo apt install redis -y
sudo systemctl restart apache2
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar #install wp-cli
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
REDIS_HOST="${cache_host}"
REDIS_PORT='6379'
REDIS_DATABASE='0'
WP_CACHE_KEY_SALT="${alb_dns}"
# Install and activate the Redis Object Cache plugin
cd /var/www/html
sudo wp core install --url=${alb_dns} --title=${company_name} --admin_user=${wp_admin} --admin_password=${wp_password} --admin_email=${wp_admin_email} --allow-root
sudo wp plugin install redis-cache --allow-root
sudo wp plugin activate redis-cache --allow-root
sudo wp redis enable --allow-root
# Adding Redis configuration to wp-config.php
cat <<EOF >>wp-config.php
// Redis settings
define('WP_REDIS_HOST', '$REDIS_HOST');
define('WP_REDIS_PORT', $REDIS_PORT);
define('WP_REDIS_DATABASE', $REDIS_DATABASE);
define('WP_CACHE_KEY_SALT', '$WP_CACHE_KEY_SALT:');
define('WP_CACHE', true);
EOF
#=======================================================================================================================================
cd /var/www/html
sudo apt install git
sudo git init
sudo git config user.email "artembrigaz@gmail.com"
sudo git config user.name "Artem Bryhynets"
sudo git config --global --add safe.directory /var/www/html
sudo git add .
sudo git commit -m "wp-config"
