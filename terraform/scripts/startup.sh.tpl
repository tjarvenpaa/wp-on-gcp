#!/bin/bash
set -e
DB_NAME=wordpress
DB_USER="${db_user}"
DB_PASS="${db_password}"
SITE_TITLE="${site_title}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
# Install dependencies for adding the PHP maintainer's repository (deb.sury.org)
apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2 software-properties-common

# Add Ondřej Surý's PHP repository for newer PHP versions
wget -qO- https://packages.sury.org/php/apt.gpg | gpg --dearmor > /usr/share/keyrings/php-sury.gpg
echo "deb [signed-by=/usr/share/keyrings/php-sury.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php-sury.list
apt-get update -y

# Install Nginx, PHP-FPM (8.2) and common extensions, plus MariaDB and helpers
apt-get install -y nginx php8.2-fpm php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring php8.2-intl php8.2-zip mariadb-server wget unzip rsync

# Configure Nginx to use PHP-FPM for .php files
cat > /etc/nginx/sites-available/wordpress <<'NGINXCONF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;
    index index.php index.html index.htm;

    client_max_body_size 100M;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
        log_not_found off;
    }

    sendfile off;
}
NGINXCONF

ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
rm -f /etc/nginx/sites-enabled/default || true

# Ensure services are enabled and running
systemctl enable --now nginx
systemctl enable --now php8.2-fpm
systemctl enable --now mariadb

# Wait a moment for MariaDB to start
sleep 3

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS $${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '$${DB_USER}'@'localhost' IDENTIFIED BY '$${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON $${DB_NAME}.* TO '$${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

# Download WordPress
wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
mkdir -p /tmp/wp
tar -xzf /tmp/wordpress.tar.gz -C /tmp/wp
rsync -a /tmp/wp/wordpress/ /var/www/html/

# Set permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Configure wp-config.php
if [ -f /var/www/html/wp-config-sample.php ]; then
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i "s/database_name_here/$${DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/$${DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/$${DB_PASS}/" /var/www/html/wp-config.php
fi

# Restart services to apply configuration
systemctl restart php8.2-fpm
systemctl restart nginx

# Small message to help debugging
echo "WordPress installed. Please open the site and finish the setup in the web installer."
