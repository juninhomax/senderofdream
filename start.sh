#!/bin/bash

# Télécharger le certificat SSL CA pour Azure MySQL
mkdir -p /opt/ssl
wget -O /opt/ssl/DigiCertGlobalRootCA.crt.pem https://www.digicert.com/CACerts/DigiCertGlobalRootCA.crt

# Debug des variables d'environnement
echo "=== DEBUG VARIABLES ==="
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "MYSQL_ATTR_SSL_CA: $MYSQL_ATTR_SSL_CA"
echo "======================="

# Test de connectivité réseau
echo "=== NETWORK TESTS ==="
echo "Testing DNS resolution..."
nslookup $DB_HOST || echo "DNS resolution failed"
echo "Testing ping..."
ping -c 3 $DB_HOST || echo "Ping failed"
echo "Testing MySQL port 3306..."
nc -zv $DB_HOST 3306 || echo "MySQL port test failed"
echo "===================="

# Test de connexion MySQL direct
echo "=== MYSQL CONNECTION TEST ==="
mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;" || echo "Direct MySQL connection failed"
echo "============================="

# Attendre que MySQL soit prêt
echo "Waiting for database connection..."
until php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "Database ready, running migrations..."
php artisan migrate --force

echo "Running seeders..."
php artisan db:seed --force

echo "Starting Apache..."
apache2-foreground
