#!/bin/bash

# Perbarui dan upgrade sistem
echo "Memperbarui dan meningkatkan sistem..."
sudo apt update && sudo apt upgrade -y

# Instal Apache2
echo "Menginstal Apache2..."
sudo apt install -y apache2

# Ubah konfigurasi Apache untuk menggunakan port 2002 (FIX AMAN)
echo "Mengubah konfigurasi Apache ke port 2002..."
sudo sed -i 's/Listen 80/Listen 2002/g' /etc/apache2/ports.conf
sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:2002>/g' /etc/apache2/sites-available/000-default.conf

# Restart Apache untuk menerapkan perubahan
echo "Restarting Apache..."
sudo systemctl restart apache2

# Instal PHP dan modul-modulnya
echo "Menginstal PHP dan modul-modul yang diperlukan..."
sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-xml php-curl php-gd php-zip

# Instal phpMyAdmin
echo "Menginstal phpMyAdmin..."
sudo apt install -y phpmyadmin

# Nonaktifkan strict mode di MariaDB (FIX SUPPORT mariadbd)
echo "Menonaktifkan strict mode di MariaDB..."
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

if grep -q "\[mariadbd\]" $CONFIG_FILE; then
    sudo sed -i '/\[mariadbd\]/a sql_mode=""' $CONFIG_FILE
elif grep -q "\[mysqld\]" $CONFIG_FILE; then
    sudo sed -i '/\[mysqld\]/a sql_mode=""' $CONFIG_FILE
else
    echo -e "\n[mariadbd]\nsql_mode=\"\"" | sudo tee -a $CONFIG_FILE > /dev/null
fi

# Mengatur batas upload dan import phpMyAdmin menjadi 100MB (FIX LOOP)
echo "Mengatur batas upload dan import phpMyAdmin menjadi 100MB..."
for file in /etc/php/*/apache2/php.ini
do
    sudo sed -i 's/^upload_max_filesize.*/upload_max_filesize = 100M/' $file
    sudo sed -i 's/^post_max_size.*/post_max_size = 100M/' $file
done

# Restart MariaDB untuk menerapkan perubahan
echo "Restarting MariaDB..."
sudo systemctl restart mariadb

# Restart Apache lagi untuk memastikan semua konfigurasi diterapkan
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Semua paket berhasil diinstal dan Apache menggunakan port 2002!"
